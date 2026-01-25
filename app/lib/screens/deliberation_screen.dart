import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/sage_avatar.dart';
import 'resolution_screen.dart';

class DeliberationScreen extends ConsumerStatefulWidget {
  const DeliberationScreen({super.key, required this.question});

  final String question;

  @override
  ConsumerState<DeliberationScreen> createState() => _DeliberationScreenState();
}

class _DeliberationScreenState extends ConsumerState<DeliberationScreen> {
  final ScrollController _scrollController = ScrollController();
  Consultation? _consultation;
  List<_TimelineItem> _timeline = [];
  final List<_TimelineItem> _displayed = [];
  Timer? _timer;
  bool _loading = true;
  bool _complete = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConsultation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultation() async {
    final api = ref.read(apiServiceProvider);
    final local = ref.read(localStorageProvider);
    try {
      final consultation = await api.deliberate(widget.question);
      await local.saveConsultation(consultation);
      final count = local.incrementConsultationCount();
      if (!mounted) return;
      setState(() {
        _consultation = consultation;
        _timeline = _flatten(consultation);
        _loading = false;
      });
      ref.read(analyticsProvider).logConsultationComplete();
      if (count == 3 && mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('登録のおすすめ'),
            content: const Text('履歴を守るため、次回以降の登録をおすすめします。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      }
      _startPlayback();
    } on DailyLimitExceededException catch (error) {
      if (!mounted) return;
      final resetAt = error.resetAt;
      setState(() {
        _loading = false;
        _errorMessage = resetAt == null
            ? error.message
            : '${error.message}\nリセット: $resetAt';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = '通信に失敗しました。時間をおいて再度お試しください。';
      });
    }
  }

  List<_TimelineItem> _flatten(Consultation consultation) {
    final items = <_TimelineItem>[];
    for (final round in consultation.rounds) {
      for (final message in round.messages) {
        items.add(
          _TimelineItem(
            roundNumber: round.roundNumber,
            ai: message.ai,
            message: message.message,
          ),
        );
      }
    }
    return items;
  }

  void _startPlayback() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_displayed.length >= _timeline.length) {
        timer.cancel();
        setState(() {
          _complete = true;
        });
        return;
      }
      setState(() {
        _displayed.add(_timeline[_displayed.length]);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  int get _currentRound {
    if (_displayed.isEmpty) return 1;
    return _displayed.last.roundNumber;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      title: '審議',
      body: _loading
          ? const _LoadingView()
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadConsultation)
              : Column(
                  children: [
                    // ラウンド表示（羊皮紙風）
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ラウンド $_currentRound / 3',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _displayed.length,
                        itemBuilder: (context, index) {
                          final item = _displayed[index];
                          return _MessageBubble(item: item);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_complete && _consultation != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => ResolutionScreen(
                                  consultation: _consultation!,
                                  showAd: true,
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.description,
                            color: AppColors.goldLight,
                          ),
                          label: Text(
                            '決議を確認する',
                            style: TextStyle(color: AppColors.goldLight),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '審議中...',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
}

class _TimelineItem {
  _TimelineItem({
    required this.roundNumber,
    required this.ai,
    required this.message,
  });

  final int roundNumber;
  final String ai;
  final String message;
}

/// 手紙風のメッセージバブル
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.item});

  final _TimelineItem item;

  Sage get _sage => Sage.fromApiKey(item.ai);

  @override
  Widget build(BuildContext context) {
    final sage = _sage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左側のアクセントバー
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: sage.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            // メインコンテンツ
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.cardBorder, width: 1),
                    right: BorderSide(color: AppColors.cardBorder, width: 1),
                    bottom: BorderSide(color: AppColors.cardBorder, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // アバター
                    SageAvatar(
                      sage: sage,
                      size: 44,
                      borderWidth: 2,
                      showGoldFrame: false,
                    ),
                    const SizedBox(width: 10),
                    // メッセージ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 名前
                          Text(
                            sage.displayName,
                            style: TextStyle(
                              color: sage.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // メッセージ本文
                          Text(
                            item.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ローディング画面（会議準備中）
class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> {
  int _messageIndex = 0;
  Timer? _timer;

  static const _messages = [
    '会議を準備中...',
    '三賢人を召喚中...',
    '論理の学者が分析中...',
    '共感の修道士が傾聴中...',
    '直感の預言者が洞察中...',
    '議論を整理中...',
    '決議をまとめ中...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: AppDecorations.parchmentCard(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ローディングアイコン
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // メッセージ
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _messages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// エラー画面
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: AppDecorations.parchmentCard(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

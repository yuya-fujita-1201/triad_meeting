import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
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
            : '${error.message}\\nリセット: $resetAt';
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadConsultation)
              : Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'ラウンド $_currentRound / 3',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        if (_consultation != null)
                          Text(
                            '相談: ${widget.question}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                        child: ElevatedButton(
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
                          child: const Text('決議を確認する'),
                        ),
                      )
                    else
                      Text(
                        '審議中...',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.item});

  final _TimelineItem item;

  Color get _color {
    switch (item.ai) {
      case 'heart':
        return AppColors.heart;
      case 'flash':
        return AppColors.flash;
      case 'logic':
      default:
        return AppColors.logic;
    }
  }

  String get _label {
    switch (item.ai) {
      case 'heart':
        return '共感';
      case 'flash':
        return '直感';
      case 'logic':
      default:
        return '論理';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _label,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(item.message),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
      ],
    );
  }
}

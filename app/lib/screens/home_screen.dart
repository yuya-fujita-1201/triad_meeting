import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/sage_avatar.dart';
import 'deliberation_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startConsultation() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相談内容を入力してください。')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final localStorage = ref.read(localStorageProvider);
    if (!localStorage.hasAiConsent) {
      _showAiConsentDialog(text);
      return;
    }

    _navigateToDeliberation(text);
  }

  void _navigateToDeliberation(String text) {
    ref.read(analyticsProvider).logConsultationStart();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliberationScreen(question: text),
      ),
    ).then((_) {
      _controller.clear();
    });
  }

  Future<void> _showAiConsentDialog(String text) async {
    final localStorage = ref.read(localStorageProvider);
    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('AIサービスへのデータ送信について'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '本アプリは、AI審議機能を提供するために、外部のAIサービスへデータを送信します。\n',
                style: TextStyle(height: 1.6),
              ),
              Text(
                '送信されるデータ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '・あなたが入力した相談テキスト\n',
                style: TextStyle(height: 1.6),
              ),
              Text(
                '送信先',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '・OpenAI, Inc.（米国）のAPIサービス\n',
                style: TextStyle(height: 1.6),
              ),
              Text(
                '送信の目的',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '・3人のAI賢者（論理・共感・直感）による審議と決議の生成\n',
                style: TextStyle(height: 1.6),
              ),
              Text(
                'データの取り扱い',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '・氏名やメールアドレスなどの個人情報は送信されません\n'
                '・送信されたデータはOpenAIにより30日後に削除されます\n'
                '・データはAIモデルのトレーニングには使用されません\n',
                style: TextStyle(height: 1.6),
              ),
              Text(
                '詳細はプライバシーポリシーをご覧ください。',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('同意しない'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('同意する'),
          ),
        ],
      ),
    );

    if (agreed == true) {
      await localStorage.setAiConsent(true);
      if (mounted) {
        _navigateToDeliberation(text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      title: '三賢会議',
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
          icon: const Icon(Icons.history),
          tooltip: '履歴',
        ),
        IconButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: const Icon(Icons.settings),
          tooltip: '設定',
        ),
      ],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
          const SizedBox(height: 16),
          
          // キャッチコピー（書道風）
          Text(
            '3つの視点で、迷いを終わらせる',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // 装飾線
          _buildDecorativeLine(),
          const SizedBox(height: 24),
          
          // 上段: 論理（中央寄せ）
          const Center(
            child: SizedBox(
              width: 170,
              child: SageCard(sage: Sage.logic, showSubtitle: true),
            ),
          ),
          const SizedBox(height: 16),
          
          // 下段: 共感・直感（横並び）
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 155,
                child: SageCard(sage: Sage.empathy, showSubtitle: true),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 155,
                child: SageCard(sage: Sage.intuition, showSubtitle: true),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 装飾線
          _buildDecorativeLine(),
          const SizedBox(height: 24),
          
          // 入力フィールド（羊皮紙風）
          Container(
            decoration: AppDecorations.parchmentCard(),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '相談したいことを入力してください...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.edit_note,
                    color: AppColors.secondary,
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 開始ボタン（えんじ色＋金文字）
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startConsultation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppColors.goldLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '会議を開始する',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.goldLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }

  /// 装飾線（羽ペン風）
  Widget _buildDecorativeLine() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cardBorder.withOpacity(0),
                  AppColors.gold.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppColors.gold,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(0.5),
                  AppColors.cardBorder.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

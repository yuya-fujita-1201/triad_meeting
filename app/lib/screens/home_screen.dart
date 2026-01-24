import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_card.dart';
import '../widgets/constrained_scaffold.dart';
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
    ref.read(analyticsProvider).logConsultationStart();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliberationScreen(question: text),
      ),
    );
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
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Text(
            '3つの視点で、迷いを終わらせる',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const AiCard(
            title: 'ロジック',
            description: '事実とデータで論理的に整理します。',
            color: AppColors.logic,
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 12),
          const AiCard(
            title: 'ハート',
            description: '感情や人間関係の視点を尊重します。',
            color: AppColors.heart,
            icon: Icons.favorite_border,
          ),
          const SizedBox(height: 12),
          const AiCard(
            title: 'フラッシュ',
            description: '直感的で行動重視の提案を行います。',
            color: AppColors.flash,
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: '相談内容',
              hintText: '1〜2文で具体的に入力してください。',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _startConsultation,
            child: const Text('会議を始める'),
          ),
        ],
      ),
    );
  }
}

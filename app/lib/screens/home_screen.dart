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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 上段: 論理（中央寄せ）
          const Center(
            child: SizedBox(
              width: 180,
              height: 160,
              child: AiCard(
                title: '論理',
                description: '論理的思考',
                color: AppColors.logic,
                imagePath: 'assets/images/sage_logic.png',
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 下段: 共感・直感（横並び）
          const Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: AiCard(
                    title: '共感',
                    description: '感情・共感',
                    color: AppColors.heart,
                    imagePath: 'assets/images/sage_empathy.png',
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: AiCard(
                    title: '直感',
                    description: '直感・行動',
                    color: AppColors.flash,
                    imagePath: 'assets/images/sage_intuition.png',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: '相談内容',
              hintText: '相談したいことを入力してください...',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _startConsultation,
            child: const Text('会議を開始する'),
          ),
        ],
      ),
    );
  }
}

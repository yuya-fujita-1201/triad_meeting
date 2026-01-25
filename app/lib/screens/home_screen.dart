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
              width: 160,
              child: SageCard(sage: Sage.logic),
            ),
          ),
          const SizedBox(height: 12),
          // 下段: 共感・直感（横並び）
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: SageCard(sage: Sage.empathy),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: SageCard(sage: Sage.intuition),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            maxLines: 2,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: '悩みを入力...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startConsultation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '会議を開始する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

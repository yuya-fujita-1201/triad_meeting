import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_controller.dart';
import '../providers/providers.dart';
import '../widgets/constrained_scaffold.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('アカウント削除'),
            content: const Text('すべての履歴が削除されます。続行しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('削除する'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final history = ref.read(historyControllerProvider).value ?? [];
    final api = ref.read(apiServiceProvider);
    final local = ref.read(localStorageProvider);

    for (final item in history) {
      await api.deleteConsultation(item.consultationId);
    }
    await local.clearAll();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントを削除しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return ConstrainedScaffold(
      title: '設定',
      body: ListView(
        children: [
          ListTile(
            title: const Text('ユーザーID'),
            subtitle: Text(user?.uid ?? '未取得'),
          ),
          const Divider(),
          ListTile(
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('アカウント削除'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

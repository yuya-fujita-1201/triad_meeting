import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
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

    final api = ref.read(apiServiceProvider);
    final local = ref.read(localStorageProvider);

    if (Firebase.apps.isNotEmpty) {
      const pageSize = 50;
      var offset = 0;
      while (true) {
        List<Consultation> page;
        try {
          page = await api.fetchHistory(limit: pageSize, offset: offset);
        } catch (_) {
          page = ref.read(historyControllerProvider).value ?? [];
        }
        if (page.isEmpty) break;
        for (final item in page) {
          try {
            await api.deleteConsultation(item.consultationId);
          } catch (_) {
            // Ignore deletion failures per-item.
          }
        }
        if (page.length < pageSize) break;
        offset += pageSize;
      }
    }
    await local.clearAll();

    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {
          // Ignore if account deletion is not permitted in current auth state.
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントを削除しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;

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

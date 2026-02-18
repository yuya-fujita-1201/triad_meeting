import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
import '../providers/history_controller.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
import 'paywall_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'アカウント削除',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: const Text('すべての履歴が削除されます。続行しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
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
    final purchaseService = ref.watch(purchaseServiceProvider);
    final isPremium = purchaseService.isPremium;

    return ConstrainedScaffold(
      title: '設定',
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // プレミアムステータスカード
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: isPremium
                ? AppDecorations.goldFrameCard()
                : AppDecorations.parchmentCard(),
            child: ListTile(
              leading: Icon(
                isPremium ? Icons.auto_awesome : Icons.workspace_premium,
                color: isPremium ? AppColors.gold : AppColors.secondary,
              ),
              title: Text(
                isPremium ? 'プレミアム会員' : 'フリープラン',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPremium ? AppColors.primaryDark : null,
                    ),
              ),
              subtitle: Text(
                isPremium
                    ? '無制限の相談・広告なし'
                    : '1日10回まで・広告表示あり',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              trailing: isPremium
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'アップグレード',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              onTap: isPremium
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      ),
            ),
          ),

          const SizedBox(height: 8),

          // 購入復元（プレミアムでない場合のみ）
          if (!isPremium) ...[
            Container(
              decoration: AppDecorations.parchmentCard(),
              child: ListTile(
                leading: Icon(
                  Icons.restore,
                  color: AppColors.secondary,
                ),
                title: Text(
                  '購入を復元',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
                onTap: () async {
                  final success = await purchaseService.restore();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? '購入を復元しました！'
                            : '復元可能な購入が見つかりませんでした'),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ユーザー情報カード
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: AppDecorations.parchmentCard(),
            child: ListTile(
              leading: Icon(
                Icons.person_outline,
                color: AppColors.secondary,
              ),
              title: Text(
                'ユーザーID',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(
                user?.uid ?? '未取得',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // プライバシーポリシー
          Container(
            decoration: AppDecorations.parchmentCard(),
            child: ListTile(
              leading: Icon(
                Icons.description_outlined,
                color: AppColors.secondary,
              ),
              title: Text(
                'プライバシーポリシー',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // アカウント削除
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppColors.accent,
              ),
              title: Text(
                'アカウント削除',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.accent.withOpacity(0.5),
              ),
              onTap: () => _deleteAccount(context, ref),
            ),
          ),

          const SizedBox(height: 32),

          // アプリ情報
          Center(
            child: Column(
              children: [
                Text(
                  '三賢会議',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 2.0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

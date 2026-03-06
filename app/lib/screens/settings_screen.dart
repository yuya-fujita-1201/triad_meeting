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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _accountStatusText(User? user) {
    if (Firebase.apps.isEmpty) {
      return '認証は現在利用できません。';
    }
    if (user == null) {
      return '未サインイン（通信時に匿名アカウントを自動作成します）';
    }
    if (user.isAnonymous) {
      return '匿名アカウントで利用中（登録不要）';
    }
    return '登録アカウントで利用中';
  }

  Future<void> _resetUsageData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              '利用データを初期化',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: const Text('履歴と設定が初期化されます。続行しますか？'),
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
                child: const Text('初期化する'),
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
          // account deletion が失敗した場合は signOut で状態をリセット
          try {
            await FirebaseAuth.instance.signOut();
          } catch (_) {}
        }
      }
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {
        // 初期化直後に通信した際、ApiService側でも匿名サインインを試行する
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('利用データを初期化しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseService = ref.watch(purchaseServiceProvider);
    final isPremium = purchaseService.isPremium;
    final user = Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;

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

          // 利用状態
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: AppDecorations.parchmentCard(),
            child: ListTile(
              leading: Icon(
                Icons.verified_user_outlined,
                color: AppColors.secondary,
              ),
              title: Text(
                '利用状態',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(
                _accountStatusText(user),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // AIデータ送信の同意管理
          Container(
            decoration: AppDecorations.parchmentCard(),
            child: ListTile(
              leading: Icon(
                Icons.psychology_outlined,
                color: AppColors.secondary,
              ),
              title: Text(
                'AIデータ送信への同意',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              subtitle: Text(
                ref.watch(localStorageProvider).hasAiConsent
                    ? '同意済み - 審議内容をAIサービスに送信します'
                    : '未同意 - AI審議機能は利用できません',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              trailing: Switch(
                value: ref.watch(localStorageProvider).hasAiConsent,
                activeTrackColor: AppColors.primary,
                onChanged: (value) async {
                  if (!value) {
                    final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              'AI同意の撤回',
                              style: Theme.of(ctx).textTheme.titleMedium,
                            ),
                            content: const Text(
                              'AIデータ送信への同意を撤回すると、AI審議機能が利用できなくなります。撤回しますか？',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  'キャンセル',
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                ),
                                child: const Text('撤回する'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (!confirmed) return;
                  }
                  await ref.read(localStorageProvider).setAiConsent(value);
                  setState(() {});
                },
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

          // 利用データ初期化
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.restart_alt,
                color: AppColors.accent,
              ),
              title: Text(
                '利用データを初期化',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.accent.withOpacity(0.5),
              ),
              onTap: () => _resetUsageData(context),
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

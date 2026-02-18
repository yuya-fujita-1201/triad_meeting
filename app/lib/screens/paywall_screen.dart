import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _purchasing = false;

  Future<void> _purchase(StoreProduct product) async {
    setState(() => _purchasing = true);
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final success = await purchaseService.purchase(product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プレミアムプランに加入しました！')),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final success = await purchaseService.restore();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('購入を復元しました！')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('復元可能な購入が見つかりませんでした')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseService = ref.watch(purchaseServiceProvider);
    final products = purchaseService.products;

    return ConstrainedScaffold(
      title: 'プレミアムプラン',
      body: _purchasing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 16),

                // ヘッダー装飾
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.goldFrameCard(),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '三賢会議 プレミアム',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '賢者たちの知恵を、制限なく。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 特典リスト
                _FeatureItem(
                  icon: Icons.all_inclusive,
                  title: '無制限の相談',
                  description: '1日の回数制限なし。何度でも賢者に相談できます。',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.block,
                  title: '広告なし',
                  description: '決議書表示後のインタースティシャル広告が非表示になります。',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.support_agent,
                  title: '優先サポート',
                  description: 'プレミアム会員向けの優先対応。',
                ),

                const SizedBox(height: 32),

                // プラン選択
                if (products.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.parchmentCard(),
                    child: Text(
                      'プラン情報を読み込み中...\nしばらくお待ちください。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  ...products.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          product: product,
                          onTap: () => _purchase(product),
                        ),
                      )),
                ],

                const SizedBox(height: 16),

                // 復元ボタン
                Center(
                  child: TextButton(
                    onPressed: _restore,
                    child: Text(
                      '購入を復元する',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 注意書き
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'サブスクリプションは自動更新されます。'
                    '期間終了の24時間前までにキャンセルしない限り自動更新されます。'
                    'お支払いはApple IDアカウントに請求されます。'
                    '設定アプリからいつでも解約できます。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

/// 特典アイテム
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.parchmentCard(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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

/// プランカード
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.product,
    required this.onTap,
  });

  final StoreProduct product;
  final VoidCallback onTap;

  String _getPlanLabel() {
    final id = product.identifier.toLowerCase();
    if (id.contains('weekly')) return '週額プラン';
    if (id.contains('monthly')) return '月額プラン';
    return product.title;
  }

  bool _isRecommended() {
    return product.identifier.toLowerCase().contains('monthly');
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _isRecommended();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: recommended
            ? AppDecorations.goldFrameCard(borderWidth: 2)
            : AppDecorations.parchmentCard(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPlanLabel(),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'おすすめ',
                            style: TextStyle(
                              color: AppColors.card,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              product.priceString,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

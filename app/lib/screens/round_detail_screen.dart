import 'package:flutter/material.dart';

import '../models/consultation.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/sage_avatar.dart';

/// ラウンド詳細画面
/// 決議書から遷移して、3ラウンドのやり取りを確認できる
class RoundDetailScreen extends StatefulWidget {
  const RoundDetailScreen({
    super.key,
    required this.consultation,
  });

  final Consultation consultation;

  @override
  State<RoundDetailScreen> createState() => _RoundDetailScreenState();
}

class _RoundDetailScreenState extends State<RoundDetailScreen> {
  int _selectedRound = 0;

  @override
  Widget build(BuildContext context) {
    final rounds = widget.consultation.rounds;

    return ConstrainedScaffold(
      title: 'ラウンド詳細',
      body: Column(
        children: [
          // 相談内容（羊皮紙風）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.parchmentCard(
              borderColor: AppColors.secondary.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '相談内容',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.consultation.question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ラウンドタブ（エレガントなスタイル）
          Row(
            children: List.generate(rounds.length, (index) {
              final isSelected = _selectedRound == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRound = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.gold, width: 1.5)
                          : Border.all(color: AppColors.cardBorder),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    margin: EdgeInsets.only(right: index < rounds.length - 1 ? 8 : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 14,
                          color: isSelected ? AppColors.goldLight : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ラウンド ${index + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // メッセージ一覧（手紙風）
          Expanded(
            child: ListView.builder(
              itemCount: rounds.isNotEmpty ? rounds[_selectedRound].messages.length : 0,
              itemBuilder: (context, index) {
                final message = rounds[_selectedRound].messages[index];
                final sage = Sage.fromApiKey(message.ai);
                return _RoundMessageBubble(
                  sage: sage,
                  message: message.message,
                  isLast: index == rounds[_selectedRound].messages.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ラウンド詳細用のメッセージバブル（手紙風）
class _RoundMessageBubble extends StatelessWidget {
  const _RoundMessageBubble({
    required this.sage,
    required this.message,
    this.isLast = false,
  });

  final Sage sage;
  final String message;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.letterBubble(accentColor: sage.color),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アバター（金縁フレーム）
            SageAvatar(
              sage: sage,
              size: 52,
              borderWidth: 2,
              showGoldFrame: true,
            ),
            const SizedBox(width: 14),
            // メッセージ内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前とサブタイトル
                  Row(
                    children: [
                      Text(
                        sage.displayName,
                        style: TextStyle(
                          color: sage.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sage.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // メッセージ本文
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

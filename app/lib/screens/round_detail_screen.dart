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
          // 相談内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '相談内容',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.consultation.question,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ラウンドタブ
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
                          ? null
                          : Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    margin: EdgeInsets.only(right: index < rounds.length - 1 ? 8 : 0),
                    child: Text(
                      'ラウンド ${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // メッセージ一覧
          Expanded(
            child: ListView.builder(
              itemCount: rounds.isNotEmpty ? rounds[_selectedRound].messages.length : 0,
              itemBuilder: (context, index) {
                final message = rounds[_selectedRound].messages[index];
                final sage = Sage.fromApiKey(message.ai);
                return _RoundMessageBubble(
                  sage: sage,
                  message: message.message,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ラウンド詳細用のメッセージバブル
class _RoundMessageBubble extends StatelessWidget {
  const _RoundMessageBubble({
    required this.sage,
    required this.message,
  });

  final Sage sage;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sage.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: sage.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アバター
            SageAvatar(
              sage: sage,
              size: 48,
              borderWidth: 2,
            ),
            const SizedBox(width: 12),
            // メッセージ内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sage.displayName,
                        style: TextStyle(
                          color: sage.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sage.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
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

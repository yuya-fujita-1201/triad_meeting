import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/consultation.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';
import '../widgets/sage_avatar.dart';
import 'round_detail_screen.dart';

class ResolutionScreen extends ConsumerStatefulWidget {
  const ResolutionScreen({
    super.key,
    required this.consultation,
    this.showAd = false,
  });

  final Consultation consultation;
  final bool showAd;

  @override
  ConsumerState<ResolutionScreen> createState() => _ResolutionScreenState();
}

class _ResolutionScreenState extends ConsumerState<ResolutionScreen> {
  @override
  void initState() {
    super.initState();
    
    if (widget.showAd) {
      final adService = ref.read(adServiceProvider);
      adService.loadInterstitial();
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        adService.showInterstitialIfReady();
      });
    }
  }

  void _showRoundDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoundDetailScreen(consultation: widget.consultation),
      ),
    );
  }

  Future<void> _share() async {
    final summary = _buildShareText(widget.consultation);
    await Share.share(summary, subject: '三賢会議の決議');
  }

  String _buildShareText(Consultation consultation) {
    final resolution = consultation.resolution;
    final votes = [
      '${Sage.logic.displayName}: ${resolution.getVoteDisplayText(resolution.votes['logic'] ?? '')}',
      '${Sage.empathy.displayName}: ${resolution.getVoteDisplayText(resolution.votes['heart'] ?? '')}',
      '${Sage.intuition.displayName}: ${resolution.getVoteDisplayText(resolution.votes['flash'] ?? '')}',
    ].join('\n');
    final reasoning = resolution.reasoning.join(' / ');
    final nextSteps = resolution.nextSteps.join(' / ');
    return '''相談: ${consultation.question}

決議: ${resolution.decision}

投票:
$votes

理由: $reasoning
次の一手: $nextSteps
再審期限: ${resolution.reviewDate}
''';
  }

  @override
  Widget build(BuildContext context) {
    final resolution = widget.consultation.resolution;

    return ConstrainedScaffold(
      title: '決議書',
      body: Column(
        children: [
          // スクロール可能なメインコンテンツ
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 決議内容カード
                  Container(
                    decoration: AppDecorations.parchmentCard(
                      borderColor: AppColors.gold.withOpacity(0.5),
                      borderWidth: 1.5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 決議文
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              resolution.decision,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          
                          // 投票セクション
                          _CompactSectionTitle(title: '投票'),
                          const SizedBox(height: 10),
                          
                          // 3賢人の投票（横並び）
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _CompactVoteCard(
                                sage: Sage.logic,
                                vote: resolution.votes['logic'],
                                resolution: resolution,
                              ),
                              _CompactVoteCard(
                                sage: Sage.empathy,
                                vote: resolution.votes['heart'],
                                resolution: resolution,
                              ),
                              _CompactVoteCard(
                                sage: Sage.intuition,
                                vote: resolution.votes['flash'],
                                resolution: resolution,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          
                          // 理由セクション
                          _CompactSectionTitle(title: '理由'),
                          const SizedBox(height: 6),
                          _CompactBulletList(items: resolution.reasoning),
                          const SizedBox(height: 12),
                          
                          // 次の一手セクション
                          _CompactSectionTitle(title: '次の一手'),
                          const SizedBox(height: 6),
                          _CompactBulletList(items: resolution.nextSteps),
                          
                          if (resolution.risks.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _CompactSectionTitle(title: 'リスク'),
                            const SizedBox(height: 6),
                            _CompactBulletList(items: resolution.risks),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 固定フッター（ボタン）
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showRoundDetail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'ラウンド詳細',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _share,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'シェア',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 14,
                      ),
                    ),
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

/// コンパクトなセクションタイトル
class _CompactSectionTitle extends StatelessWidget {
  const _CompactSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

/// コンパクトな箇条書きリスト
class _CompactBulletList extends StatelessWidget {
  const _CompactBulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'なし',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '・',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            fontSize: 13,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// コンパクトな投票カード
class _CompactVoteCard extends StatelessWidget {
  const _CompactVoteCard({
    required this.sage,
    required this.resolution,
    this.vote,
  });

  final Sage sage;
  final Resolution resolution;
  final String? vote;

  @override
  Widget build(BuildContext context) {
    final voteText = resolution.getVoteDisplayText(vote ?? '');
    final voteColor = _getVoteColor(vote, resolution.questionType, resolution.options);

    return Column(
      children: [
        // アバター
        SageAvatar(
          sage: sage,
          size: 48,
          borderWidth: 2,
          showGoldFrame: false,
        ),
        const SizedBox(height: 4),
        // 名前
        Text(
          sage.displayName,
          style: TextStyle(
            color: sage.color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        // 投票結果バッジ
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: voteColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            voteText,
            style: TextStyle(
              color: AppColors.card,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 質問タイプに応じた投票バッジの色を決定
Color _getVoteColor(String? vote, QuestionType questionType, VoteOptions? options) {
  switch (questionType) {
    case QuestionType.yesno:
      switch (vote) {
        case 'approve':
          return AppColors.logic;
        case 'reject':
          return AppColors.heart;
        case 'pending':
        default:
          return AppColors.flash;
      }
    
    case QuestionType.choice:
      switch (vote) {
        case 'A':
          return AppColors.logic;
        case 'B':
          return AppColors.heart;
        case 'both':
          return AppColors.success;
        case 'depends':
        default:
          return AppColors.flash;
      }
    
    case QuestionType.open:
      switch (vote) {
        case 'strongly_recommend':
          return AppColors.logic;
        case 'recommend':
          return AppColors.success;
        case 'conditional':
        default:
          return AppColors.flash;
      }
  }
}

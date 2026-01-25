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
    // 審議画面で既に自動保存済み
    
    if (widget.showAd) {
      final adService = ref.read(adServiceProvider);
      adService.loadInterstitial();
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        adService.showInterstitialIfReady();
      });
    }
  }

  /// ラウンド詳細画面へ遷移
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
      title: '三賢会議',
      body: ListView(
        children: [
          // 決議書タイトル（書道風）
          Center(
            child: Column(
              children: [
                Text(
                  '決議書',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                // 装飾線
                Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withOpacity(0),
                        AppColors.gold,
                        AppColors.gold.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 決議内容カード（羊皮紙風）
          Container(
            decoration: AppDecorations.goldFrameCard(borderWidth: 1.5),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 決議文
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      resolution.decision,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.8,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 投票セクション
                  SectionTitle(title: '投票', icon: Icons.how_to_vote),
                  const SizedBox(height: 16),
                  
                  // 3賢人の投票（横並び）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _VoteCard(
                        sage: Sage.logic,
                        vote: resolution.votes['logic'],
                        resolution: resolution,
                      ),
                      _VoteCard(
                        sage: Sage.empathy,
                        vote: resolution.votes['heart'],
                        resolution: resolution,
                      ),
                      _VoteCard(
                        sage: Sage.intuition,
                        vote: resolution.votes['flash'],
                        resolution: resolution,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 理由セクション
                  SectionTitle(title: '理由', icon: Icons.lightbulb_outline),
                  const SizedBox(height: 12),
                  _BulletList(items: resolution.reasoning),
                  const SizedBox(height: 20),
                  
                  // 次の一手セクション
                  SectionTitle(title: '次の一手', icon: Icons.explore),
                  const SizedBox(height: 12),
                  _BulletList(items: resolution.nextSteps),
                  
                  if (resolution.risks.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SectionTitle(title: 'リスク', icon: Icons.warning_amber),
                    const SizedBox(height: 12),
                    _BulletList(items: resolution.risks),
                  ],
                  
                  // 再審期限
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '再審期限: ${resolution.reviewDate}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 自動保存メッセージ（落ち着いた緑）
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  '履歴に自動保存されました',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // ボタン（左: ラウンド詳細を見る、右: シェア）
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showRoundDetail,
                  icon: Icon(Icons.auto_stories, size: 18, color: AppColors.primary),
                  label: Text(
                    'ラウンド詳細',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _share,
                  icon: Icon(Icons.share, size: 18, color: AppColors.goldLight),
                  label: Text(
                    'シェア',
                    style: TextStyle(color: AppColors.goldLight),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 箇条書きリスト（インクドット風）
class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'なし',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // インクドット風のマーカー
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
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

/// 投票カード（アバター + サブタイトル + 投票結果）
class _VoteCard extends StatelessWidget {
  const _VoteCard({
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
        // アバター（金縁フレーム）
        SageAvatar(
          sage: sage,
          size: 56,
          borderWidth: 2,
          showGoldFrame: true,
        ),
        const SizedBox(height: 8),
        // サブタイトル
        Text(
          sage.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
                fontSize: 10,
              ),
        ),
        const SizedBox(height: 6),
        // 投票結果バッジ
        VoteBadge(
          text: voteText,
          color: voteColor,
        ),
      ],
    );
  }
}

/// 質問タイプに応じた投票バッジの色を決定
Color _getVoteColor(String? vote, QuestionType questionType, VoteOptions? options) {
  switch (questionType) {
    case QuestionType.yesno:
      // Yes/No型
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
      // 選択肢型
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
      // オープン型
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

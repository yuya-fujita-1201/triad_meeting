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
          // 決議書タイトル
          Center(
            child: Text(
              '決議書',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 決議内容カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 決議文
                  Text(
                    resolution.decision,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 投票セクション
                  const _SectionTitle(title: '投票'),
                  const SizedBox(height: 12),
                  
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
                  const SizedBox(height: 20),
                  
                  // 理由セクション
                  const _SectionTitle(title: '理由'),
                  const SizedBox(height: 8),
                  _BulletList(items: resolution.reasoning),
                  const SizedBox(height: 16),
                  
                  // 次の一手セクション
                  const _SectionTitle(title: '次の一手'),
                  const SizedBox(height: 8),
                  _BulletList(items: resolution.nextSteps),
                  
                  if (resolution.risks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _SectionTitle(title: 'リスク'),
                    const SizedBox(height: 8),
                    _BulletList(items: resolution.risks),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 自動保存メッセージ（審議完了時に自動保存済み）
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 6),
                Text(
                  '履歴に自動保存されました',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // ボタン（左: ラウンド詳細を見る、右: シェア）
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showRoundDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('ラウンド詳細'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _share,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('シェア'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

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
            ?.copyWith(color: AppColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
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
        // アバター
        SageAvatar(
          sage: sage,
          size: 56,
          borderWidth: 2.5,
        ),
        const SizedBox(height: 6),
        // サブタイトル（東洋の学者など）
        Text(
          sage.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 4),
        // 投票結果バッジ
        Container(
          constraints: const BoxConstraints(maxWidth: 90),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: voteColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            voteText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
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
      // Yes/No型: 賛成=青, 反対=ピンク, 保留=黄
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
      // 選択肢型: A=青, B=ピンク, どちらも=緑, 状況次第=黄
      switch (vote) {
        case 'A':
          return AppColors.logic;
        case 'B':
          return AppColors.heart;
        case 'both':
          return const Color(0xFF4CAF50); // 緑
        case 'depends':
        default:
          return AppColors.flash;
      }
    
    case QuestionType.open:
      // オープン型: 強く推奨=青, 推奨=緑, 条件付き=黄
      switch (vote) {
        case 'strongly_recommend':
          return AppColors.logic;
        case 'recommend':
          return const Color(0xFF4CAF50); // 緑
        case 'conditional':
        default:
          return AppColors.flash;
      }
  }
}

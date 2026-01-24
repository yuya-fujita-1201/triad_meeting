import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/consultation.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_scaffold.dart';

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

  Future<void> _save() async {
    final local = ref.read(localStorageProvider);
    await local.saveConsultation(widget.consultation);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴に保存しました。')),
    );
  }

  Future<void> _share() async {
    final summary = _buildShareText(widget.consultation);
    await Share.share(summary, subject: '三賢会議の決議');
  }

  String _buildShareText(Consultation consultation) {
    final resolution = consultation.resolution;
    final votes = resolution.votes.entries
        .map((entry) => '${_labelForAi(entry.key)}: ${entry.value}')
        .join('\n');
    final reasoning = resolution.reasoning.join(' / ');
    final nextSteps = resolution.nextSteps.join(' / ');
    return '''相談: ${consultation.question}

決議: ${resolution.decision}

投票:\n$votes

理由: $reasoning
次の一手: $nextSteps
再審期限: ${resolution.reviewDate}
''';
  }

  String _labelForAi(String ai) {
    switch (ai) {
      case 'logic':
        return 'ロジック';
      case 'heart':
        return 'ハート';
      case 'flash':
        return 'フラッシュ';
      default:
        return ai;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolution = widget.consultation.resolution;

    return ConstrainedScaffold(
      title: '決議書',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolution.decision,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(title: '投票'),
                  const SizedBox(height: 8),
                  _VoteRow(label: 'ロジック', value: resolution.votes['logic']),
                  _VoteRow(label: 'ハート', value: resolution.votes['heart']),
                  _VoteRow(label: 'フラッシュ', value: resolution.votes['flash']),
                  const SizedBox(height: 12),
                  _SectionTitle(title: '理由'),
                  const SizedBox(height: 8),
                  _BulletList(items: resolution.reasoning),
                  const SizedBox(height: 12),
                  _SectionTitle(title: '次の一手'),
                  const SizedBox(height: 8),
                  _BulletList(items: resolution.nextSteps),
                  const SizedBox(height: 12),
                  _SectionTitle(title: '再審期限'),
                  const SizedBox(height: 8),
                  Text(resolution.reviewDate),
                  if (resolution.risks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionTitle(title: 'リスク'),
                    const SizedBox(height: 8),
                    _BulletList(items: resolution.risks),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _save,
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _share,
                  child: const Text('シェア'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '相談内容: ${widget.consultation.question}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
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
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
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

class _VoteRow extends StatelessWidget {
  const _VoteRow({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = _voteLabel(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            display,
            style: TextStyle(
              color: display == '賛成'
                  ? AppColors.logic
                  : display == '反対'
                      ? AppColors.heart
                      : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _voteLabel(String? value) {
  switch (value) {
    case 'approve':
      return '賛成';
    case 'reject':
      return '反対';
    case 'pending':
      return '保留';
    default:
      return '保留';
  }
}

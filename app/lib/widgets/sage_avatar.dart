import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 三賢人の定義
enum Sage {
  logic,
  empathy,
  intuition;

  String get displayName {
    switch (this) {
      case Sage.logic:
        return '論理';
      case Sage.empathy:
        return '共感';
      case Sage.intuition:
        return '直感';
    }
  }

  String get displayNameEn {
    switch (this) {
      case Sage.logic:
        return 'Logic';
      case Sage.empathy:
        return 'Empathy';
      case Sage.intuition:
        return 'Intuition';
    }
  }

  String get subtitle {
    switch (this) {
      case Sage.logic:
        return '論理の学者';
      case Sage.empathy:
        return '共感の修道士';
      case Sage.intuition:
        return '直感の預言者';
    }
  }

  String get imagePath {
    switch (this) {
      case Sage.logic:
        return 'assets/images/sage_logic.png';
      case Sage.empathy:
        return 'assets/images/sage_empathy.png';
      case Sage.intuition:
        return 'assets/images/sage_intuition.png';
    }
  }

  Color get color {
    switch (this) {
      case Sage.logic:
        return AppColors.logic;
      case Sage.empathy:
        return AppColors.heart;
      case Sage.intuition:
        return AppColors.flash;
    }
  }

  /// APIのaiフィールドからSageを取得
  static Sage fromApiKey(String key) {
    switch (key) {
      case 'heart':
        return Sage.empathy;
      case 'flash':
        return Sage.intuition;
      case 'logic':
      default:
        return Sage.logic;
    }
  }
}

/// 賢人アバターウィジェット（円形、金縁フレーム付き）
class SageAvatar extends StatelessWidget {
  const SageAvatar({
    super.key,
    required this.sage,
    this.size = 60,
    this.borderWidth = 2,
    this.showGoldFrame = true,
  });

  final Sage sage;
  final double size;
  final double borderWidth;
  final bool showGoldFrame;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // 外側の金の輪
        border: showGoldFrame
            ? Border.all(
                color: AppColors.gold,
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(showGoldFrame ? 2 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // 内側の賢人カラーの輪
          border: Border.all(
            color: sage.color,
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            sage.imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// ホーム画面用の大きなカード（羊皮紙スタイル）
class SageCard extends StatelessWidget {
  const SageCard({
    super.key,
    required this.sage,
    this.showSubtitle = true,
  });

  final Sage sage;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.parchmentCard(
        borderColor: sage.color.withOpacity(0.5),
        borderWidth: 1.5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 賢人名（書道風）
            Text(
              sage.displayName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: sage.color,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            // アバター（金縁フレーム）
            SageAvatar(
              sage: sage,
              size: 80,
              borderWidth: 2,
              showGoldFrame: true,
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 10),
              // サブタイトル（イタリック風）
              Text(
                sage.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 投票バッジ（蝋封印風）
class VoteBadge extends StatelessWidget {
  const VoteBadge({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.card,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// セクションタイトル（万年筆風）
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cardBorder,
                  AppColors.cardBorder.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

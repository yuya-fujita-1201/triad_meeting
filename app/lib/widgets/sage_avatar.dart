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
        return '東洋の学者';
      case Sage.empathy:
        return '西洋の修道士';
      case Sage.intuition:
        return '西洋の預言者';
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

/// 賢人アバターウィジェット（円形、枠線付き）
class SageAvatar extends StatelessWidget {
  const SageAvatar({
    super.key,
    required this.sage,
    this.size = 60,
    this.borderWidth = 3,
  });

  final Sage sage;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
    );
  }
}

/// ホーム画面用の大きなカード
class SageCard extends StatelessWidget {
  const SageCard({
    super.key,
    required this.sage,
    this.showSubtitle = false,
  });

  final Sage sage;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sage.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SageAvatar(
              sage: sage,
              size: 80,
              borderWidth: 3,
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 8),
              Text(
                sage.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

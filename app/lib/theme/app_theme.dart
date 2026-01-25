import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 古代賢人・羊皮紙・万年筆インク風デザインのカラーパレット
class AppColors {
  // メインカラー（バーガンディ/えんじ色）
  static const Color primary = Color(0xFF8B4557);
  static const Color primaryDark = Color(0xFF6B2D3E);
  
  // セカンダリ（アンティークゴールド）
  static const Color secondary = Color(0xFFB8956C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D5A3);
  
  // 三賢人の色（落ち着いたトーン）
  static const Color logic = Color(0xFF3D5A80);      // 深い紺青
  static const Color heart = Color(0xFFB56576);      // 落ち着いたコーラル
  static const Color flash = Color(0xFFCD9A35);      // アンティークゴールド
  
  // 背景色（羊皮紙・クリーム色）
  static const Color background = Color(0xFFF5EFE0);     // 羊皮紙ベース
  static const Color backgroundDark = Color(0xFFEDE4D0); // 少し濃い羊皮紙
  static const Color card = Color(0xFFFAF6ED);           // カード背景
  static const Color cardBorder = Color(0xFFD4C9B5);     // カードの枠線
  
  // テキスト（インク色）
  static const Color textPrimary = Color(0xFF2C2416);    // 濃いインク
  static const Color textSecondary = Color(0xFF6B5D4D);  // 薄いインク
  static const Color textMuted = Color(0xFF9A8B78);      // さらに薄い
  
  // アクセント
  static const Color accent = Color(0xFFC25450);         // 朱色（印鑑風）
  static const Color success = Color(0xFF5B7F5B);        // 落ち着いた緑
}

class AppTheme {
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      background: AppColors.background,
    );

    // Noto Serif JP を使用して、万年筆で書いたような雰囲気に
    final textTheme = GoogleFonts.notoSerifJpTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        // タイトル用に少し太めのスタイル
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          height: 1.8,
          letterSpacing: 0.3,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          height: 1.7,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 2.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: TextStyle(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.goldLight,
          elevation: 2,
          shadowColor: AppColors.primaryDark.withOpacity(0.3),
          textStyle: GoogleFonts.notoSerifJp(
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.gold, width: 1.5),
          textStyle: GoogleFonts.notoSerifJp(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.notoSerifJp(
          color: AppColors.card,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// 装飾用のカスタムウィジェット・スタイル
class AppDecorations {
  /// 羊皮紙風のカードデコレーション
  static BoxDecoration parchmentCard({
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: borderColor ?? AppColors.cardBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.textMuted.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 金縁フレーム付きのデコレーション
  static BoxDecoration goldFrameCard({
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.gold,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// メッセージバブル用のデコレーション（手紙風）
  static BoxDecoration letterBubble({
    required Color accentColor,
  }) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      border: Border(
        left: BorderSide(color: accentColor, width: 3),
        top: BorderSide(color: AppColors.cardBorder, width: 1),
        right: BorderSide(color: AppColors.cardBorder, width: 1),
        bottom: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.textMuted.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }

  /// セクション区切り線（インク風）
  static Widget inkDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBorder.withOpacity(0),
            AppColors.cardBorder,
            AppColors.cardBorder,
            AppColors.cardBorder.withOpacity(0),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/constrained_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      title: 'プライバシーポリシー',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'プライバシーポリシー',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '最終更新日: 2026年1月31日',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),

          Text(
            '三賢会議（以下「本アプリ」）は、ユーザーの皆様のプライバシーを尊重し、個人情報の保護に努めています。',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '1. 収集する情報',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '【ユーザーが提供する情報】\n'
            '• 審議テーマ・相談内容\n'
            '• 審議履歴データ\n'
            '• アカウント情報（オプション）\n\n'
            '【自動的に収集される情報】\n'
            '• デバイス情報（機種、OSバージョン）\n'
            '• アプリ使用状況（起動回数、機能使用状況）\n'
            '• 広告識別子（IDFA）\n'
            '• クラッシュレポート',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '2. 情報の使用目的',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• AI審議機能の提供\n'
            '• サービスの改善とバグ修正\n'
            '• パーソナライズド広告の配信\n'
            '• 利用統計の作成（匿名化データ）',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '3. 第三者サービスの利用',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '【OpenAI API】\n'
            '審議内容の処理に使用。個人を特定できる情報は送信されません。送信されたデータは30日後に削除されます。\n\n'
            '【Firebase (Google)】\n'
            '• Firebase Authentication: ユーザー認証\n'
            '• Firebase Analytics: 利用分析\n'
            '• Firebase Crashlytics: 安定性向上\n\n'
            '【Google AdMob】\n'
            'パーソナライズド広告の配信と効果測定に使用。\n'
            'iOS設定 > プライバシーとセキュリティ > トラッキング から制限可能。',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '4. データの保存と保護',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '【保存場所】\n'
            '• デバイス内（ローカルストレージ）\n'
            '• Firebase（クラウド、ログイン時）\n\n'
            '【セキュリティ対策】\n'
            '• HTTPS通信による暗号化\n'
            '• Firebase認証による保護\n\n'
            '【保持期間】\n'
            '• 審議履歴: ユーザーが削除するまで\n'
            '• クラッシュレポート: 90日間\n'
            '• 分析データ: 14ヶ月間\n'
            '• OpenAI処理データ: 30日間',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '5. ユーザーの権利',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• アクセス権: 保存データの閲覧\n'
            '• 修正権: 不正確なデータの修正\n'
            '• 削除権: アプリ内またはサポートから削除可能\n'
            '• トラッキング拒否権: iOS設定から制限可能',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '6. 子供のプライバシー',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '本アプリは13歳未満の子供を対象としていません。13歳未満の子供から意図的に個人情報を収集することはありません。',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 16),

          Text(
            '7. お問い合わせ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'プライバシーに関するご質問やデータ削除のご要望は、以下までご連絡ください。\n\n'
            'Email: marumi.works@gmail.com\n\n'
            '詳細なプライバシーポリシーは以下でご覧いただけます:\n'
            'https://marumi-works.com/triad-council/privacy/',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

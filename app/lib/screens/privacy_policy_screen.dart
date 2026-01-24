import 'package:flutter/material.dart';

import '../widgets/constrained_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      title: 'プライバシーポリシー',
      body: ListView(
        children: const [
          Text(
            '三賢会議は、相談内容を分析するためにOpenAIのAPIを使用します。\n'
            '入力された相談内容は意思決定支援のためにサーバーへ送信されます。\n\n'
            '収集する情報:\n'
            '- 相談内容\n'
            '- 相談履歴（匿名IDに紐づく）\n\n'
            'ユーザーは設定画面からアカウント削除を実行できます。削除後は履歴が破棄されます。',
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}

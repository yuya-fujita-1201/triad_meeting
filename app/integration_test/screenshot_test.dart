import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/models/consultation.dart';
import 'package:app/providers/providers.dart';
import 'package:app/screens/deliberation_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/resolution_screen.dart';
import 'package:app/screens/round_detail_screen.dart';
import 'package:app/services/local_storage_service.dart';
import 'package:app/services/purchase_service.dart';
import 'package:app/services/analytics_service.dart';
import 'package:app/theme/app_theme.dart';

/// テスト用モックデータ
Consultation _mockConsultation() {
  return Consultation(
    consultationId: 'test-001',
    question: '転職すべきかどうか悩んでいます。今の仕事は安定していますが、やりがいを感じません。',
    rounds: [
      DeliberationRound(
        roundNumber: 1,
        messages: [
          AiMessage(
            ai: 'logic',
            message:
                '転職の判断には、現職の待遇と市場価値の比較が重要です。まず、現在の年収・福利厚生と、転職先で期待できる条件を数値で比較しましょう。また、業界の成長性や自身のスキルの市場価値も客観的に評価する必要があります。',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'heart',
            message:
                '「やりがいを感じない」という気持ちは大切なサインです。毎日の仕事に意味を見出せないことは、長期的に心身の健康に影響します。あなたが本当に大切にしたい価値観は何でしょうか？',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'flash',
            message:
                '安定とやりがいは二者択一ではありません。副業や社内異動、スキルアップ投資など、リスクを抑えながら変化を起こす方法もあります。まずは小さな一歩から始めてみてはいかがでしょうか。',
            timestamp: DateTime.now(),
          ),
        ],
      ),
      DeliberationRound(
        roundNumber: 2,
        messages: [
          AiMessage(
            ai: 'logic',
            message:
                '直感の提案は合理的です。リスク分散の観点から、まず副業や学習で新しい分野を試し、確信が得られてから本格的に転職活動を始めるのが戦略的です。',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'heart',
            message:
                '小さな一歩を踏み出すことで、自分の本当の気持ちが見えてきます。行動することで「やりたいこと」が明確になることも多いのです。',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'flash',
            message:
                '3ヶ月という期限を設けて、週末に興味のある分野を探索してみましょう。期限があることで決断が先延ばしになりません。',
            timestamp: DateTime.now(),
          ),
        ],
      ),
      DeliberationRound(
        roundNumber: 3,
        messages: [
          AiMessage(
            ai: 'logic',
            message:
                '3ヶ月の探索期間は妥当です。その間に市場調査と自己分析を並行して進めれば、データに基づいた判断が可能になります。',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'heart',
            message:
                '探索の過程自体が、あなたの人生を豊かにするはずです。結果だけでなく、その旅を楽しんでください。',
            timestamp: DateTime.now(),
          ),
          AiMessage(
            ai: 'flash',
            message:
                '行動あるのみです。考えすぎずに、まず一つ具体的なアクションを今週中に起こしましょう。',
            timestamp: DateTime.now(),
          ),
        ],
      ),
    ],
    resolution: Resolution(
      questionType: QuestionType.yesno,
      decision: 'すぐに転職するのではなく、3ヶ月間の探索期間を設けて段階的に行動することを推奨します。',
      votes: {
        'logic': 'pending',
        'heart': 'approve',
        'flash': 'approve',
      },
      reasoning: [
        '安定を維持しながら新しい可能性を探れる',
        'やりがいの欠如は長期的リスクであり対処が必要',
        '小さな行動から始めることでリスクを最小化できる',
      ],
      nextSteps: [
        '今週中に興味のある分野を3つリストアップ',
        '週末に1つの分野について調べる・体験する',
        '3ヶ月後に転職・異動・現職継続を判断',
      ],
      reviewDate: '2026年5月',
      risks: [
        '探索期間中にモチベーションが下がる可能性',
        '現職の状況が変化する可能性',
      ],
    ),
    createdAt: DateTime.now(),
  );
}

/// テスト用の薄いラッパーアプリ（Firebase不要）
Widget _testApp(Widget home) {
  final localStorage = _MockLocalStorageService();
  final purchaseService = PurchaseService();

  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(localStorage),
      purchaseServiceProvider.overrideWith((ref) => purchaseService),
      analyticsProvider.overrideWithValue(AnalyticsService.disabled()),
    ],
    child: MaterialApp(
      title: '三賢会議',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: home,
    ),
  );
}

/// 最小限のモック LocalStorageService
class _MockLocalStorageService extends LocalStorageService {
  final List<Consultation> _items = [];

  @override
  Future<void> init() async {}

  @override
  String getDeviceId() => 'test-device-id';

  @override
  List<Consultation> loadConsultations() => _items;

  @override
  Future<void> saveConsultation(Consultation consultation) async {
    _items.add(consultation);
  }

  @override
  Future<void> deleteConsultation(String id) async {
    _items.removeWhere((c) => c.consultationId == id);
  }

  @override
  int incrementConsultationCount() => 1;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final consultation = _mockConsultation();

  // ── screenshot_01: ホーム画面 ──
  testWidgets('screenshot_01: HomeScreen', (tester) async {
    await tester.pumpWidget(_testApp(const HomeScreen()));
    await tester.pumpAndSettle();
    // マーカーを出力
    debugPrint('📸 SCREEN_READY: screenshot_01');
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  // ── screenshot_02: 審議画面（結果表示後） ──
  // DeliberationScreen はAPIを呼ぶので、直接 ResolutionScreen を表示して
  // 「審議中」の雰囲気は別途作る。ここでは審議完了→決議画面直前の状態として
  // ResolutionScreen を使う。
  // 代わりに「審議中」風のスクショが欲しい場合は DeliberationScreen を
  // モックAPIで動かす必要がある。
  testWidgets('screenshot_02: ResolutionScreen (決議書)', (tester) async {
    await tester.pumpWidget(_testApp(
      ResolutionScreen(consultation: consultation),
    ));
    await tester.pumpAndSettle();
    debugPrint('📸 SCREEN_READY: screenshot_02');
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  // ── screenshot_03: ラウンド詳細画面 ──
  testWidgets('screenshot_03: RoundDetailScreen', (tester) async {
    await tester.pumpWidget(_testApp(
      RoundDetailScreen(consultation: consultation),
    ));
    await tester.pumpAndSettle();
    debugPrint('📸 SCREEN_READY: screenshot_03');
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  // ── screenshot_04: 履歴画面 ──
  testWidgets('screenshot_04: HistoryScreen', (tester) async {
    // 履歴に1件保存してから表示
    final localStorage = _MockLocalStorageService();
    await localStorage.saveConsultation(consultation);
    // 2件目も追加してリストを豊かに
    await localStorage.saveConsultation(Consultation(
      consultationId: 'test-002',
      question: '新しい趣味を始めたいのですが、何がおすすめですか？',
      rounds: consultation.rounds,
      resolution: Resolution(
        questionType: QuestionType.open,
        decision: 'まずは体験教室に参加して、自分に合うものを見つけましょう。',
        votes: {'logic': 'recommend', 'heart': 'strongly_recommend', 'flash': 'recommend'},
        reasoning: ['新しい経験は人生を豊かにする', '体験してみないとわからない'],
        nextSteps: ['体験教室を3つ予約する'],
        reviewDate: '2026年4月',
        risks: ['続かない可能性'],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ));

    final purchaseService = PurchaseService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(localStorage),
          purchaseServiceProvider.overrideWith((ref) => purchaseService),
          analyticsProvider.overrideWithValue(AnalyticsService.disabled()),
        ],
        child: MaterialApp(
          title: '三賢会議',
          theme: AppTheme.lightTheme(),
          debugShowCheckedModeBanner: false,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    debugPrint('📸 SCREEN_READY: screenshot_04');
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  // ── screenshot_05: ホーム画面（入力済み） ──
  testWidgets('screenshot_05: HomeScreen with input', (tester) async {
    await tester.pumpWidget(_testApp(const HomeScreen()));
    await tester.pumpAndSettle();

    // テキストフィールドにサンプルの質問を入力
    final textField = find.byType(TextField);
    if (textField.evaluate().isNotEmpty) {
      await tester.enterText(textField, '来月から海外赴任の話が出ています。家族と離れることへの不安がありますが、キャリアアップのチャンスでもあります。');
      await tester.pumpAndSettle();
      // キーボードを閉じる
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    debugPrint('📸 SCREEN_READY: screenshot_05');
    await Future<void>.delayed(const Duration(seconds: 2));
  });
}

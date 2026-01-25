import 'dart:convert';

/// 質問タイプ
enum QuestionType {
  yesno,   // 「〜すべきか？」賛成/反対で答えられる
  choice,  // 「AとBどちらがいい？」選択肢がある
  open;    // 「どうすればいい？」オープンな質問

  static QuestionType fromString(String? value) {
    switch (value) {
      case 'yesno':
        return QuestionType.yesno;
      case 'choice':
        return QuestionType.choice;
      case 'open':
      default:
        return QuestionType.open;
    }
  }

  String toJson() => name;
}

/// 選択肢（choice型の場合）
class VoteOptions {
  final String optionA;
  final String optionB;

  VoteOptions({
    required this.optionA,
    required this.optionB,
  });

  factory VoteOptions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return VoteOptions(optionA: '選択肢A', optionB: '選択肢B');
    }
    return VoteOptions(
      optionA: json['A'] as String? ?? '選択肢A',
      optionB: json['B'] as String? ?? '選択肢B',
    );
  }

  Map<String, dynamic> toJson() => {
    'A': optionA,
    'B': optionB,
  };
}

class Consultation {
  final String consultationId;
  final String question;
  final List<DeliberationRound> rounds;
  final Resolution resolution;
  final DateTime createdAt;

  Consultation({
    required this.consultationId,
    required this.question,
    required this.rounds,
    required this.resolution,
    required this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    final consultationIdRaw = json['consultationId'] ?? json['id'] ?? '';
    final consultationId = consultationIdRaw.toString();
    final resolutionJson = json['resolution'];
    return Consultation(
      consultationId: consultationId,
      question: json['question'] as String? ?? json['consultation'] as String? ?? '',
      rounds: (json['rounds'] as List<dynamic>? ?? [])
          .map((item) => DeliberationRound.fromJson(item as Map<String, dynamic>))
          .toList(),
      resolution: Resolution.fromJson(
        resolutionJson is Map<String, dynamic> ? resolutionJson : null,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consultationId': consultationId,
      'question': question,
      'rounds': rounds.map((round) => round.toJson()).toList(),
      'resolution': resolution.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toStorageString() => jsonEncode(toJson());

  factory Consultation.fromStorageString(String raw) {
    return Consultation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class DeliberationRound {
  final int roundNumber;
  final List<AiMessage> messages;

  DeliberationRound({
    required this.roundNumber,
    required this.messages,
  });

  factory DeliberationRound.fromJson(Map<String, dynamic> json) {
    return DeliberationRound(
      roundNumber: json['roundNumber'] is int
          ? json['roundNumber'] as int
          : int.tryParse(json['roundNumber']?.toString() ?? '') ?? 1,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((item) => AiMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

class AiMessage {
  final String ai;
  final String message;
  final DateTime timestamp;

  AiMessage({
    required this.ai,
    required this.message,
    required this.timestamp,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      ai: json['ai'] as String? ?? 'logic',
      message: json['message'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ai': ai,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Resolution {
  final QuestionType questionType;
  final VoteOptions? options;
  final String decision;
  final Map<String, String> votes;
  final List<String> reasoning;
  final List<String> nextSteps;
  final String reviewDate;
  final List<String> risks;

  Resolution({
    required this.questionType,
    this.options,
    required this.decision,
    required this.votes,
    required this.reasoning,
    required this.nextSteps,
    required this.reviewDate,
    required this.risks,
  });

  factory Resolution.empty() => Resolution(
        questionType: QuestionType.open,
        options: null,
        decision: '',
        votes: const {},
        reasoning: const [],
        nextSteps: const [],
        reviewDate: '',
        risks: const [],
      );

  factory Resolution.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Resolution.empty();
    }
    final votesRaw = json['votes'] as Map<String, dynamic>? ?? {};
    final questionType = QuestionType.fromString(json['questionType'] as String?);
    final optionsJson = json['options'] as Map<String, dynamic>?;
    
    return Resolution(
      questionType: questionType,
      options: questionType == QuestionType.choice 
          ? VoteOptions.fromJson(optionsJson)
          : null,
      decision: json['decision'] as String? ?? '',
      votes: votesRaw.map((key, value) => MapEntry(key, value.toString())),
      reasoning: (json['reasoning'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      nextSteps: (json['nextSteps'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      reviewDate: json['reviewDate'] as String? ?? '',
      risks: (json['risks'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionType': questionType.toJson(),
      if (options != null) 'options': options!.toJson(),
      'decision': decision,
      'votes': votes,
      'reasoning': reasoning,
      'nextSteps': nextSteps,
      'reviewDate': reviewDate,
      'risks': risks,
    };
  }

  /// 投票値を表示用テキストに変換
  String getVoteDisplayText(String vote) {
    switch (questionType) {
      case QuestionType.yesno:
        switch (vote) {
          case 'approve':
            return '賛成';
          case 'reject':
            return '反対';
          case 'pending':
          default:
            return '保留';
        }
      case QuestionType.choice:
        switch (vote) {
          case 'A':
            return options?.optionA ?? 'A';
          case 'B':
            return options?.optionB ?? 'B';
          case 'both':
            return 'どちらも';
          case 'depends':
          default:
            return '状況次第';
        }
      case QuestionType.open:
        switch (vote) {
          case 'strongly_recommend':
            return '強く推奨';
          case 'recommend':
            return '推奨';
          case 'conditional':
          default:
            return '条件付き';
        }
    }
  }
}

import 'dart:convert';

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
    return Consultation(
      consultationId: json['consultationId'] as String,
      question: json['question'] as String? ?? json['consultation'] as String? ?? '',
      rounds: (json['rounds'] as List<dynamic>? ?? [])
          .map((item) => DeliberationRound.fromJson(item as Map<String, dynamic>))
          .toList(),
      resolution: Resolution.fromJson(json['resolution'] as Map<String, dynamic>),
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
      roundNumber: json['roundNumber'] as int,
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
  final String decision;
  final Map<String, String> votes;
  final List<String> reasoning;
  final List<String> nextSteps;
  final String reviewDate;
  final List<String> risks;

  Resolution({
    required this.decision,
    required this.votes,
    required this.reasoning,
    required this.nextSteps,
    required this.reviewDate,
    required this.risks,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) {
    final votesRaw = json['votes'] as Map<String, dynamic>? ?? {};
    return Resolution(
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
      'decision': decision,
      'votes': votes,
      'reasoning': reasoning,
      'nextSteps': nextSteps,
      'reviewDate': reviewDate,
      'risks': risks,
    };
  }
}

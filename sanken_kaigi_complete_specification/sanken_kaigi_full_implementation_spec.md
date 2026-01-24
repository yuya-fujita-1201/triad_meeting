# Sanken Kaigi (Three Sages Council) - Complete Implementation Specification

**Version:** 2.0  
**Date:** January 20, 2026  
**Target Platform:** iOS & Android (Mobile App)  
**Tech Stack:** Flutter + Node.js/Python Backend + OpenAI API  

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Design](#2-architecture-design)
3. [Technology Stack](#3-technology-stack)
4. [Frontend Specification (Flutter)](#4-frontend-specification-flutter)
5. [Backend Specification (API & AI Processing)](#5-backend-specification-api--ai-processing)
6. [Database Schema](#6-database-schema)
7. [AI Processing Logic](#7-ai-processing-logic)
8. [Infrastructure & Deployment](#8-infrastructure--deployment)
9. [Development Workflow](#9-development-workflow)
10. [App Store Submission](#10-app-store-submission)

---

## 1. Project Overview

### 1.1 App Concept

**Sanken Kaigi (三賢会議)** is a decision-making assistance app that helps users resolve dilemmas through a three-AI consensus system. Each AI represents a different perspective:

- **Logic (ロジック)**: Rational, data-driven analysis
- **Heart (ハート)**: Emotional, relationship-focused perspective
- **Flash (フラッシュ)**: Intuitive, action-oriented approach

### 1.2 Core Features (MVP)

1. **Home Screen**: Input consultation topic, select AI personalities
2. **Deliberation Screen**: Display real-time AI discussion with debate rounds
3. **Resolution Card**: Final decision with voting results, reasoning, and action items
4. **History**: Save and review past consultations

### 1.3 User Flow

```
[Home Screen]
    ↓ User inputs question
[Deliberation Screen]
    ↓ AI discussion (3 rounds)
    ↓ - Round 1: Initial opinions
    ↓ - Round 2: Debate & counter-arguments
    ↓ - Round 3: Final consensus
[Resolution Card]
    ↓ Display decision, voting, risks, next steps
[History Screen]
    ↓ Save & review past decisions
```

---

## 2. Architecture Design

### 2.1 System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Mobile App (Flutter)                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │   Home   │  │Deliberate│  │Resolution│  │ History │ │
│  │  Screen  │  │  Screen  │  │   Card   │  │ Screen  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS/REST API
                          ↓
┌─────────────────────────────────────────────────────────┐
│              Backend API (Node.js/Python)                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  API Endpoints                                    │   │
│  │  - POST /api/v1/deliberate                       │   │
│  │  - GET  /api/v1/history                          │   │
│  │  - POST /api/v1/save-decision                    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ↓               ↓               ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   OpenAI API │  │   Firebase   │  │  PostgreSQL  │
│   (GPT-4)    │  │     Auth     │  │  (Optional)  │
└──────────────┘  └──────────────┘  └──────────────┘
```

### 2.2 Data Flow

1. **User Input** → Flutter App
2. **API Request** → Backend Server
3. **AI Processing** → OpenAI API (3 parallel calls for 3 AI personalities)
4. **Debate Logic** → Backend orchestrates multi-round discussion
5. **Resolution Generation** → Backend formats final decision card
6. **Response** → Flutter App displays results
7. **Save** → Database stores consultation history

---

## 3. Technology Stack

### 3.1 Frontend

| Component | Technology | Reason |
|:---|:---|:---|
| **Framework** | Flutter 3.16+ | Cross-platform (iOS/Android), native performance, beautiful UI |
| **State Management** | Riverpod 2.4+ | Type-safe, scalable, recommended by Flutter team |
| **HTTP Client** | Dio 5.4+ | Robust HTTP client with interceptors, error handling |
| **Local Storage** | Hive 2.2+ | Fast NoSQL database for offline storage |
| **UI Components** | Custom widgets | Match exact design specification |

### 3.2 Backend

| Component | Technology | Reason |
|:---|:---|:---|
| **Runtime** | Node.js 20+ (or Python 3.11+) | Fast, scalable, large ecosystem |
| **Framework** | Express 4.18+ (or FastAPI 0.109+) | Lightweight, easy to deploy |
| **AI Integration** | OpenAI API (GPT-4) | Best-in-class LLM for natural conversations |
| **Database** | Firebase Firestore (or PostgreSQL) | Real-time, scalable, easy Firebase integration |
| **Authentication** | Firebase Auth | Easy OAuth, email/password, future monetization |
| **Hosting** | Vercel / Railway / AWS Lambda | Serverless, auto-scaling, cost-effective |

### 3.3 Development Tools

| Tool | Purpose |
|:---|:---|
| **Git** | Version control |
| **GitHub Actions** | CI/CD pipeline |
| **Postman** | API testing |
| **Flutter DevTools** | Debugging & profiling |

---

## 4. Frontend Specification (Flutter)

### 4.1 Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   └── dimensions.dart
│   ├── utils/
│   │   └── validators.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── ai_personality.dart
│   │   ├── consultation.dart
│   │   └── resolution_card.dart
│   ├── repositories/
│   │   └── consultation_repository.dart
│   └── services/
│       ├── api_service.dart
│       └── local_storage_service.dart
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ai_card.dart
│   │   │       ├── input_field.dart
│   │   │       └── start_button.dart
│   │   ├── deliberation/
│   │   │   ├── deliberation_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ai_avatar.dart
│   │   │       ├── message_bubble.dart
│   │   │       └── progress_indicator.dart
│   │   ├── resolution/
│   │   │   ├── resolution_screen.dart
│   │   │   └── widgets/
│   │   │       └── resolution_card.dart
│   │   └── history/
│   │       ├── history_screen.dart
│   │       └── widgets/
│   │           └── history_item.dart
│   └── providers/
│       ├── consultation_provider.dart
│       └── history_provider.dart
└── routes/
    └── app_router.dart
```

### 4.2 Design System

#### 4.2.1 Color Palette

```dart
// lib/core/constants/colors.dart

class AppColors {
  // Background Gradient
  static const Color bgStart = Color(0xFFF5F3FF);
  static const Color bgEnd = Color(0xFFE8F4FF);
  
  // Card & Surface
  static const Color cardBg = Color(0xFFFFFFFF);
  
  // Text
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  // AI Personality Colors
  static const Color logic = Color(0xFF4A5FD9);      // Blue
  static const Color heart = Color(0xFFFF6B9D);      // Pink
  static const Color flash = Color(0xFFFFB800);      // Yellow
  
  // Button Gradient
  static const Color buttonStart = Color(0xFF8B7FFF);
  static const Color buttonEnd = Color(0xFF5B9FFF);
  
  // Borders & Shadows
  static const Color inputBorder = Color(0xFFCBD5E0);
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x4D8B7FFF),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
```

#### 4.2.2 Typography

```dart
// lib/core/constants/text_styles.dart

class AppTextStyles {
  static const String fontFamily = 'NotoSansJP';
  
  // App Title
  static const TextStyle appTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );
  
  // Tagline
  static const TextStyle tagline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // AI Name (Card Title)
  static const TextStyle aiName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // AI Subtitle
  static const TextStyle aiSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // Input Field
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
```

#### 4.2.3 Dimensions & Spacing

```dart
// lib/core/constants/dimensions.dart

class AppDimensions {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Icon Size
  static const double iconSize = 64.0;
  
  // Card Dimensions
  static const double cardMinHeight = 120.0;
  static const double cardPadding = 24.0;
  static const double cardBorderWidth = 4.0;
  
  // Input Field
  static const double inputMinHeight = 120.0;
  static const double inputPadding = 16.0;
  
  // Button
  static const double buttonHeight = 56.0;
  static const double buttonPadding = 16.0;
}
```

### 4.3 Screen Specifications

#### 4.3.1 Home Screen

**File:** `lib/presentation/screens/home/home_screen.dart`

**Layout:**
```
┌─────────────────────────────────────┐
│          三賢会議                    │
│   3つの視点で、迷いを終わらせる      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Logic Icon]                 │   │
│  │   ロジック                   │   │
│  │   論理的思考                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ [Heart Icon]│  │[Flash Icon] │  │
│  │   ハート    │  │  フラッシュ │  │
│  │  感情・共感 │  │  直感・行動 │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 相談内容（1〜2文でOK）       │   │
│  │ 例：転職するか迷っています   │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      会議を始める            │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Components:**

1. **AICard Widget** (`lib/presentation/screens/home/widgets/ai_card.dart`)

```dart
class AICard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String subtitle;
  final Color accentColor;
  final bool isFullWidth;

  const AICard({
    required this.iconPath,
    required this.name,
    required this.subtitle,
    required this.accentColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppColors.cardShadow,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon (SVG or PNG)
          SvgPicture.asset(
            iconPath,
            width: AppDimensions.iconSize,
            height: AppDimensions.iconSize,
          ),
          SizedBox(height: 12),
          // Name
          Text(name, style: AppTextStyles.aiName),
          SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.aiSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

2. **InputField Widget** (`lib/presentation/screens/home/widgets/input_field.dart`)

```dart
class ConsultationInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const ConsultationInputField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: AppDimensions.inputMinHeight,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.inputText.copyWith(
            color: Color(0xFFA0AEC0),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppDimensions.inputPadding),
        ),
      ),
    );
  }
}
```

3. **StartButton Widget** (`lib/presentation/screens/home/widgets/start_button.dart`)

```dart
class StartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const StartButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.buttonStart, AppColors.buttonEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: AppColors.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(text, style: AppTextStyles.buttonText),
          ),
        ),
      ),
    );
  }
}
```

#### 4.3.2 Deliberation Screen

**Purpose:** Display real-time AI discussion with animated message bubbles.

**Layout:**
```
┌─────────────────────────────────────┐
│  [← Back]       審議中...           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Logic Avatar]              │   │
│  │ まず、転職の理由を整理しま   │   │
│  │ しょう...                   │   │
│  └─────────────────────────────┘   │
│                                     │
│          ┌─────────────────────┐   │
│          │ [Heart Avatar]      │   │
│          │ あなたの気持ちは？  │   │
│          └─────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Flash Avatar]              │   │
│  │ 今すぐ行動すべきか？        │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Progress: Round 2/3]              │
└─────────────────────────────────────┘
```

**Key Features:**
- Animated message appearance (fade in + slide up)
- Avatar icons for each AI
- Progress indicator (Round 1/3, 2/3, 3/3)
- Auto-scroll to latest message

#### 4.3.3 Resolution Card Screen

**Purpose:** Display final decision in a structured card format.

**Card Structure:**
```
┌─────────────────────────────────────┐
│         決議書                       │
│                                     │
│  決議: 転職を推奨                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━       │
│                                     │
│  投票結果:                           │
│  ✓ ロジック: 賛成                   │
│  ✓ ハート: 賛成                     │
│  ✗ フラッシュ: 保留                 │
│                                     │
│  理由:                               │
│  - 現職での成長が限界               │
│  - 新しい環境での挑戦が必要         │
│  - ただし準備期間が必要             │
│                                     │
│  次の一手:                           │
│  1. 職務経歴書を更新する            │
│  2. 転職エージェントに登録          │
│  3. 1週間後に再評価                 │
│                                     │
│  再審期限: 2026年1月27日            │
│                                     │
│  [保存]  [シェア]                   │
└─────────────────────────────────────┘
```

---

## 5. Backend Specification (API & AI Processing)

### 5.1 API Endpoints

**Base URL:** `https://api.sankenkaigi.com/v1`

#### 5.1.1 POST /api/v1/deliberate

**Purpose:** Start AI deliberation process

**Request:**
```json
{
  "consultation": "転職するか迷っています",
  "userId": "user_12345" // Optional, for authenticated users
}
```

**Response:**
```json
{
  "consultationId": "consult_abc123",
  "rounds": [
    {
      "roundNumber": 1,
      "messages": [
        {
          "ai": "logic",
          "message": "まず、転職の理由を明確にしましょう。現職での不満点は何ですか？",
          "timestamp": "2026-01-20T10:30:00Z"
        },
        {
          "ai": "heart",
          "message": "あなたの気持ちを大切にしてください。本当に転職したいと感じていますか？",
          "timestamp": "2026-01-20T10:30:05Z"
        },
        {
          "ai": "flash",
          "message": "今すぐ行動すべきです。チャンスは待ってくれません。",
          "timestamp": "2026-01-20T10:30:10Z"
        }
      ]
    },
    {
      "roundNumber": 2,
      "messages": [...]
    },
    {
      "roundNumber": 3,
      "messages": [...]
    }
  ],
  "resolution": {
    "decision": "転職を推奨",
    "votes": {
      "logic": "approve",
      "heart": "approve",
      "flash": "pending"
    },
    "reasoning": [
      "現職での成長が限界に達している",
      "新しい環境での挑戦が必要",
      "ただし、準備期間を設けることを推奨"
    ],
    "nextSteps": [
      "職務経歴書を更新する",
      "転職エージェントに登録する",
      "1週間後に状況を再評価する"
    ],
    "reviewDate": "2026-01-27",
    "risks": [
      "収入が一時的に減少する可能性",
      "新しい環境への適応に時間がかかる"
    ]
  }
}
```

#### 5.1.2 GET /api/v1/history

**Purpose:** Retrieve consultation history

**Request:**
```
GET /api/v1/history?userId=user_12345&limit=10&offset=0
```

**Response:**
```json
{
  "consultations": [
    {
      "consultationId": "consult_abc123",
      "question": "転職するか迷っています",
      "decision": "転職を推奨",
      "createdAt": "2026-01-20T10:30:00Z"
    },
    ...
  ],
  "total": 25,
  "hasMore": true
}
```

#### 5.1.3 POST /api/v1/save-decision

**Purpose:** Save consultation result to database

**Request:**
```json
{
  "consultationId": "consult_abc123",
  "userId": "user_12345"
}
```

**Response:**
```json
{
  "success": true,
  "savedAt": "2026-01-20T10:35:00Z"
}
```

### 5.2 Backend Implementation (Node.js Example)

**File:** `server/index.js`

```javascript
const express = require('express');
const OpenAI = require('openai');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// AI Personality Prompts
const AI_PROMPTS = {
  logic: `You are "Logic", a rational AI focused on data-driven analysis.
Your role is to:
- Analyze facts and data objectively
- Identify pros and cons systematically
- Consider long-term consequences
- Provide logical reasoning

Respond in Japanese, keep answers concise (2-3 sentences).`,

  heart: `You are "Heart", an empathetic AI focused on emotions and relationships.
Your role is to:
- Consider emotional impact
- Think about relationships and people involved
- Prioritize mental well-being
- Provide compassionate advice

Respond in Japanese, keep answers concise (2-3 sentences).`,

  flash: `You are "Flash", an intuitive AI focused on action and speed.
Your role is to:
- Trust gut feelings and intuition
- Encourage bold action
- Focus on immediate next steps
- Provide decisive recommendations

Respond in Japanese, keep answers concise (2-3 sentences).`,
};

// POST /api/v1/deliberate
app.post('/api/v1/deliberate', async (req, res) => {
  try {
    const { consultation } = req.body;

    if (!consultation || consultation.trim().length === 0) {
      return res.status(400).json({ error: 'Consultation text is required' });
    }

    // Round 1: Initial opinions
    const round1 = await Promise.all([
      getAIResponse('logic', consultation, []),
      getAIResponse('heart', consultation, []),
      getAIResponse('flash', consultation, []),
    ]);

    // Round 2: Debate (each AI responds to others)
    const round2 = await Promise.all([
      getAIResponse('logic', consultation, round1),
      getAIResponse('heart', consultation, round1),
      getAIResponse('flash', consultation, round1),
    ]);

    // Round 3: Final consensus
    const round3 = await Promise.all([
      getAIResponse('logic', consultation, [...round1, ...round2]),
      getAIResponse('heart', consultation, [...round1, ...round2]),
      getAIResponse('flash', consultation, [...round1, ...round2]),
    ]);

    // Generate resolution
    const resolution = await generateResolution(
      consultation,
      [...round1, ...round2, ...round3]
    );

    res.json({
      consultationId: generateId(),
      rounds: [
        { roundNumber: 1, messages: round1 },
        { roundNumber: 2, messages: round2 },
        { roundNumber: 3, messages: round3 },
      ],
      resolution,
    });
  } catch (error) {
    console.error('Error in /deliberate:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Helper: Get AI response
async function getAIResponse(aiType, consultation, previousMessages) {
  const systemPrompt = AI_PROMPTS[aiType];
  
  const messages = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `相談内容: ${consultation}` },
  ];

  // Add previous round messages for context
  if (previousMessages.length > 0) {
    const context = previousMessages
      .map((msg) => `${msg.ai}: ${msg.message}`)
      .join('\n');
    messages.push({
      role: 'user',
      content: `他のAIの意見:\n${context}\n\nこれを踏まえて、あなたの意見を述べてください。`,
    });
  }

  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages,
    max_tokens: 150,
    temperature: 0.7,
  });

  return {
    ai: aiType,
    message: response.choices[0].message.content.trim(),
    timestamp: new Date().toISOString(),
  };
}

// Helper: Generate resolution card
async function generateResolution(consultation, allMessages) {
  const context = allMessages
    .map((msg) => `${msg.ai}: ${msg.message}`)
    .join('\n');

  const prompt = `以下の相談と3つのAIの議論を基に、決議書を作成してください。

相談内容: ${consultation}

議論:
${context}

以下のJSON形式で出力してください:
{
  "decision": "推奨する決定（1文）",
  "votes": {
    "logic": "approve/reject/pending",
    "heart": "approve/reject/pending",
    "flash": "approve/reject/pending"
  },
  "reasoning": ["理由1", "理由2", "理由3"],
  "nextSteps": ["ステップ1", "ステップ2", "ステップ3"],
  "risks": ["リスク1", "リスク2"],
  "reviewDate": "YYYY-MM-DD"
}`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 500,
    temperature: 0.5,
  });

  const resolutionText = response.choices[0].message.content.trim();
  
  // Parse JSON from response
  const jsonMatch = resolutionText.match(/\{[\s\S]*\}/);
  if (jsonMatch) {
    return JSON.parse(jsonMatch[0]);
  }

  throw new Error('Failed to parse resolution JSON');
}

// Helper: Generate unique ID
function generateId() {
  return `consult_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 6. Database Schema

### 6.1 Firestore Collections

#### Collection: `consultations`

```javascript
{
  "consultationId": "consult_abc123",
  "userId": "user_12345",
  "question": "転職するか迷っています",
  "rounds": [
    {
      "roundNumber": 1,
      "messages": [
        {
          "ai": "logic",
          "message": "...",
          "timestamp": "2026-01-20T10:30:00Z"
        },
        ...
      ]
    },
    ...
  ],
  "resolution": {
    "decision": "転職を推奨",
    "votes": {...},
    "reasoning": [...],
    "nextSteps": [...],
    "risks": [...],
    "reviewDate": "2026-01-27"
  },
  "createdAt": "2026-01-20T10:30:00Z",
  "updatedAt": "2026-01-20T10:35:00Z"
}
```

#### Collection: `users`

```javascript
{
  "userId": "user_12345",
  "email": "user@example.com",
  "displayName": "田中太郎",
  "createdAt": "2026-01-15T08:00:00Z",
  "subscription": {
    "plan": "free", // "free", "premium"
    "startDate": "2026-01-15T08:00:00Z",
    "endDate": null
  },
  "usage": {
    "consultationsThisMonth": 5,
    "totalConsultations": 12
  }
}
```

---

## 7. AI Processing Logic

### 7.1 Three-Round Deliberation System

**Round 1: Initial Opinions**
- Each AI provides independent analysis
- No knowledge of other AIs' opinions
- Focus on their core perspective (logic/heart/flash)

**Round 2: Debate & Counter-arguments**
- Each AI receives others' Round 1 opinions
- Respond with counter-arguments or agreements
- Identify conflicts and common ground

**Round 3: Final Consensus**
- Each AI receives all previous messages
- Provide final recommendation
- State vote (approve/reject/pending)

### 7.2 Resolution Generation Logic

**Decision Formula:**
- **Unanimous approval** → "強く推奨"
- **2/3 approval** → "推奨"
- **1/3 approval** → "条件付き推奨"
- **0/3 approval** → "推奨しない"

**Minority Opinion Handling:**
- Always include dissenting opinions in "risks" section
- Highlight conditions under which minority would approve

---

## 8. Infrastructure & Deployment

### 8.1 Backend Hosting

**Recommended:** Vercel (Node.js) or Railway (Python)

**Environment Variables:**
```
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://...
FIREBASE_PROJECT_ID=sanken-kaigi
FIREBASE_PRIVATE_KEY=...
```

**Deployment Steps:**
1. Push code to GitHub
2. Connect GitHub repo to Vercel/Railway
3. Set environment variables
4. Deploy automatically on push to `main` branch

### 8.2 Flutter App Build

**iOS Build:**
```bash
flutter build ios --release
```

**Android Build:**
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## 9. Development Workflow

### 9.1 Setup Instructions

**Backend:**
```bash
# Clone repository
git clone https://github.com/your-repo/sanken-kaigi-backend.git
cd sanken-kaigi-backend

# Install dependencies
npm install

# Set environment variables
cp .env.example .env
# Edit .env with your API keys

# Run development server
npm run dev
```

**Frontend:**
```bash
# Clone repository
git clone https://github.com/your-repo/sanken-kaigi-app.git
cd sanken-kaigi-app

# Install dependencies
flutter pub get

# Run on simulator
flutter run
```

### 9.2 Testing

**Backend API Testing:**
```bash
# Using curl
curl -X POST http://localhost:3000/api/v1/deliberate \
  -H "Content-Type: application/json" \
  -d '{"consultation": "転職するか迷っています"}'
```

**Flutter Widget Testing:**
```bash
flutter test
```

---

## 10. App Store Submission

### 10.1 iOS App Store

**Requirements:**
- Apple Developer Account ($99/year)
- App icon (1024x1024px)
- Screenshots (various iPhone sizes)
- Privacy policy URL
- App description (Japanese & English)

**Steps:**
1. Create app in App Store Connect
2. Upload build via Xcode or Transporter
3. Fill in app metadata
4. Submit for review (7-14 days)

### 10.2 Google Play Store

**Requirements:**
- Google Play Developer Account ($25 one-time)
- App icon (512x512px)
- Feature graphic (1024x500px)
- Screenshots (various Android sizes)
- Privacy policy URL
- App description (Japanese & English)

**Steps:**
1. Create app in Google Play Console
2. Upload APK/AAB
3. Fill in store listing
4. Submit for review (1-3 days)

---

## 11. Implementation Checklist

### Phase 1: MVP (Weeks 1-2)
- [ ] Backend API setup (Node.js/Python)
- [ ] OpenAI integration (3 AI personalities)
- [ ] Flutter project setup
- [ ] Home screen UI
- [ ] Deliberation screen UI
- [ ] Resolution card UI
- [ ] API integration in Flutter

### Phase 2: Core Features (Weeks 3-4)
- [ ] History screen
- [ ] Local storage (Hive)
- [ ] Error handling
- [ ] Loading states
- [ ] Animations

### Phase 3: Polish & Testing (Week 5)
- [ ] UI refinements
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] User testing

### Phase 4: Deployment (Week 6)
- [ ] Backend deployment (Vercel/Railway)
- [ ] iOS build & submission
- [ ] Android build & submission
- [ ] Marketing materials

---

## 12. Success Metrics

**MVP Success Criteria:**
- App launches without crashes
- User can input consultation and receive AI response
- Resolution card displays correctly
- History saves locally

**Post-Launch Metrics:**
- Daily Active Users (DAU)
- Average consultations per user
- Completion rate (users who finish deliberation)
- App Store rating (target: 4.5+)

---

## END OF SPECIFICATION

**Next Steps:**
1. Review this specification
2. Set up development environment
3. Begin Phase 1 implementation
4. Iterate based on user feedback

For questions or clarifications, contact the project lead.

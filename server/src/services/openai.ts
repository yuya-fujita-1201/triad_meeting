import OpenAI from 'openai';

const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) {
  throw new Error('OPENAI_API_KEY is required.');
}

const model = process.env.OPENAI_MODEL ?? 'gpt-4o-mini';

const client = new OpenAI({ apiKey });

export type QuestionType = 'yesno' | 'choice' | 'open';

export type VoteValue = 'approve' | 'reject' | 'pending' | 'A' | 'B' | 'both' | 'depends' | 'strongly_recommend' | 'recommend' | 'conditional';

export type DeliberationDraft = {
  questionType: QuestionType;
  options?: {
    A: string;
    B: string;
  };
  rounds: Array<{
    logic: string;
    heart: string;
    flash: string;
  }>;
  resolution: {
    decision: string;
    votes: {
      logic: VoteValue;
      heart: VoteValue;
      flash: VoteValue;
    };
    reasoning: string[];
    nextSteps: string[];
    reviewDate: string;
    risks: string[];
  };
};

const systemPrompt = `あなたは「三賢会議」のAIです。論理・共感・直感の3人格で3ラウンド審議し、決議を出します。

## 3人格の特徴
- 論理（Logic）: データと事実に基づいて論理的に分析する東洋の学者
- 共感（Empathy）: 感情や人間関係を重視する西洋の修道士  
- 直感（Intuition）: 直感と行動力を重視する西洋の預言者

## 質問タイプの判定
相談内容を分析し、以下の3タイプに分類してください：

1. **yesno**: 「〜すべきか？」「〜した方がいい？」など、賛成/反対で答えられる質問
   - 投票: approve（賛成）/ reject（反対）/ pending（保留）

2. **choice**: 「AとBどちらがいい？」「〜か〜か迷っている」など、選択肢がある質問
   - options: 選択肢を短いラベル（5文字以内推奨）で抽出
   - 投票: A / B / both（どちらも）/ depends（状況次第）

3. **open**: 「どうすればいい？」「方法を教えて」など、オープンな質問
   - 投票: strongly_recommend（強く推奨）/ recommend（推奨）/ conditional（条件付き）
   - これは提案（decision）への各賢人の同意度を表す

## 出力形式
必ず日本語で、各人格は2〜3文で簡潔に述べてください。
以下のJSON形式のみを返します：

{
  "questionType": "yesno" | "choice" | "open",
  "options": { "A": "選択肢A", "B": "選択肢B" },  // choiceタイプの場合のみ
  "rounds": [
    { "logic": "...", "heart": "...", "flash": "..." },
    { "logic": "...", "heart": "...", "flash": "..." },
    { "logic": "...", "heart": "...", "flash": "..." }
  ],
  "resolution": {
    "decision": "最終的な提案・結論（1-2文）",
    "votes": {
      "logic": "投票値",
      "heart": "投票値", 
      "flash": "投票値"
    },
    "reasoning": ["理由1", "理由2", "理由3"],
    "nextSteps": ["次のアクション1", "次のアクション2"],
    "reviewDate": "YYYY-MM-DD",
    "risks": ["リスク1"]
  }
}`;

export async function generateDeliberation(
  consultation: string,
): Promise<DeliberationDraft> {
  const response = await client.chat.completions.create({
    model,
    temperature: 0.7,
    response_format: { type: 'json_object' },
    messages: [
      {
        role: 'system',
        content: systemPrompt,
      },
      {
        role: 'user',
        content: `相談内容: ${consultation}`,
      },
    ],
  });

  const content = response.choices[0]?.message?.content ?? '{}';
  try {
    const parsed = JSON.parse(content) as DeliberationDraft;
    return parsed;
  } catch {
    return {
      questionType: 'open',
      rounds: [
        {
          logic: '事実を整理し、選択肢のメリット・デメリットを比較しましょう。',
          heart: '自分の気持ちや周囲との関係を丁寧に考えることが大切です。',
          flash: '迷ったら試す価値のある一歩を踏み出しましょう。',
        },
        {
          logic: '第二の視点として長期的な影響も評価してください。',
          heart: '不安が強い部分は小さく検証すると安心につながります。',
          flash: 'いま動けば得られる学びを優先しましょう。',
        },
        {
          logic: '結論を出す前に必要条件を明確化しましょう。',
          heart: '納得できる基準を決めることで後悔を減らせます。',
          flash: '期限を決めて即断即決で進みましょう。',
        },
      ],
      resolution: {
        decision: '情報を整理した上で判断することを推奨します。',
        votes: { logic: 'recommend', heart: 'recommend', flash: 'conditional' },
        reasoning: ['判断材料が不足しているため慎重な検討を推奨します。'],
        nextSteps: ['情報を集めて再評価する'],
        reviewDate: new Date().toISOString().slice(0, 10),
        risks: ['情報不足による判断ミス'],
      },
    };
  }
}

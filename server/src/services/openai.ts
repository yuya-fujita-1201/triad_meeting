import OpenAI from 'openai';

const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) {
  throw new Error('OPENAI_API_KEY is required.');
}

const model = process.env.OPENAI_MODEL ?? 'gpt-4o-mini';

const client = new OpenAI({ apiKey });

export type DeliberationDraft = {
  rounds: Array<{
    logic: string;
    heart: string;
    flash: string;
  }>;
  resolution: {
    votes: {
      logic: 'approve' | 'reject' | 'pending';
      heart: 'approve' | 'reject' | 'pending';
      flash: 'approve' | 'reject' | 'pending';
    };
    reasoning: string[];
    nextSteps: string[];
    reviewDate: string;
    risks: string[];
  };
};

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
        content:
          'あなたは三賢会議のAIです。ロジック・ハート・フラッシュの3人格で3ラウンド審議し、決議を出します。' +
          '必ず日本語で、各人格は2〜3文で簡潔に述べてください。' +
          '以下のJSON形式のみを返します。' +
          '{"rounds":[{"logic":"...","heart":"...","flash":"..."},{"logic":"...","heart":"...","flash":"..."},{"logic":"...","heart":"...","flash":"..."}],"resolution":{"votes":{"logic":"approve|reject|pending","heart":"approve|reject|pending","flash":"approve|reject|pending"},"reasoning":["..."],"nextSteps":["..."],"reviewDate":"YYYY-MM-DD","risks":["..."]}}',
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
        votes: { logic: 'pending', heart: 'pending', flash: 'pending' },
        reasoning: ['判断材料が不足しているため保留とします。'],
        nextSteps: ['情報を集めて再評価する'],
        reviewDate: new Date().toISOString().slice(0, 10),
        risks: ['情報不足による判断ミス'],
      },
    };
  }
}

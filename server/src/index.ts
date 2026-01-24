import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import { randomUUID } from 'crypto';
import { z } from 'zod';
import winston from 'winston';

import { verifyFirebaseToken, AuthenticatedRequest } from './middleware/auth';
import { firestore, admin } from './services/firebase';
import { generateDeliberation } from './services/openai';
import { checkAndIncrementDailyUsage, DailyLimitError } from './services/usage';
import { getJstResetAt } from './utils/time';

const app = express();

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
  ),
  transports: [new winston.transports.Console()],
});

app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

const router = express.Router();
router.use(verifyFirebaseToken);

const deliberateSchema = z.object({
  consultation: z.string().min(1).max(500),
  userId: z.string().optional(),
  plan: z.string().optional(),
});

router.post('/deliberate', async (req: AuthenticatedRequest, res) => {
  try {
    const body = deliberateSchema.parse(req.body);
    const userId = req.userId ?? body.userId;
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    try {
      await checkAndIncrementDailyUsage(userId);
    } catch (error) {
      if (error instanceof DailyLimitError) {
        return res.status(429).json({
          error: {
            code: 'DAILY_LIMIT_EXCEEDED',
            message: '本日の無料相談回数（10回）を超えました。',
            resetAt: error.resetAt,
          },
        });
      }
      throw error;
    }

    const draft = await generateDeliberation(body.consultation);
    type DraftRound = (typeof draft.rounds)[number];
    const safeRounds = Array.isArray(draft.rounds) ? draft.rounds : [];
    const safeResolution: Partial<typeof draft.resolution> = draft.resolution ?? {};

    const fallbackMessages = {
      logic: '事実と選択肢を整理し、判断材料を比較しましょう。',
      heart: '自分の気持ちと周囲の影響を丁寧に見つめましょう。',
      flash: '迷ったら試せる小さな一歩を先に踏み出しましょう。',
    };

    const baseTime = Date.now();
    const rounds = Array.from({ length: 3 }).map((_, roundIndex) => {
      const round = (safeRounds[roundIndex] ?? {}) as Partial<DraftRound>;
      const logic =
        typeof round.logic === 'string' && round.logic.trim().length > 0
          ? round.logic
          : fallbackMessages.logic;
      const heart =
        typeof round.heart === 'string' && round.heart.trim().length > 0
          ? round.heart
          : fallbackMessages.heart;
      const flash =
        typeof round.flash === 'string' && round.flash.trim().length > 0
          ? round.flash
          : fallbackMessages.flash;
      return {
        roundNumber: roundIndex + 1,
        messages: [
          {
            ai: 'logic',
            message: logic,
            timestamp: new Date(baseTime + roundIndex * 3000 + 0).toISOString(),
          },
          {
            ai: 'heart',
            message: heart,
            timestamp: new Date(baseTime + roundIndex * 3000 + 1000).toISOString(),
          },
          {
            ai: 'flash',
            message: flash,
            timestamp: new Date(baseTime + roundIndex * 3000 + 2000).toISOString(),
          },
        ],
      };
    });

    const sanitizeVote = (vote: string | undefined) =>
      vote === 'approve' || vote === 'reject' || vote === 'pending'
        ? vote
        : 'pending';
    const votesRaw =
      typeof safeResolution.votes === 'object' && safeResolution.votes
        ? (safeResolution.votes as Partial<typeof draft.resolution.votes>)
        : {};
    const votes = {
      logic: sanitizeVote(votesRaw.logic),
      heart: sanitizeVote(votesRaw.heart),
      flash: sanitizeVote(votesRaw.flash),
    };
    const approveCount = Object.values(votes).filter(
      (vote) => vote === 'approve',
    ).length;
    const decision =
      approveCount === 3
        ? '強く推奨'
        : approveCount === 2
            ? '推奨'
            : approveCount === 1
                ? '条件付き推奨'
                : '推奨しない';

    const reviewDate = /^\\d{4}-\\d{2}-\\d{2}$/.test(
      safeResolution.reviewDate ?? '',
    )
      ? safeResolution.reviewDate
      : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
          .toISOString()
          .slice(0, 10);

    const resolution = {
      decision,
      votes,
      reasoning: Array.isArray(safeResolution.reasoning)
        ? safeResolution.reasoning
        : [],
      nextSteps: Array.isArray(safeResolution.nextSteps)
        ? safeResolution.nextSteps
        : [],
      reviewDate,
      risks: Array.isArray(safeResolution.risks) ? safeResolution.risks : [],
    };

    const consultationId = randomUUID();
    const createdAt = new Date().toISOString();

    const doc = {
      consultationId,
      question: body.consultation,
      rounds,
      resolution,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await firestore
      .collection('users')
      .doc(userId)
      .collection('consultations')
      .doc(consultationId)
      .set(doc, { merge: true });

    return res.json({
      consultationId,
      rounds,
      resolution,
      createdAt,
    });
  } catch (error) {
    logger.error('deliberate_failed', { error });
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.flatten() });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/history', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId ?? (req.query.userId as string | undefined);
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    const rawLimit = Number(req.query.limit ?? 10);
    const rawOffset = Number(req.query.offset ?? 0);
    const limit = Math.min(
      Math.max(Number.isFinite(rawLimit) ? rawLimit : 10, 1),
      50,
    );
    const offset = Math.max(Number.isFinite(rawOffset) ? rawOffset : 0, 0);

    const snapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('consultations')
      .orderBy('createdAt', 'desc')
      .offset(offset)
      .limit(limit)
      .get();

    const items = snapshot.docs.map((doc) => {
      const data = doc.data();
      const createdAt = data.createdAt?.toDate?.()?.toISOString?.() ?? null;
      return {
        consultationId: data.consultationId ?? doc.id,
        question: data.question ?? '',
        rounds: data.rounds ?? [],
        resolution: data.resolution ?? {},
        createdAt: createdAt ?? new Date().toISOString(),
      };
    });

    return res.json({ items });
  } catch (error) {
    logger.error('history_failed', { error });
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.post(
  '/consultations/:id/save',
  async (req: AuthenticatedRequest, res) => {
    try {
      const userId = req.userId ?? (req.body.userId as string | undefined);
      const sourceUserId = req.body.sourceUserId as string | undefined;
      const consultationId = req.params.id;

      if (!userId) {
        return res.status(400).json({ error: 'Missing userId' });
      }

      let payload = req.body.consultation as Record<string, unknown> | undefined;

      if (!payload && sourceUserId) {
        const sourceSnap = await firestore
          .collection('users')
          .doc(sourceUserId)
          .collection('consultations')
          .doc(consultationId)
          .get();
        payload = sourceSnap.data();
      }

      if (!payload) {
        return res.status(400).json({ error: 'Missing consultation data' });
      }

      payload.consultationId = consultationId;
      payload.createdAt = payload.createdAt ?? admin.firestore.FieldValue.serverTimestamp();

      await firestore
        .collection('users')
        .doc(userId)
        .collection('consultations')
        .doc(consultationId)
        .set(payload, { merge: true });

      return res.json({ saved: true });
    } catch (error) {
      logger.error('save_failed', { error });
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

router.get('/consultations/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId ?? (req.query.userId as string | undefined);
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    const snapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('consultations')
      .doc(req.params.id)
      .get();

    if (!snapshot.exists) {
      return res.status(404).json({ error: 'Not found' });
    }

    const data = snapshot.data() ?? {};
    const createdAt = data.createdAt?.toDate?.()?.toISOString?.() ?? null;

    return res.json({
      ...data,
      consultationId: data.consultationId ?? snapshot.id,
      createdAt: createdAt ?? new Date().toISOString(),
    });
  } catch (error) {
    logger.error('consultation_get_failed', { error });
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.delete('/consultations/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId ?? (req.query.userId as string | undefined);
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    await firestore
      .collection('users')
      .doc(userId)
      .collection('consultations')
      .doc(req.params.id)
      .delete();

    return res.json({ deleted: true });
  } catch (error) {
    logger.error('consultation_delete_failed', { error });
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.use('/v1', router);

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  logger.info('server_started', { port, resetAt: getJstResetAt() });
});

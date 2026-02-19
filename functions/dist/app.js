"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
require("dotenv/config");
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const crypto_1 = require("crypto");
const zod_1 = require("zod");
const winston_1 = __importDefault(require("winston"));
const auth_1 = require("./middleware/auth");
const firebase_1 = require("./services/firebase");
const openai_1 = require("./services/openai");
const usage_1 = require("./services/usage");
const app = (0, express_1.default)();
exports.app = app;
const logger = winston_1.default.createLogger({
    level: 'info',
    format: winston_1.default.format.combine(winston_1.default.format.timestamp(), winston_1.default.format.json()),
    transports: [new winston_1.default.transports.Console()],
});
app.use((0, cors_1.default)());
app.use(express_1.default.json({ limit: '2mb' }));
app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
});
const router = express_1.default.Router();
router.use(auth_1.verifyFirebaseToken);
const deliberateSchema = zod_1.z.object({
    consultation: zod_1.z.string().min(1).max(500),
    userId: zod_1.z.string().optional(),
    plan: zod_1.z.string().optional(),
});
// 有効な投票値のセット
const validVotes = [
    'approve', 'reject', 'pending', // yesno型
    'A', 'B', 'both', 'depends', // choice型
    'strongly_recommend', 'recommend', 'conditional', // open型
];
// 質問タイプに応じたデフォルト投票値
const defaultVoteForType = (questionType) => {
    switch (questionType) {
        case 'yesno':
            return 'pending';
        case 'choice':
            return 'depends';
        case 'open':
        default:
            return 'recommend';
    }
};
// 投票値のサニタイズ
const sanitizeVote = (vote, questionType) => {
    if (vote && validVotes.includes(vote)) {
        return vote;
    }
    return defaultVoteForType(questionType);
};
router.post('/deliberate', async (req, res) => {
    try {
        const body = deliberateSchema.parse(req.body);
        const userId = req.userId ?? body.userId;
        logger.info('deliberate_request', { userId, bodyUserId: body.userId, reqUserId: req.userId });
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        try {
            await (0, usage_1.checkAndIncrementDailyUsage)(userId);
        }
        catch (error) {
            if (error instanceof usage_1.DailyLimitError) {
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
        const draft = await (0, openai_1.generateDeliberation)(body.consultation);
        const safeRounds = Array.isArray(draft.rounds) ? draft.rounds : [];
        const safeResolution = draft.resolution ?? {};
        // 質問タイプの取得（デフォルトはopen）
        const questionType = draft.questionType === 'yesno' || draft.questionType === 'choice' || draft.questionType === 'open'
            ? draft.questionType
            : 'open';
        // 選択肢の取得（choice型の場合）
        const options = questionType === 'choice' && draft.options
            ? {
                A: typeof draft.options.A === 'string' ? draft.options.A : '選択肢A',
                B: typeof draft.options.B === 'string' ? draft.options.B : '選択肢B',
            }
            : undefined;
        const fallbackMessages = {
            logic: '事実と選択肢を整理し、判断材料を比較しましょう。',
            heart: '自分の気持ちと周囲の影響を丁寧に見つめましょう。',
            flash: '迷ったら試せる小さな一歩を先に踏み出しましょう。',
        };
        const baseTime = Date.now();
        const rounds = Array.from({ length: 3 }).map((_, roundIndex) => {
            const round = (safeRounds[roundIndex] ?? {});
            const logic = typeof round.logic === 'string' && round.logic.trim().length > 0
                ? round.logic
                : fallbackMessages.logic;
            const heart = typeof round.heart === 'string' && round.heart.trim().length > 0
                ? round.heart
                : fallbackMessages.heart;
            const flash = typeof round.flash === 'string' && round.flash.trim().length > 0
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
        const votesRaw = typeof safeResolution.votes === 'object' && safeResolution.votes
            ? safeResolution.votes
            : {};
        const votes = {
            logic: sanitizeVote(votesRaw.logic, questionType),
            heart: sanitizeVote(votesRaw.heart, questionType),
            flash: sanitizeVote(votesRaw.flash, questionType),
        };
        // 決議文（APIから取得、なければデフォルト生成）
        const decision = typeof safeResolution.decision === 'string' && safeResolution.decision.trim().length > 0
            ? safeResolution.decision
            : generateDefaultDecision(questionType, votes, options);
        const reviewDate = /^\d{4}-\d{2}-\d{2}$/.test(safeResolution.reviewDate ?? '')
            ? safeResolution.reviewDate
            : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
                .toISOString()
                .slice(0, 10);
        const resolution = {
            questionType,
            ...(options && { options }),
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
        const consultationId = (0, crypto_1.randomUUID)();
        const createdAt = new Date().toISOString();
        const doc = {
            consultationId,
            question: body.consultation,
            rounds,
            resolution,
            createdAt: firebase_1.admin.firestore.FieldValue.serverTimestamp(),
        };
        await firebase_1.firestore
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
    }
    catch (error) {
        logger.error('deliberate_failed', {
            message: error instanceof Error ? error.message : String(error),
            stack: error instanceof Error ? error.stack : undefined,
            error
        });
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({ error: error.flatten() });
        }
        return res.status(500).json({ error: 'Internal server error' });
    }
});
// デフォルトの決議文を生成
function generateDefaultDecision(questionType, votes, options) {
    const voteValues = Object.values(votes);
    switch (questionType) {
        case 'yesno': {
            const approveCount = voteValues.filter(v => v === 'approve').length;
            if (approveCount >= 2)
                return '実行することを推奨します。';
            if (approveCount === 1)
                return '条件付きで検討を推奨します。';
            return '現時点では推奨しません。';
        }
        case 'choice': {
            const aCount = voteValues.filter(v => v === 'A').length;
            const bCount = voteValues.filter(v => v === 'B').length;
            if (aCount > bCount)
                return `${options?.A ?? '選択肢A'}を推奨します。`;
            if (bCount > aCount)
                return `${options?.B ?? '選択肢B'}を推奨します。`;
            return '状況に応じて判断することを推奨します。';
        }
        case 'open':
        default: {
            const strongCount = voteValues.filter(v => v === 'strongly_recommend').length;
            if (strongCount >= 2)
                return '提案内容を強く推奨します。';
            return '提案内容の実行を推奨します。';
        }
    }
}
router.get('/history', async (req, res) => {
    try {
        const userId = req.userId ?? req.query.userId;
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        const rawLimit = Number(req.query.limit ?? 10);
        const rawOffset = Number(req.query.offset ?? 0);
        const limit = Math.min(Math.max(Number.isFinite(rawLimit) ? rawLimit : 10, 1), 50);
        const offset = Math.max(Number.isFinite(rawOffset) ? rawOffset : 0, 0);
        const snapshot = await firebase_1.firestore
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
    }
    catch (error) {
        logger.error('history_failed', { error });
        return res.status(500).json({ error: 'Internal server error' });
    }
});
router.post('/consultations/:id/save', async (req, res) => {
    try {
        const userId = req.userId ?? req.body.userId;
        const sourceUserId = req.body.sourceUserId;
        const consultationId = req.params.id;
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        let payload = req.body.consultation;
        if (!payload && sourceUserId) {
            const sourceSnap = await firebase_1.firestore
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
        payload.createdAt = payload.createdAt ?? firebase_1.admin.firestore.FieldValue.serverTimestamp();
        await firebase_1.firestore
            .collection('users')
            .doc(userId)
            .collection('consultations')
            .doc(consultationId)
            .set(payload, { merge: true });
        return res.json({ saved: true });
    }
    catch (error) {
        logger.error('save_failed', { error });
        return res.status(500).json({ error: 'Internal server error' });
    }
});
router.get('/consultations/:id', async (req, res) => {
    try {
        const userId = req.userId ?? req.query.userId;
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        const snapshot = await firebase_1.firestore
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
    }
    catch (error) {
        logger.error('consultation_get_failed', { error });
        return res.status(500).json({ error: 'Internal server error' });
    }
});
router.delete('/consultations/:id', async (req, res) => {
    try {
        const userId = req.userId ?? req.query.userId;
        if (!userId) {
            return res.status(400).json({ error: 'Missing userId' });
        }
        await firebase_1.firestore
            .collection('users')
            .doc(userId)
            .collection('consultations')
            .doc(req.params.id)
            .delete();
        return res.json({ deleted: true });
    }
    catch (error) {
        logger.error('consultation_delete_failed', { error });
        return res.status(500).json({ error: 'Internal server error' });
    }
});
app.use('/v1', router);
//# sourceMappingURL=app.js.map
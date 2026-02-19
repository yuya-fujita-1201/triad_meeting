"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DailyLimitError = void 0;
exports.checkAndIncrementDailyUsage = checkAndIncrementDailyUsage;
const firebase_1 = require("./firebase");
const time_1 = require("../utils/time");
const DAILY_LIMIT = 10;
class DailyLimitError extends Error {
    constructor(resetAt) {
        super('DAILY_LIMIT_EXCEEDED');
        this.resetAt = resetAt;
    }
}
exports.DailyLimitError = DailyLimitError;
async function checkAndIncrementDailyUsage(userId) {
    const dateKey = (0, time_1.getJstDateKey)();
    const resetAt = (0, time_1.getJstResetAt)();
    const usageRef = firebase_1.firestore
        .collection('users')
        .doc(userId)
        .collection('dailyUsage')
        .doc(dateKey);
    let updatedCount = 0;
    await firebase_1.firestore.runTransaction(async (tx) => {
        const snap = await tx.get(usageRef);
        const currentCount = snap.data()?.count ?? 0;
        if (currentCount >= DAILY_LIMIT) {
            throw new DailyLimitError(resetAt);
        }
        updatedCount = currentCount + 1;
        tx.set(usageRef, {
            count: updatedCount,
            updatedAt: firebase_1.admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
    });
    return updatedCount;
}
//# sourceMappingURL=usage.js.map
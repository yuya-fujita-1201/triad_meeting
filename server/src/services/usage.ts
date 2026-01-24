import { firestore, admin } from './firebase';
import { getJstDateKey, getJstResetAt } from '../utils/time';

const DAILY_LIMIT = 10;

export class DailyLimitError extends Error {
  constructor(public resetAt: string) {
    super('DAILY_LIMIT_EXCEEDED');
  }
}

export async function checkAndIncrementDailyUsage(userId: string): Promise<number> {
  const dateKey = getJstDateKey();
  const resetAt = getJstResetAt();
  const usageRef = firestore
    .collection('users')
    .doc(userId)
    .collection('dailyUsage')
    .doc(dateKey);

  let updatedCount = 0;

  await firestore.runTransaction(async (tx) => {
    const snap = await tx.get(usageRef);
    const currentCount = (snap.data()?.count as number | undefined) ?? 0;
    if (currentCount >= DAILY_LIMIT) {
      throw new DailyLimitError(resetAt);
    }
    updatedCount = currentCount + 1;
    tx.set(
      usageRef,
      {
        count: updatedCount,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

  return updatedCount;
}

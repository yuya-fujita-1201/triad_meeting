import { NextFunction, Request, Response } from 'express';

import { admin } from '../services/firebase';

export interface AuthenticatedRequest extends Request {
  userId?: string;
}

export async function verifyFirebaseToken(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    const token = header.replace('Bearer ', '');
    const decoded = await admin.auth().verifyIdToken(token);
    req.userId = decoded.uid;
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
}

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
      // For development: allow requests without auth token
      // Don't set req.userId here - let the route handler use body.userId
      return next();
    }
    const token = header.replace('Bearer ', '');
    const decoded = await admin.auth().verifyIdToken(token);
    req.userId = decoded.uid;
    return next();
  } catch (error) {
    // For development: allow requests even if token verification fails
    // Don't set req.userId here - let the route handler use body.userId
    return next();
  }
}

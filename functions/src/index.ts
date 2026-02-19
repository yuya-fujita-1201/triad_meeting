import * as functions from 'firebase-functions';
import { app } from './app';

// Cloud Functions用にexpressアプリをエクスポート
export const api = functions.https.onRequest(app);

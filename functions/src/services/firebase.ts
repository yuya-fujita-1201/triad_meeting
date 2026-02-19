import admin from 'firebase-admin';

// Cloud Functions環境では自動的に認証情報が提供される
if (!admin.apps.length) {
  admin.initializeApp();
}

export const firestore = admin.firestore();
export { admin };

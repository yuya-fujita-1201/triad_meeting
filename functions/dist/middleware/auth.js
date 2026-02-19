"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyFirebaseToken = verifyFirebaseToken;
const firebase_1 = require("../services/firebase");
async function verifyFirebaseToken(req, res, next) {
    try {
        const header = req.headers.authorization;
        if (!header || !header.startsWith('Bearer ')) {
            // For development: allow requests without auth token
            // Don't set req.userId here - let the route handler use body.userId
            return next();
        }
        const token = header.replace('Bearer ', '');
        const decoded = await firebase_1.admin.auth().verifyIdToken(token);
        req.userId = decoded.uid;
        return next();
    }
    catch (error) {
        // For development: allow requests even if token verification fails
        // Don't set req.userId here - let the route handler use body.userId
        return next();
    }
}
//# sourceMappingURL=auth.js.map
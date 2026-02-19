"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.admin = exports.firestore = void 0;
const firebase_admin_1 = __importDefault(require("firebase-admin"));
exports.admin = firebase_admin_1.default;
// Cloud Functions環境では自動的に認証情報が提供される
if (!firebase_admin_1.default.apps.length) {
    firebase_admin_1.default.initializeApp();
}
exports.firestore = firebase_admin_1.default.firestore();
//# sourceMappingURL=firebase.js.map
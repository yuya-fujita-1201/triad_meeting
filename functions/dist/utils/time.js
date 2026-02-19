"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getJstDateKey = getJstDateKey;
exports.getJstResetAt = getJstResetAt;
function getJstDateKey(date = new Date()) {
    const jst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
    const year = jst.getUTCFullYear();
    const month = String(jst.getUTCMonth() + 1).padStart(2, '0');
    const day = String(jst.getUTCDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}
function getJstResetAt(date = new Date()) {
    const dateKey = getJstDateKey(date);
    return `${dateKey}T24:00:00+09:00`;
}
//# sourceMappingURL=time.js.map
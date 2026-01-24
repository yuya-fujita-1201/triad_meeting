export function getJstDateKey(date = new Date()): string {
  const jst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const year = jst.getUTCFullYear();
  const month = String(jst.getUTCMonth() + 1).padStart(2, '0');
  const day = String(jst.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function getJstResetAt(date = new Date()): string {
  const dateKey = getJstDateKey(date);
  return `${dateKey}T24:00:00+09:00`;
}

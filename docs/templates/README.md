# テンプレート README

このフォルダは「次のアプリ開発で迷わずAIに実装させる」ためのテンプレート一式です。  
**統合版指示書 + 実行指示（Prompt） + タスク一覧** の3点セットで運用することを前提にしています。

---

## 使い方（推奨フロー）

1. **統合版指示書を作る**  
   `SPEC_UNIFIED_TEMPLATE.md` をコピーして埋める  
   - **ファイル名は英語で作成**（例: `docs/MyApp - Unified Spec.md`）

2. **実行指示（Phase 1専用）を作る**  
   `PHASE1_EXECUTION_PROMPT_TEMPLATE.md` をコピーして、  
   実装対象ファイル名を指示する  
   - **ファイル名は英語で作成**（例: `docs/PHASE1_EXECUTION_PROMPT.md`）

3. **タスク一覧（Phase 1準拠）を作る**  
   `MVP_TASK_LIST_TEMPLATE.md` をコピーして整理する  
   - **ファイル名は英語で作成**（例: `docs/MyApp - MVP Task List (Phase1).md`）
   - 仕様と矛盾がある場合は **統合版指示書が最優先**

---

## ファイル構成（例）

```
docs/
  MyApp - Unified Spec.md
  MyApp - MVP Task List (Phase1).md
  PHASE1_EXECUTION_PROMPT.md
```

---

## 重要ルール

- **Phase 1 / Phase 2 を必ず分離**する  
  （課金・広告・審査要件など「詰まりやすい要素」はPhase 2へ）
- 実装者には **PHASE1_EXECUTION_PROMPT** を必ず添える  
  （Phase 2を勝手に作らせないため）
- **未決定事項は統合版指示書の最後に明記**しておく  

---

## テンプレート一覧

- `SPEC_UNIFIED_TEMPLATE.md`  
  統合版の実装指示書テンプレート

- `PHASE1_EXECUTION_PROMPT_TEMPLATE.md`  
  Codex / Claude Code への実行指示テンプレート

- `MVP_TASK_LIST_TEMPLATE.md`  
  Phase 1準拠のタスク一覧テンプレート

- `TIPS.md`  
  開発中に学んだTipsの蓄積用

- `CHECKLIST.md`  
  毎回使うチェックリストの蓄積用

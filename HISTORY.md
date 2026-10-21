# 作業履歴

このファイルは、日ごとの作業状況を時次進捗形式で記録するためのものです。

## 2026-10-22

### 2時進捗
- PHP・Node.jsの監査後、ユーザーからLocal by Flywheelの修正版PHPは未提供なので、それ以外を修正する指示を受けた。静的版は `origin/main` の専用worktree・`codex/fix-node-runtime-security` で共通の制作ツールだけを修正した。WordPress版のHTML・SCSS・JS・画像は持ち込んでいない。
- `tools/node-runtime.ps1` を追加し、Windows標準のNode.jsまたは `HIDAMARI_NODE_PATH` の絶対パスを使用する。安定版24系の `24.22.1` 以上を確認・表示し、未導入・未修正版・要件外の版とCodex同梱パスは停止する。Sass・PostCSS・静的検査のPATH依存と同梱版への自動切り替えを除去した。
- `tools/run-pnpm.ps1` を追加し、Git管理外 `.build-tools/` に導入した `package.json` 指定版のpnpmを、確認済みNode.jsから直接実行する。子プロセスのPATHにも同じNode.jsを先頭に設定し、pnpmの版不一致は起動前に停止する。指定版 `11.7.0` と依存関係のlockfileは維持し、Node.js要件を `package.json` に記載した。
- READMEとAGENTS.mdへ初回準備、修正済みNode.jsの確認、pnpmラッパー経由のコマンドを記載した。最低版は今回のセキュリティ修正の基準であり、更新時の公式告知の再確認が必要と明記した。
- `tools/test-node-runtime.ps1` の13項目が成功。実Node.js `24.22.1`、新しい24系パッチの受け入れ、未修正版・別系列・RC・未導入・相対パス・同梱パス・PATHへの誘導・pnpm版不一致を確認した。異常系はバッチファイルの代役で検証し、古いNode.js本体は起動していない。
- `./tools/run-pnpm.ps1 run check:site` は9 HTMLと共通JSの検査に合格。`./tools/run-pnpm.ps1 run build:css` も成功し、静的ソース・生成CSS・lockfileに差分がないことを確認した。見た目の変更がないため、追加のブラウザー表示確認は実施していない。
- `main` と `static-v1.0` は変更せず、修正ブランチをPRとして提出する。マージとPages公開は明示的な指示を受けて実施する。前回履歴は内容一致を確認し `History-archive/HISTORY-261011.md` へアーカイブした。

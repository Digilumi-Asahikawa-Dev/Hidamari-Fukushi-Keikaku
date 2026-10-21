# 作業履歴

このファイルは、日ごとの作業状況を時次進捗形式で記録するためのものです。

## 2026-10-22

### 2時進捗
- PHP・Node.jsの脆弱性対応について、GitHub側で修正が必要な箇所を調査した。コード修正は実施していない。作業開始時のブランチは `feature/wordpress`、既存の未コミット `SITEMAP.md` とGit管理外 `handoff/` は保持した。
- `git pull --ff-only` は初回サンドボックス内で `.git/FETCH_HEAD` の書き込み権限エラーとなり、承認された権限で再実行して成功した。`feature/wordpress` は `origin/feature/wordpress` と一致（`f747bbc`）、`origin/main` は `ded2b79`。GitHub連携から現行ファイルの内容も確認した。
- Node.jsの修正対象: `tools/run-sass.ps1:14` と `tools/run-postcss.ps1:14` はPATH上のNode.jsを無検証で使い、見つからない場合は古い同梱版へ自動で切り替える。同じ実装が `main` と `feature/wordpress` に存在する。`tools/check-site.ps1:15` もPATH依存。検証済みの修正済みNode.jsを選び、パス・版を確認し、利用できない場合は停止する方針への変更を推奨する。修正時は各管理元へ個別に反映する。
- PHPの修正対象: `tools/local-wpvivid-restore-check.ps1:37` はLocalのPHP `8.2.29` を直接指定し、同スクリプトはPHPの組み込みHTTPサーバーも起動する。修正済みPHPと対応する設定を選択・検証できる実装への変更を推奨する。単にパスを存在未確認の版へ置換しただけでは対策完了とはしない。
- 文書の修正候補: `README.md` とリポジトリの `AGENTS.md` にNode.jsの修正版・起動経路とpnpmの安全な起動手順を記載する。`package.json` には `pnpm@11.7.0` の指定があるがNode.js要件はない。`wordpress/README.md`、`project-docs/wordpress/HANDOFF.md`、`PRODUCTION_RUNBOOK.md` にはPHP更新・再検証の条件を追記する。過去のPHP `8.2.29` の検証記録は事実として保持し、新版で検証済みとは書き換えない。
- `C:/Program Files/nodejs/node.exe --version` が `v24.22.1` を返ることを再確認した。古い同梱Node.js、未修正PHP、ビルド・復元処理は起動していない。今回の監査では依存パッケージの脆弱性監査、Localでの新版PHP検証、本番サーバーの調査は実施していない。
- 公式の2026-10-21告知でNode.js 24系の修正版 `24.22.1`、PHPの修正版 `8.2.35` / `8.3.36` / `8.4.27` / `8.5.12` を再確認した。PHP本体の問題はテーマのコード修正だけでは解消しない。GitHub上にランタイム本体・独自の `.github` ワークフローはなく、公開静的HTML/CSS/ブラウザーJSに今回のランタイム対策を直接施す必要は見当たらない。
- 参考: Node.js公式告知 https://nodejs.org/en/blog/vulnerability/october-2026-security-releases 、PHP公式告知 https://www.php.net/archive/2026.php#2026-10-21-5 。別案件 `Digilumi-Asahikawa-Dev/Digilumi_HP_renewal` の `main` に `docs/runtime-security-policy.md` が存在し、導入・公開時に修正済みのサポート対象版を確認する方針が記録済みであることをGitHub連携で確認した。同案件のコード全体を再監査したものではない。
- 前回の2026-10-11分は `History-archive/HISTORY-261011.md` へ内容一致を確認してアーカイブした。今回の変更は調査履歴とアーカイブのみとする。
- 続いて、ユーザーからLocal by Flywheelの修正版PHPは未提供なのでそれ以外を修正する指示を受けた。PHPの更新・復元スクリプトの指定変更は保留し、WordPress側のREADME・HANDOFF・本番手順に提供待ちと新版での再検証条件を追記した。過去のPHP検証記録は保持した。
- `tools/node-runtime.ps1` を追加し、標準のWindows Node.jsまたは `HIDAMARI_NODE_PATH` に設定された絶対パスを検証する。安定版24系の `24.22.1` 以上を確認・表示し、未導入・未修正版・要件外の版とCodex同梱パスは停止する。Sass・PostCSS・静的検査を共通処理へ切り替えた。
- `tools/run-pnpm.ps1` を追加し、Git管理外 `.build-tools/` のpnpmが `package.json` 指定版と一致することを確認して、検証済みNode.jsからJavaScriptエントリーポイントを直接実行する。子プロセスにも同じNode.jsを優先させる。pnpm `11.7.0` と依存関係lockfileは維持し、Node.js要件を `package.json` に記載した。READMEとAGENTS.mdの初回準備・実行コマンドを同期した。
- 更新済みNode.js `24.22.1` と同じインストール先のnpmでpnpm `11.7.0` を `.build-tools/` へ取得した。初回はサンドボックスのDNS制限で失敗したため、承認された権限で再実行して成功した。グローバルnpmや同梱ランタイムは変更していない。
- `tools/test-node-runtime.ps1` の13項目が成功。実Node.jsと新しい24系パッチの受け入れ、未修正版・別系列・RC・未導入・相対パス・同梱パス・PATHへの誘導・pnpm版不一致を確認した。古いNode.js本体は使わず異常系はバッチの代役で検証した。6 PowerShellファイルの構文解析も成功した。
- 新ラッパー経由の `check:site` は9 HTMLと共通JSの検査に合格し、`build:css:wordpress` も成功した。pnpmの子プロセスが `C:/Program Files/nodejs/node.exe` / `v24.22.1` を使用すること、終了コード7が保持されることも確認した。WordPressテーマ・静的サイト・生成CSS・依存関係lockfile・PHP復元スクリプトに差分なし。見た目とPHP処理は変更せず、追加のブラウザー表示・PHP動作確認は実施していない。
- 静的版は `origin/main` 基点の専用worktree・`codex/fix-node-runtime-security` へ共通ツールと手順だけを個別反映した。13項目のテスト、9ページの静的検査、静的CSSビルドが成功し、サイトソース・生成CSS・lockfileに差分なし。共通6スクリプトがWordPress側と内容一致することも確認した。
- 静的版のコミット `3e03e68` をpushし、PR #2「Node.jsの修正版を使う制作コマンドへ変更」を作成した。URL: https://github.com/Digilumi-Asahikawa-Dev/Hidamari-Fukushi-Keikaku/pull/2 。GitHub連携の作成APIは403のため、ログイン済みChromeから作成・Open状態を確認し、このチャットへ添付した。mainへのマージとPages公開は実施していない。静的版worktreeはpush済み・未コミット変更なしを確認してアーカイブを依頼した。

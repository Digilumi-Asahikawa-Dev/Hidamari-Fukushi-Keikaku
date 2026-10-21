# 作業履歴

このファイルは、日ごとの作業状況を時次進捗形式で記録するためのものです。

## 2026-10-11

### 21時進捗
- Organization移行に伴う静的版PagesのURL修正を、`origin/main` を基点とする `codex/fix-pages-organization` ブランチと専用worktreeで実施した。
- Pages設定は `main` の `/docs`、カスタムドメイン未設定、HTTPS有効を確認済み。旧URLのトップと `about_us.html` はHTTP 404、新Organization URLの同2ページはHTTP 200だった。
- 全9ページの `canonical`、`og:url`、`og:image` を `https://digilumi-asahikawa-dev.github.io/Hidamari-Fukushi-Keikaku/` に更新した。READMEとレビュー資料の現在の公開先案内も更新した。本文、SCSS、CSS、JavaScript、画像、過去のROADMAP・アーカイブの記録は変更していない。
- Deploymentsの最新リンクは移行前デプロイの旧URLを参照している。mainへの修正反映後、新しいPagesデプロイの成功と最新リンクの更新を確認する。過去デプロイの履歴は保持する。
- main側の前回2026-08-05分の履歴を `History-archive/HISTORY-260805.md` にアーカイブし、当日分の履歴を作成した。WordPress版と既存の未コミット変更は別の作業場所で保持している。
- 既存の `pnpm run check:site` が成功し、全9ページと `js/main.js` の静的検査に合格した。
- Chromeプラグインと一時ローカルHTTPサーバーで全9ページを1600px・390pxの計18状態で確認し、横はみ出し0、h1各1件、共通ヘッダー・フッターの生成、全ページの新canonicalを確認した。PC側ではog:url・og:imageの新URLも確認した。
- トップのPC/SP表示を確認し、SPメニューの開閉・Escapeでの閉じ、FAQ展開が成功した。検証タブの警告・エラーログは0件だった。読み込み済み画像の欠落は検出しなかった。公開サイト全リソースのHTTP検査はmain反映後に行う。
- 全9ページのcanonical・og:urlのページ別一致、共通og:image、公開HTML内の旧ドメイン残存0件を確認した。修正をPRにまとめ、mainへのマージとPages公開は明示的な指示を受けて実施する。

# 作業履歴

このファイルは、日ごとの作業状況を時次進捗形式で記録するためのものです。

## 2026-10-11

### 21時進捗
- Organization移行後の `Digilumi-Asahikawa-Dev/Hidamari-Fukushi-Keikaku` への接続を確認した。作業開始時のブランチは `feature/wordpress`。既存の `SITEMAP.md` の変更とGit管理外 `handoff/` は保持した。
- 新URLに対する `git ls-remote` が成功し、`main`、`feature/wordpress`、`static-v1.0` を確認した。旧URLでの `git pull --ff-only` も成功した。
- ローカル `origin` のfetch/push URLをOrganizationの新URLへ更新し、新URLでの `git pull --ff-only` が `Already up to date.` と返ることを確認した。
- GitHub連携の接続ユーザーは `AoyamaATM`。OrganizationがGitHubアプリのインストール先に含まれ、リポジトリ情報の取得に成功した。リポジトリ情報の `permissions` は `pull`、`push`、`admin` などがtrueだった。
- 個別ユーザーの権限詳細APIはGitHub連携アプリの権限制約により403（`Resource not accessible by integration`）だった。リポジトリ情報取得とGit接続は成功しており、このAPIに限った制限として記録した。
- 前回の2026-08-25分の履歴を `History-archive/HISTORY-260825.md` へアーカイブし、本日分の履歴を作成した。
- Pages復旧手順のステップ1として、Chromeで移行先リポジトリのPages設定とDeploymentsを読み取り確認した。公開方式はブランチからデプロイ、公開元は `main` の `/docs`、カスタムドメインは未設定、HTTPSは有効だった。Pages設定は新Organization URLを公開中として表示している。
- GETリクエストで旧URLのトップと `about_us.html` はHTTP 404、新URLの同2ページはHTTP 200を確認した。旧URLから新URLへの転送は発生しなかった。
- 新URL `https://digilumi-asahikawa-dev.github.io/Hidamari-Fukushi-Keikaku/` をChromeで開き、サイト本文と共通ナビゲーションを確認した。公開中トップの `canonical`、`og:url`、`og:image` は旧 `aoyamaatm.github.io` を参照している。
- 直近のデプロイは2026-08-05 10:12 JSTの成功履歴（run 30965680165）で、Deploymentsのリンクは旧URLのままだった。旧履歴のリンクと現在のPages設定の公開URLを区別した。
- 404の発生範囲は旧URLで、新URLでは公開が継続している。ステップ2のPages設定復旧は不要と判断し、次はステップ3の静的版SEO・OGP情報と現在の公開案内のURL更新を行う。ステップ1ではPages設定とサイトコードは変更していない。全9ページ・画像・PC/SPの詳細検証は後続ステップで実施する。

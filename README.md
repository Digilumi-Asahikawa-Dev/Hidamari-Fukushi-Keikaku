# ひだまり福祉計画

静的サイトの制作リポジトリです。

## ソース構成

- `docs/*.html`: 各ページの本文構造
- `docs/js/main.js`: 共通ヘッダー／フッターとページ共通の操作
- `docs/scss/style.scss`: 全ページのスタイル元ファイル
- `docs/css/style.css`: HTMLが読み込む生成CSS
- `docs/img/`: 公開時に配信する画像
- `source-assets/images/`: WebP生成に使う非公開の画像原本
- `tools/`: CSS生成・静的検査・表示確認用スクリプト

## GitHub Pages公開構成

- 公開元：`main` ブランチの `/docs`
- 公開基準URL：[https://digilumi-asahikawa-dev.github.io/Hidamari-Fukushi-Keikaku/](https://digilumi-asahikawa-dev.github.io/Hidamari-Fukushi-Keikaku/)
- `docs/.nojekyll` により、Jekyllを介さず静的ファイルとして配信する

## プロジェクト資料

- [ROADMAP.md](ROADMAP.md)：工程、実施結果、進行状況
- [SITEMAP.md](SITEMAP.md)：ページ構成と導線
- [レビュー資料アーカイブ](project-docs/reviews/README.md)：完了済みレビューの資料と指摘記録

## Node.js・pnpmの準備（Windows）

Node.jsは安定版24系の `24.22.1` 以上を使用します。これは[2026-10-21のセキュリティ修正](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)を含む最低版であり、将来も最新版という意味ではありません。導入・更新時には公式告知を確認し、24系の修正済み最新パッチ版を選びます。別の系列への変更は互換性を確認して要件と起動処理を合わせて更新します。

起動処理は標準の `C:\Program Files\nodejs\node.exe` を使用し、毎回パスと版を表示・検証します。別の場所へインストールした場合は、`$env:HIDAMARI_NODE_PATH` に更新済み `node.exe` の絶対パスを設定してください。PATHやCodex同梱版への自動切り替えは行わず、未導入・未修正版・要件外の版では停止します。

このPCのPATH上の `pnpm.cmd` は古い同梱Node.jsを起動するため使用しません。初回は更新済みNode.jsと同じインストール先のnpmから、`package.json` 指定のpnpmを作業用フォルダーへ導入します。リポジトリのルートで実行してください。

```powershell
. ./tools/node-runtime.ps1
$nodePath = Get-HidamariNodePath
$npmScript = Join-Path (Split-Path -Parent $nodePath) 'node_modules/npm/bin/npm-cli.js'
& $nodePath $npmScript install --prefix .build-tools --no-save --package-lock=false --ignore-scripts pnpm@11.7.0
if ($LASTEXITCODE -ne 0) { throw 'pnpmの準備に失敗しました。' }
./tools/run-pnpm.ps1 --version
./tools/run-pnpm.ps1 install --frozen-lockfile
```

`.build-tools/` はGit管理外です。`run-pnpm.ps1` はpnpmが指定版 `11.7.0` であることを確認し、検証済みNode.jsからJavaScriptエントリーポイントを直接起動します。子プロセス用のPATHにも同じNode.jsを先頭に設定します。pnpmが指定版と一致しない場合は起動前に停止します。

以降の `pnpm` 操作は `./tools/run-pnpm.ps1` を経由します。別PCでもその環境の修正済みNode.jsを確認し、このPC固有のパスを流用しないでください。これらは制作コマンドの設定であり、Codex本体・プラグイン内部のランタイムを更新するものではありません。

起動処理を変更した場合は `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/test-node-runtime.ps1` で未修正版・要件外の版・同梱版・pnpmの版不一致を拒否することを確認します。版の異常系はバッチファイルの代役で検証し、古いNode.js本体は起動しません。

## CSSビルド

CSSやレイアウトを変更する場合は、次の順で作業します。

1. 元ファイルのSCSSを編集する。
2. `./tools/run-pnpm.ps1 run build:css` を実行して生成CSSを更新する。
3. `./tools/run-pnpm.ps1 run check:visual` を実行してPC幅のスクリーンショットを生成する。
4. `visual-check/*.png` を確認する。

ビルドしてからPC幅スクリーンショットを撮る場合は、次のコマンドを使えます。

```powershell
./tools/run-pnpm.ps1 run check:visual:build
```

初回のみ依存関係をインストールします。

```powershell
./tools/run-pnpm.ps1 install --frozen-lockfile
```

SassコンパイルとAutoprefixer適用をまとめて実行し、生成CSSを更新します。

```powershell
./tools/run-pnpm.ps1 run build:css
```

Autoprefixerの対象ブラウザは `.browserslistrc` で管理します。

CSS作業中に表示用CSSだけを監視ビルドする場合は、次のコマンドを使います。

```powershell
./tools/run-pnpm.ps1 run watch:css
```

生成される主なCSSは次の通りです。

- `docs/css/style.css`: HTMLが読み込む表示用CSS
- `docs/scss/style.css`: SCSS配下の確認用コンパイル結果
- `docs/scss/style.min.css`: 圧縮CSS

生成CSSだけを直接編集するのは避け、`scss/style.scss` を更新してから `./tools/run-pnpm.ps1 run build:css` を実行してください。

## 静的検査

JavaScriptの構文と、全HTMLのローカル参照・ID・関連付け・画像代替テキストをまとめて確認します。

```powershell
./tools/run-pnpm.ps1 run check:site
```

## 画像最適化

変換元画像は `source-assets/images/`、生成したWebPは `docs/img/` で管理します。OGPにも使う `MainVisual_pc.png` は公開ファイルを変換元として兼用します。

```powershell
python tools/optimize-images.py
```

## 表示確認

CSSやレイアウトを変更した後は、`./tools/run-pnpm.ps1 run build:css` を実行してから主要ページを確認します。標準ではPC幅を確認し、SP幅は指示がある場合のみ生成します。

確認対象ページの一覧は `tools/visual-check-pages.json` で管理します。

| ID | ページ | ファイル |
|---|---|---|
| `index` | TOP | `docs/index.html` |
| `about` | About_Us | `docs/about_us.html` |
| `facilities` | Facilities | `docs/facilities.html` |
| `price` | Price | `docs/price.html` |
| `faq` | FAQ | `docs/faq.html` |
| `contact` | Contact | `docs/contact.html` |
| `archive` | Archive | `docs/archive.html` |
| `single` | Single | `docs/single.html` |
| `privacy` | Privacy | `docs/privacy.html` |

主要ページのPC幅スクリーンショットは次のコマンドでまとめて生成できます。

```powershell
./tools/run-pnpm.ps1 run check:visual
```

PC幅だけを明示する場合は次のコマンドを使います。

```powershell
./tools/run-pnpm.ps1 run check:visual:pc
```

SP幅は指示がある場合のみ、次のコマンドで生成します。

```powershell
./tools/run-pnpm.ps1 run check:visual:sp
```

一部ページだけ確認する場合は、ページIDを指定します。

```powershell
./tools/run-pnpm.ps1 run check:visual -PageId index,faq
./tools/run-pnpm.ps1 run check:visual:build -PageId price
```

スクリーンショットは `visual-check/` に保存されます。`visual-check/` と `.chrome-check/` はローカル確認用の生成物で、Git管理には含めません。

古いスクリーンショットと表示確認用のChrome一時プロファイルを削除する場合は、次のコマンドを使います。

```powershell
./tools/run-pnpm.ps1 run clean:visual
```

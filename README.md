# rimo

[English](README.en.md) | [日本語](README.md)

`rimo` は [Rimo Voice](https://rimo.app) プラットフォームのコマンドラインインターフェースです。Rimo Voice API をラップしており、ターミナルから会議メモの検索・取得・質問ができます。

人間と AI エージェント（Claude Code、Codex など）の両方のために作られています。すべてのコマンドはデフォルトで JSON を出力し、`--help` で挙動を確認できるため、スクリプトやエージェントのワークフローにそのまま組み込めます。

> **公式配布リポジトリです。** このリポジトリはリリース済みの `rimo` バイナリとそのドキュメントを提供します。CLI のソースコードはここでは公開していません。バイナリは [Releases](https://github.com/rimoapp/cli/releases) からのみ取得し、公開されている `checksums.txt` で検証してください（[インストール](docs/ja/installation.md) を参照）。

## インストール

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

これにより最新の `rimo` バイナリが `~/.local/bin` にインストールされます（`sudo` は不要）。その他のオプション、バージョン固定、アップグレード、アンインストールについては [インストール](docs/ja/installation.md) を参照してください。

## クイックスタート

```bash
rimo auth login        # ブラウザベースの安全なログイン（トークンは OS により安全に保存）
rimo note list         # メモを一覧表示（JSON）
rimo note get <id>     # 単一のメモを取得
```

```bash
rimo note search "Q3 release plan"               # 意味でメモを検索
rimo note ask "what did we decide on pricing?"   # メモから AI が回答を生成
```

## コマンド

すべてのコマンドはデフォルトで stdout に JSON を出力します。（[理由と例外 →](docs/ja/output-and-errors.md)）

| コマンド | 説明 |
|---------|-------------|
| [`rimo auth login`](docs/ja/commands.md#rimo-auth-login)   | OAuth デバイス認可グラントで認証 |
| [`rimo auth logout`](docs/ja/commands.md#rimo-auth-logout) | トークンを失効させ、保存されたアカウントを削除 |
| [`rimo auth status`](docs/ja/commands.md#rimo-auth-status) | 認証済みアカウントを表示 |
| [`rimo auth switch`](docs/ja/commands.md#rimo-auth-switch) | アクティブなアカウントを切り替え |
| [`rimo note list`](docs/ja/commands.md#rimo-note-list)     | メモを一覧表示（参加したメモは `--attended`） |
| [`rimo note get`](docs/ja/commands.md#rimo-note-get)       | ID でメモを取得（メタデータ、文字起こし、ドキュメント） |
| [`rimo note search`](docs/ja/commands.md#rimo-note-search) | 意味的類似度またはキーワードでメモを検索 |
| [`rimo note ask`](docs/ja/commands.md#rimo-note-ask)       | 質問すると AI が統合した回答を返す |
| [`rimo version`](docs/ja/commands.md#rimo-version)         | CLI のバージョンを表示 |
| [`rimo upgrade`](docs/ja/commands.md#rimo-upgrade)         | 最新リリースへ自己アップグレード |

フラグごとの完全なリファレンス: [コマンド](docs/ja/commands.md)。

## グローバルフラグ

```
--account <alias>    使用するアカウントのエイリアス（設定の default_account を上書き）
--token <string>     API トークン（保存された認証情報を上書き。RIMO_TOKEN 環境変数を推奨）
--fields <spec>      含めるフィールド: "" (すべて)、"compact"、または "field1,field2"
--excludes <list>    出力から除外するフィールド（カンマ区切り）
--dry-run            副作用なしでコマンドをシミュレート（書き込み系のみ）
```

## ドキュメント

- [インストール](docs/ja/installation.md) — インストール、バージョン固定、アップグレード、アンインストール
- [認証](docs/ja/authentication.md) — デバイスグラントログイン、アカウント、CI 向けの `RIMO_TOKEN`
- [コマンド](docs/ja/commands.md) — フラグと例を含む完全なリファレンス
- [設定](docs/ja/configuration.md) — `config.yaml`、認証情報の保存、環境変数
- [出力とエラー](docs/ja/output-and-errors.md) — JSON 設計、`--fields`/`--excludes`、終了コード
- [トラブルシューティング](docs/ja/troubleshooting.md) — インストール・ログイン・PATH のよくある問題

## AI エージェント

`rimo` には [エージェント用スキル](skills/rimo-cli/SKILL.md) が同梱されており、AI コーディングエージェント（Claude Code、Codex など）が自律的にインストール・認証・メモ内容の取得を行えます。スキルはエージェントがオンデマンドで読み込む、自己完結型の操作マニュアルです。

**Claude Code での利用** — スキルをプロジェクトまたはユーザーのスキルディレクトリに配置すると、Rimo に関する話題が出たときに Claude Code が自動的に読み込みます:

```bash
# プロジェクト単位（リポジトリと一緒にコミット）
mkdir -p .claude/skills && cp -r skills/rimo-cli .claude/skills/

# またはユーザー単位（全プロジェクトで利用可能）
mkdir -p ~/.claude/skills && cp -r skills/rimo-cli ~/.claude/skills/
```

その後はそのまま会話で依頼できます: *「今週の Rimo のメモを要約して」*、*「直近のミーティングで料金についてどう決まった？」*、*「Q3 リリースプランに関する Rimo のメモを探して」*。

**Codex やその他のエージェントでの利用** — セッション開始時にエージェントへ [`skills/rimo-cli/SKILL.md`](skills/rimo-cli/SKILL.md) を読み込ませる（例: `cat skills/rimo-cli/SKILL.md`）か、内容をシステムプロンプトに含めてください。シェルコマンドを実行でき Markdown を読めるエージェントであれば、そのまま手順に従って動作します。

完全なエージェント操作マニュアルは [`skills/rimo-cli/SKILL.md`](skills/rimo-cli/SKILL.md) を参照してください。

## サポート

バグの発見や機能のリクエストがありますか？このリポジトリで issue を作成してください。

## セキュリティ

脆弱性の報告については [セキュリティポリシー](SECURITY.md) を参照してください。セキュリティに関する報告は公開 issue では行わないでください。

## ライセンス

本プロジェクトはオープンソースではありません。Rimo CLI の利用は [Rimo 利用規約](https://rimo.app/terms) に従います。[NOTICE](NOTICE.md) を参照してください。

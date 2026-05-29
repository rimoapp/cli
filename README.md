# rimo

[English](README.en.md) | [日本語](README.md)

`rimo` は [Rimo Voice](https://rimo.app) プラットフォームのコマンドラインインターフェースです。ターミナルから会議メモの検索・取得・質問ができます。

人間と AI エージェント（Claude Code、Codex など）の両方のために作られています。すべてのコマンドはデフォルトで JSON を出力し、`--help` で挙動を確認できるため、スクリプトやエージェントのワークフローにそのまま組み込めます。

> **公式配布リポジトリです。** このリポジトリはリリース済みの `rimo` バイナリとそのドキュメントを提供します。CLI のソースコードはここでは公開していません。バイナリは [Releases](https://github.com/rimoapp/cli/releases) からのみ取得し、公開されている `checksums.txt` で検証してください（[インストール](docs/ja/installation.md) を参照）。

## インストール

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

これにより最新の `rimo` バイナリが `~/.local/bin` にインストールされます。その他のオプション、アップグレード、アンインストールについては [インストール](docs/ja/installation.md) を参照してください。

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
| [`rimo auth login`](docs/ja/commands.md#rimo-auth-login)   | ブラウザベースのログインで認証 |
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
--token <string>     API トークン（保存された認証情報を上書き）
--fields <spec>      含めるフィールド: "" (すべて)、"compact"、または "field1,field2"
--excludes <list>    出力から除外するフィールド（カンマ区切り）
--dry-run            副作用なしでコマンドをシミュレート（書き込み系のみ）
```

## ドキュメント

- [インストール](docs/ja/installation.md) — インストール、アップグレード、アンインストール
- [認証](docs/ja/authentication.md) — ブラウザベースのログインとアカウント
- [コマンド](docs/ja/commands.md) — フラグと例を含む完全なリファレンス
- [設定](docs/ja/configuration.md) — `config.yaml`、認証情報の保存、環境変数
- [出力とエラー](docs/ja/output-and-errors.md) — JSON 設計、`--fields`/`--excludes`、終了コード
- [MCP サーバー](docs/ja/mcp.md) — `rimo` を Claude Code、Codex、Cursor などの MCP クライアントに型付きツールとして公開
- [トラブルシューティング](docs/ja/troubleshooting.md) — インストール・ログイン・PATH のよくある問題

## AI エージェント

`rimo` は AI コーディングエージェント（Claude Code、Codex、Cursor など）への組み込み手段を 2 つ提供しています。両者は併用できます。

### MCP サーバー（型付きツール、MCP 対応クライアント向け）

`rimo mcp` を起動すると、CLI が [Model Context Protocol](https://modelcontextprotocol.io) の型付きツールとして公開され、エージェントは CLI に shell out して JSON を解析する必要がありません。Claude Code には `.mcp.json` にエントリを追加するだけ:

```json
{
  "mcpServers": {
    "rimo": { "type": "stdio", "command": "rimo", "args": ["mcp"] }
  }
}
```

クライアントを再起動し、自然言語で問いかけてください: *「今週の Rimo のメモを要約して」*、*「料金について何を決めた?」*、*「Q3 リリースプランに関する Rimo のメモを探して」*。

Claude Code、Codex、Cursor などの完全なセットアップ、ツール一覧、問いかけ例: [MCP サーバー](docs/ja/mcp.md)。

### エージェント用スキル（シェルコマンドを実行できる任意のエージェント向け）

`rimo` には [エージェント用スキル](skills/rimo-cli/SKILL.md) も同梱されています — 自己完結型の操作マニュアルで、任意のエージェントが読み込んでシェルコマンドを実行することで利用できます。MCP に対応していないエージェント向け、またはシステムプロンプトに貼り付ける単一の成果物が欲しい場合にどうぞ。

```bash
# プロジェクト単位（リポジトリと一緒にコミット）
mkdir -p .claude/skills && cp -r skills/rimo-cli .claude/skills/

# またはユーザー単位（全プロジェクトで利用可能）
mkdir -p ~/.claude/skills && cp -r skills/rimo-cli ~/.claude/skills/
```

Codex やその他のエージェントでは、セッション開始時に [`skills/rimo-cli/SKILL.md`](skills/rimo-cli/SKILL.md) を読み込ませる（例: `cat skills/rimo-cli/SKILL.md`）か、内容をシステムプロンプトに含めてください。

## サポート

バグの発見や機能のリクエストがありますか？このリポジトリで issue を作成してください。

## セキュリティ

脆弱性の報告については [セキュリティポリシー](SECURITY.md) を参照してください。セキュリティに関する報告は公開 issue では行わないでください。

## ライセンス

本プロジェクトはオープンソースではありません。Rimo CLI の利用は [Rimo 利用規約](https://rimo.app/policies/terms) に従います。[NOTICE](NOTICE.md) を参照してください。

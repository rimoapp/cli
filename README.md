# rimo

[English](README.en.md) | [日本語](README.md)

`rimo` は [Rimo Voice](https://rimo.app) プラットフォームのコマンドラインインターフェースです。ターミナルから会議ノートの検索・取得・質問ができます。

人間と AI エージェント（Claude Code、Codex など）の両方のために作られています。すべてのコマンドはデフォルトで JSON を出力し、`--help` で挙動を確認できるため、スクリプトやエージェントのワークフローにそのまま組み込めます。

> **公式配布リポジトリです。** バイナリは [Releases](https://github.com/rimo/cli/releases) からのみ取得し、公開されている `checksums.txt` で検証してください（[インストール](docs/ja/installation.md) を参照）。

## インストール

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

これにより最新の `rimo` バイナリが `~/.local/bin` にインストールされます。その他のオプション、アップグレード、アンインストールについては [インストール](docs/ja/installation.md) を参照してください。

## クイックスタート

```bash
rimo auth login        # ブラウザベースの安全なログイン（トークンは OS により安全に保存）
rimo note list         # ノートを一覧表示（JSON）
rimo note get <id>     # 単一のノートを取得
```

```bash
rimo note search "Q3 release plan"               # 意味でノートを検索
rimo note ask "what did we decide on pricing?"   # ノートから AI が回答を生成
```

## コマンド

すべてのコマンドはデフォルトで stdout に JSON を出力します。（[理由と例外 →](docs/ja/output-and-errors.md)）

| コマンド | 説明 |
|---------|-------------|
| [`rimo auth login`](docs/ja/commands.md#rimo-auth-login)   | ブラウザベースのログインで認証 |
| [`rimo auth logout`](docs/ja/commands.md#rimo-auth-logout) | トークンを失効させ、保存されたアカウントを削除 |
| [`rimo auth status`](docs/ja/commands.md#rimo-auth-status) | 認証済みアカウントを表示 |
| [`rimo auth switch`](docs/ja/commands.md#rimo-auth-switch) | アクティブなアカウントを切り替え |
| [`rimo note list`](docs/ja/commands.md#rimo-note-list)     | ノートを一覧表示（`--attended`、`--team`、`--since`/`--until`、`--updated-since`） |
| [`rimo note get`](docs/ja/commands.md#rimo-note-get)       | ID でノートを取得（メタデータ、文字起こし、ドキュメント） |
| [`rimo note search`](docs/ja/commands.md#rimo-note-search) | 意味的類似度またはキーワードでノートを検索 |
| [`rimo note ask`](docs/ja/commands.md#rimo-note-ask)       | 質問すると AI が統合した回答を返す |
| [`rimo team list`](docs/ja/commands.md#rimo-team-list)     | 組織内のチームを一覧表示 |
| [`rimo version`](docs/ja/commands.md#rimo-version)         | CLI のバージョンを表示 |
| [`rimo upgrade`](docs/ja/commands.md#rimo-upgrade)         | 最新リリースへ自己アップグレード |

完全なリファレンスはこちらを参照ください: [コマンド](docs/ja/commands.md)。

## グローバルフラグ

```
--account <alias>    使用するアカウントのエイリアス（設定の active_account を上書き）
--fields <spec>      含めるフィールド: "" (すべて)、"compact"、または "field1,field2"
--excludes <list>    出力から除外するフィールド（カンマ区切り）
--dry-run            副作用なしでコマンドをシミュレーション（書き込み系のみ）
```

## ドキュメント

- [インストール](docs/ja/installation.md) — インストール、アップグレード、アンインストール
- [認証](docs/ja/authentication.md) — ブラウザベースのログインとアカウント
- [個人用 APIキー](docs/ja/personal-api-keys.md) — Web アプリでキーを作成し、CI/CD 向けに `RIMO_API_KEY` で認証
- [コマンド](docs/ja/commands.md) — フラグと例を含む完全なリファレンス
- [設定](docs/ja/configuration.md) — `config.yaml`、認証情報の保存、環境変数
- [出力とエラー](docs/ja/output-and-errors.md) — JSON 設計、`--fields`/`--excludes`、終了コード
- [MCP サーバー](docs/ja/mcp.md) — `rimo` を Claude Code、Codex、Cursor などの MCP クライアントに型付きツールとして公開
- [トラブルシューティング](docs/ja/troubleshooting.md) — インストール・ログイン・PATH のよくある問題

## AI エージェント

`rimo` は AI コーディングエージェント（Claude Code、Codex、Cursor など）への組み込み手段を 2 つ提供しています。両者は併用できます。Claude Code をお使いの場合は、プラグインでスキルをワンコマンド導入するのが最も簡単です。

### Claude Code プラグイン（スキルをワンコマンドで）

`rimo` プラグインは [エージェント用スキル](skills/rimo-cli/SKILL.md) を同梱しています。Claude Code に 1 コマンドで導入できます:

```
/plugin marketplace add rimo/cli
/plugin install rimo@rimo
```

このリポジトリ自体がマーケットプレイスを兼ねているため、外部リポジトリへの依存はありません。別途 `rimo` バイナリを `$PATH` に置き、`rimo auth login` で認証しておく必要があります。スキルだけでエージェントは `rimo` CLI を通じて全機能を使えます。型付きツール（MCP）が欲しい場合は、下記の MCP サーバーを併用してください。

### MCP サーバー（型付きツール、MCP 対応クライアント向け）

`rimo mcp` を起動すると、CLI が [Model Context Protocol](https://modelcontextprotocol.io) の型付きツールとして公開されます。Claude Code の `.mcp.json` に `rimo` エントリを追加してください:

```json
{
  "mcpServers": {
    "rimo": { "type": "stdio", "command": "rimo", "args": ["mcp"] }
  }
}
```

クライアントを再起動し、自然言語で問いかけてください:

- *「今週の Rimo のノートを要約して」*
- *「Q3 リリースプランに関する Rimo のノートを探して」*

Claude Code、Codex、Cursor など他の MCP クライアントの完全なセットアップについてはこちらを参照ください: [MCP サーバー](docs/ja/mcp.md)。

### エージェント用スキル（シェルコマンドを実行できる任意のエージェント向け）

`rimo` には [エージェント用スキル](skills/rimo-cli/SKILL.md) も同梱されています — 自己完結型の操作マニュアルで、任意のエージェントが読み込んでシェルコマンドを実行することで利用できます。MCP に対応していないエージェント向け、またはシステムプロンプトに貼り付ける単一の成果物が欲しい場合にご利用ください。

```bash
# プロジェクト単位（リポジトリと一緒にコミット）
mkdir -p .claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimo/cli/main/skills/rimo-cli/SKILL.md \
  -o .claude/skills/rimo-cli/SKILL.md

# またはユーザー単位（全プロジェクトで利用可能）
mkdir -p ~/.claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimo/cli/main/skills/rimo-cli/SKILL.md \
  -o ~/.claude/skills/rimo-cli/SKILL.md
```

Codex やその他のエージェントでは、セッション開始時にインストールしたファイルを読み込ませる（例: `cat ~/.claude/skills/rimo-cli/SKILL.md`）か、内容をシステムプロンプトに含めてください。

## サポート

バグの発見や機能のリクエストがある場合は、このリポジトリで issue を作成してください。

## セキュリティ

脆弱性の報告については [セキュリティポリシー](SECURITY.md) を参照してください。セキュリティに関する報告は公開 issue では行わないでください。

## ライセンス

本プロジェクトはオープンソースではありません。Rimo CLI の利用は [Rimo 利用規約](https://rimo.app/policies/terms) に従います。[NOTICE](NOTICE.md) を参照してください。

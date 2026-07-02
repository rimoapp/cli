# はじめに

`rimo` は [Rimo Voice](https://rimo.app) プラットフォームのコマンドラインインターフェースです。ターミナルから会議のノートを検索・取得・質問したり、Claude Code・Codex・Cursor などの AI エージェントに組み込んだりできます。

## インストール

**Linux / macOS**

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

**Windows（PowerShell）**

```powershell
irm https://rimo.app/cli/install.ps1 | iex
```

確認:

```bash
rimo version
```

手動インストール、アップグレード、アンインストールの方法は [インストール](installation.md) を参照してください。

## ログイン

```bash
rimo auth login
```

ブラウザが開きます。サインインしてリクエストを承認してください。トークンは OS の認証情報ストアに安全に保存されます（ファイルには保存されません）。

ブラウザを使えない環境（SSH、CI など）では:

```bash
rimo auth login --no-browser
```

## 最初のコマンド

```bash
# ノートを一覧表示
rimo note list

# 1 件のノートを取得（メタデータを JSON で）
rimo note get <note_id>

# ノートのトランスクリプトをプレーンテキストで取得
rimo note get <note_id> --transcript

# 意味でノートを検索
rimo note search "Q3 リリース計画"

# 質問して AI が合成した回答を得る
rimo note ask "料金について何を決めましたか？"
```

## 出力形式

すべてのコマンドはデフォルトで stdout に JSON を出力します — TTY 検出やテーブル整形はありません。ターミナルでもスクリプトでも同じ出力が得られます:

```bash
rimo note list | jq '.notes[].title'
rimo note list --fields id,title,created_at
```

一部のコマンド（`rimo version`、`rimo upgrade`、`rimo note ask`、コンテンツフラグ付きの `rimo note get`）はプレーンテキストを出力します。エラーは常に JSON です。

詳細は [出力とエラー](output-and-errors.md) を参照してください。

## 次のステップ

- [インストール](installation.md) — プラットフォーム別のインストール、アップグレード、アンインストール
- [認証](authentication.md) — 複数アカウントのセットアップ
- [コマンド](commands.md) — フラグ別の完全なリファレンス
- [MCP サーバー](mcp.md) — Claude Code・Codex・Cursor 向けの型付きツール
- [使用例](examples.md) — 実用的なレシピ

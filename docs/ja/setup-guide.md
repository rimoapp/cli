# コーディングツールで使う

[English](../en/setup-guide.md) | [日本語](../ja/setup-guide.md)

このガイドでは、Rimo を **自分のパソコンで動くコーディングツール** — Claude Code、Codex CLI、Cursor、Claude Desktop — に接続します。これらは `rimo` バイナリに同梱されたローカル MCP サーバー（`rimo mcp`）と通信します。組み込むと、ツールから Rimo ノートの一覧表示、トランスクリプトの取得、検索、質問ができるようになります。

> **代わりに Web アシスタント（Claude や ChatGPT）を使いますか?** それらはインストール不要で、ブラウザで Rimo を追加してサインインするだけです。[Claude で Rimo を使う](rimo-in-claude.md) または [ChatGPT で Rimo を使う](rimo-in-chatgpt.md) を参照してください。接続後に *できること*（どのツールでも同じ）は [MCP でできること](mcp.md) を参照してください。

> **スキルと MCP — どちらを使うべきか?** どちらも `rimo` に同梱されています。[エージェント用スキル](../../skills/rimo-cli/SKILL.md) は、任意のエージェントが読み込んでシェルコマンドを実行することで利用できるマークダウン形式の操作マニュアルです。`rimo mcp` は型付きツールによる代替で、MCP 対応クライアント（Claude Code、Cursor、MCP 対応の Codex 等）向けです。両者は共存可能です。エージェントに合う方を選んでください。

---

## 1. 必要条件

1. **`rimo` がインストールされ、`$PATH` 上にあること。** `rimo version` で確認できます。未インストールの場合は [インストール](installation.md) を参照してください。
2. **ログイン済みのアカウント。** `rimo auth login` を実行してブラウザで認証してください。
   トークンは OS の認証情報ストアに保存されます。MCP サーバーは CLI と同じ認証情報を
   再利用するため、MCP 専用のログインは不要です。

> **Claude Desktop は例外です** — ワンクリック拡張機能に `rimo` が同梱されているため、そのパスでは CLI のインストールも `rimo auth login` のセッションも **不要** です。下記の [Claude Desktop（ワンクリック拡張機能）](#claude-desktopワンクリック拡張機能) を参照してください。

---

## 2. クライアント別のセットアップ

### Claude Code

`.mcp.json` に `rimo` エントリを追加します。プロジェクトローカル（`./.mcp.json`、リポジトリと一緒にコミット）または、ユーザーグローバル（`~/.claude/mcp.json`）のどちらでも動作します。

```json
{
  "mcpServers": {
    "rimo": {
      "type": "stdio",
      "command": "rimo",
      "args": ["mcp"]
    }
  }
}
```

Claude Code を再起動すると、新しいサーバーが起動します。Rimo のツールが追加されるので、自然言語で問いかけるだけで Claude Code が適切なツールにルーティングします。

### Claude Desktop（ワンクリック拡張機能）

Claude Desktop は MCP サーバーを **拡張機能**（`.mcpb` バンドル）として導入します。`claude_desktop_config.json` を手で編集する必要はありません。Rimo のバンドルは自己完結型で、**`rimo` CLI のインストールは不要です。**

1. **バンドルを入手する。** [最新リリース](https://github.com/rimo/cli/releases/latest) から `rimo.mcpb` をダウンロードします（macOS・Windows 対応）。
2. **インストールする。** Claude Desktop の **設定 → Extensions（拡張機能）** を開き、`rimo.mcpb` をウィンドウにドラッグ＆ドロップします（または **Install from file** を使用）。ファイルをダブルクリックしても導入できます。
3. **サインインする。** Rimo の Web アプリで[パーソナル API キー](personal-api-keys.md)を作成し、拡張機能の **Rimo API key** 設定に貼り付けます。Claude Desktop がキーを安全に保存します。
   - すでに `rimo` CLI を使っている場合は、キーを空欄のままにすれば `rimo auth login` のセッションが再利用されます。
4. **有効化する。** Rimo のツールが Claude Desktop のツール一覧に表示されます。自然言語で問いかければ、Claude が適切なツールにルーティングします。

> **API キーのローテーション:** Rimo の Web アプリで古いキーを失効させて新しいキーを作成し、拡張機能の設定（設定 → Extensions → Rimo → Configure）に貼り付けてください。変更はすぐに反映されます。

> **アップデート:** 各リリースには、そのリリースの `rimo` を内蔵した新しい `rimo.mcpb` が付属します。最新版をダウンロードして再インストールすれば更新されます。別途インストールした `rimo` CLI は `rimo upgrade` で独立して更新され、両者は互いに影響しません。

### Codex

Codex CLI は `.mcp.json` を読み込み **ません**。MCP サーバーは `~/.codex/config.toml` の `[mcp_servers.<name>]`（TOML）に登録します。`rimo` エントリを追加してください:

```toml
[mcp_servers.rimo]
command = "rimo"
args = ["mcp"]
```

追加したら Codex を再起動して新しいサーバーを起動させます。Rimo のツールが利用可能になり、自然に質問すれば Codex が適切なツールにルーティングします。Codex が引き継ぐ `PATH` に `rimo` が含まれていない場合は、`command` に絶対パスを指定してください（例: `command = "/usr/local/bin/rimo"`）。

### Cursor

Cursor の設定 → **MCP** → **Add new MCP server** で以下を入力します:

- **Type:** Command (stdio)
- **Command:** `rimo`
- **Args:** `mcp`

保存して Cursor の MCP パネルをリロードすると、Rimo のツールが表示されます。

### その他の MCP クライアント

stdio JSON-RPC を扱える任意の MCP クライアントで動作します。起動コマンドは常に以下のとおり:

```bash
rimo mcp
```

クライアントは stdout から JSON-RPC を読み取り、stdin に書き込みます。ログ出力は stderr に流れるため、プロトコルストリームと衝突することはありません。

---

## 3. 認証エラー

ツール呼び出しが認証関連のエラーを返した場合、最も多い原因は以下のとおりです:

| 症状                                                                  | 対処                                                                 |
|---------------------------------------------------------------------|---------------------------------------------------------------------|
| すべてのツールがトークン解決エラーを返す。                                | `rimo auth login` を実行し、**MCP クライアントを再起動** して、新しいトークンで `rimo mcp` を再起動させてください。 |
| 1 つのアカウントでは成功するが、別のアカウントでは失敗する。              | `rimo_auth_status` を確認してください。他方のアカウントのトークンが期限切れの可能性があります — `--account <alias>` を指定して再ログインしてください。 |
| `rimo auth status` は正常なのに「no token resolved」と表示される。      | MCP クライアントがシェルの `PATH` を引き継いでいない可能性があります。`.mcp.json` の `command` フィールドで `rimo` の絶対パスを指定するか、`~/.local/bin` が `PATH` に入っているシェルからクライアントを起動してください。 |

---

## 4. トラブルシューティング

**Rimo のツールがツールピッカーに表示されない。**
MCP クライアントを動かしているユーザーアカウントの `$PATH` に `rimo` が含まれているか確認してください。クライアントが起動するシェル環境から `which rimo` を実行してみてください。クライアントが GUI アプリケーション（シェルではない）から起動される場合、`~/.local/bin` を認識しないことがあります。`rimo` をシェルに依存しない場所（`/usr/local/bin`）に置くか、`.mcp.json` で絶対パスをハードコードしてください。

**ツールは表示されるが、すべての呼び出しがエラーになる。**
MCP クライアントが表示する `rimo mcp` のログを確認してください。サーバーからのエラーメッセージは、ほぼそのままツール結果のコンテンツとして返されます。よくあるケース: トークンの期限切れ（再ログインしてクライアントを再起動）、ネットワーク未接続、バックエンドの一時的な 5xx エラー（リトライ）。

**`note_search` を期待しているのにエージェントが `note_ask` を選ぶ。**
エージェントはツールの説明とユーザーの言い回しを参考にしています。明示的にしてください: *「ノートを検索して…」* は `note_search` / `note_semantic_search` に、*「質問に答えて…」* は `note_ask` にルーティングされます。

**表示されるツールが期待より少ない。**
一部の Rimo API 操作は意図的にまだ公開されていません — CLI でエンドツーエンドに検証済みの操作のみが MCP ツールとして提供されます。CLI コマンドのリリースに合わせて順次拡張されます。

**対話的なデバッグ。**
公式の MCP Inspector を使うと、ブラウザ UI でサーバーを直接操作できます:

```bash
npx @modelcontextprotocol/inspector rimo mcp
```

ローカルでウェブ UI が起動し、ツールの閲覧、スキーマの確認、1 件ずつのツール呼び出しが行えます。

---

## 関連項目

- [MCP でできること](mcp.md) — 接続後に使えるツールと問いかけの例
- [Claude で Rimo を使う](rimo-in-claude.md) / [ChatGPT で Rimo を使う](rimo-in-chatgpt.md) — Web アシスタント向けのホスト型サーバー。インストール不要
- [認証](authentication.md) — ログインフロー、トークン保存、複数アカウント
- [設定](configuration.md) — `config.yaml`、環境変数
- [コマンド](commands.md) — CLI の完全リファレンス（MCP サーバーはこのサブセットを公開）
- [エージェント用スキル](../../skills/rimo-cli/SKILL.md) — MCP に対応していないエージェント向けのマークダウン代替

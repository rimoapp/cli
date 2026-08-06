# Rimo — Claude Desktop 拡張機能（`.mcpb`）

[English](README.en.md) | [日本語](README.md)

このディレクトリは、**Rimo の Claude Desktop 拡張機能**のソースオブトゥルース（正）です。`claude_desktop_config.json` を手で編集することなく、`rimo mcp` サーバーを [Claude Desktop](https://claude.ai/download) にワンクリックで組み込むためのバンドルです。

| ファイル | 役割 |
|------|------|
| `manifest.json` | 拡張機能のメタデータ + MCP サーバーの起動定義。**拡張機能の `version` の唯一のソースオブトゥルース。** |
| `icons/icon.png` | Claude Desktop に表示される拡張機能のアイコン（`rimo` GitHub org のアバターを元にした Rimo のブランドマーク）。 |
| `icons/icon-16.png`, `icons/icon-32.png`, `icons/icon-128.png` | 小さいサイズ（`icons/icon.png` を `sips` で縮小したもの）。コンパクトな UI（コネクターメニューなど）が正確なサイズを選べるよう、manifest の `icons` 配列に列挙されています。ローカル拡張機能の場合、Claude Desktop は一部のメニューで頭文字アバターを表示することがあります — アップストリームの [mcpb#154](https://github.com/modelcontextprotocol/mcpb/issues/154) を参照。 |
| `server/` | **Gitignore されたビルド成果物** — パック直前にここへ配置される `rimo` バイナリ（ローカルでは `make mcpb-server-binaries`、リリースワークフローでは署名済みの goreleaser 成果物をコピー）。 |
| `.mcpbignore` | パックされたバンドルから除外するファイル。 |

## バイナリ戦略 — オプション B（バイナリ同梱）

このバンドルは **`rimo` バイナリを同梱**しているため、拡張機能のインストールに別途 CLI をインストールする必要も、PATH の設定も不要です。

- `server/rimo` — macOS **ユニバーサル**バイナリ（goreleaser の `universal_binaries`/lipo による Intel + Apple Silicon）。リリースパイプラインで Developer ID による**署名と公証**が行われます。manifest の `platform_overrides` はアーキテクチャ単位ではなく **OS 単位**で選択するため、fat バイナリが必要です。
- `server/rimo.exe` — Windows amd64（ARM Windows ではエミュレーションで動作）。**#152 まで未署名**（Authenticode）— Claude Desktop は子プロセスとして問題なく起動しますが、ディレクトリ登録に向けては署名が信頼上の課題として残っています。
- Linux は `compatibility.platforms` に含まれていません。Claude Desktop は Linux 向けに提供されていないためです。

manifest は `${__dirname}/server/rimo` を起動します（win32 のオーバーライド: `${__dirname}/server/rimo.exe`）。`rimo_path` という user-config フィールドはありません — オプション A（別途インストールした CLI を PATH 依存で起動する方式。v0.1.0 で提供）は、macOS の署名/公証が実現した時点（#124）で v0.2.0 においてこの方式に置き換えられました。

**`args` を `user_config` の値でパラメータ化してはいけません。** `args` はハードコードされた `["mcp"]` のままにします。ユーザー設定を `args` に流し込むと、何のメリットもなくインジェクションの余地を広げてしまいます — ユーザー設定は `env` 経由で渡してください。

## 認証 — 2 つの経路

manifest は任意の **`api_key`** という user-config フィールド（`sensitive: true` なので Claude Desktop が入力をマスクし、値を安全に保存します）を公開しており、その値はサーバーの環境変数 `RIMO_API_KEY` として注入されます — これは CLI のトークン解決における最優先項目です。したがって、Rimo の Web アプリで作成した個人用 API キーを使えば、ターミナルを一切使わずにサインインできます。空欄のままにすると値は空になり、CLI は空の `RIMO_API_KEY` を未設定として扱い、`rimo auth login` による OS キーリングのセッションにフォールバックします — そのため CLI も併用しているユーザーは設定不要で認証できます。拡張機能内での OAuth サインインはありません。それにはリモートトランスポートの作業（#198）が必要になります。

## ビルド

リポジトリのルートから:

```bash
make mcpb-validate          # manifest.json をスキーマ検証
make mcpb-server-binaries   # server/rimo（ユニバーサル）+ server/rimo.exe をクロスビルド — macOS のみ（lipo）
make mcpb-pack              # → dist/rimo.mcpb（server/ のバイナリが無ければ即座に失敗）
```

ローカルでビルドしたバイナリは**未署名**です — 自分でテストする分には問題ありません（自分でビルドしたファイルを Gatekeeper が隔離することはありません）。リリースパイプラインは、代わりに署名 + 公証済みのバイナリをパックします。

パック/検証は、公式の `@anthropic-ai/mcpb` CLI を `npx` 経由で呼び出します（Node が必要。バージョンは Makefile に固定）。`dist/` と `server/` は gitignore されており、`.mcpb` はリリース成果物であってコミットはされません。

## リリース / バージョニング

- 安定版リリースのたびに、**そのリリースのバイナリ**でバンドルを再パックし、`rimo.mcpb` + `rimo.mcpb.sha256` を添付します（`Release` ワークフローが署名済みの goreleaser 成果物を `server/` にコピーし、`make mcpb-pack` を実行）。ユーザーは最新の `rimo.mcpb` を再インストールすることで、同梱の CLI を更新します。
- **拡張機能そのもの**がユーザーに見える形で変わったとき（起動の契約、設定フィールド、説明文など）に、`manifest.json` の semver `version` を上げてください。同梱の CLI バージョンは各リリースに自動で追随するため、それ自体はバージョンを上げる理由にはなりません。
- 拡張機能の `version` は、Claude Code プラグイン（`../.claude-plugin/plugin.json`）や `rimo` CLI のリリースとは独立しています。

ユーザー向けのセットアップ手順は [`../docs/ja/mcp.md`](../docs/ja/mcp.md#claude-desktopワンクリック拡張機能) にあります。

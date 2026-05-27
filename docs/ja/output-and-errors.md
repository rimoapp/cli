# 出力とエラー

[English](../en/output-and-errors.md) | [日本語](../ja/output-and-errors.md)

## 設計としての JSON ファースト

`rimo` はデフォルトで stdout に JSON を出力します — TTY 検出やテーブル整形は
ありません。コマンドの出力はターミナルで実行してもスクリプトにパイプしても同じであり、
シェルパイプラインと AI エージェントの両方にとって予測可能です。

一部の人間向けコマンドは、JSON のラッパーがかえって邪魔になるため、成功時には
代わりに**プレーンテキスト**を出力します:

- `rimo version` と `rimo upgrade`
- `rimo note ask`（ストリーミングされる回答）
- `--transcript`、`--document`、`--all`、`--document-id` を指定した `rimo note get`

これらの場合でも、**エラーは常に JSON** なので、失敗は機械可読のままです。

## フィールドのフィルタリング

`--fields` と `--excludes` は、出力が JSON である任意のコマンドに適用されます。

### `--fields`

| 値 | 挙動 |
|-------|----------|
| `""`（デフォルト） | すべてのフィールド、完全な値 |
| `"compact"` | すべてのフィールド。長い文字列値は `"[omitted]"` に置換 |
| `"f1,f2,f3"` | これらのフィールドのみ |

```bash
rimo note list --fields compact
rimo note list --fields id,title,created_at
```

### `--excludes`

出力から削除するフィールド名をカンマ区切りで指定します。`--fields` の後に
適用されます。

```bash
rimo note list --excludes transcript,document_markdown
```

フィールドのフィルタリングは AI エージェントに特に有用です。必要なフィールドのみ
（`--fields id,title`）を要求することで、レスポンスを小さく、パースを安価に保てます。

## 終了コード

| コード | 意味 |
|------|---------|
| 0 | 成功 |
| 1 | 一般的なエラー |
| 2 | 認証 / 権限エラー |
| 3 | 見つからない |
| 4 | 検証エラー（不正なフラグ/引数） |

終了コードは成功か失敗かを判断する信頼できるシグナルです。出力をパースするのではなく、
スクリプトでは終了コードを確認してください。

## エラー形式

エラーは JSON として stdout に出力され、ゼロ以外の終了コードを伴います:

```json
{
  "code": "not_found",
  "message": "note not found: note_abc123"
}
```

| コード | 終了 | 発生条件 |
|------|------|------|
| `error` | 1 | 一般的なエラー（ネットワーク、パース、予期しないもの） |
| `auth_error` | 2 | トークンが欠落/無効。`rimo auth login` を実行 |
| `permission_denied` | 2 | トークンに必要なスコープがない（`details` 内に `scope_required`） |
| `not_found` | 3 | リソースが存在しないかアクセスできない |
| `validation_error` | 4 | 不正なフラグまたは引数 |
| `unknown_command` | 1 | タイプミス。最も近い候補は `details.suggestion` を確認 |

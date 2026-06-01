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
- `--transcript`、`--document`、`--full`、`--document-id` を指定した `rimo note get`

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
| 1 | エラー |

終了コードは成功か失敗かを判断する信頼できるシグナルです。出力をパースするのではなく、
スクリプトでは終了コードを確認してください。

## エラー形式

エラーは JSON として stdout に出力され、終了コード 1 で終了します:

```json
{
  "code": "error",
  "message": "unknown flag: --bogus"
}
```

| フィールド | 説明 |
|-------|-------------|
| `code` | 機械可読のエラーコード。現状は常に `error`。 |
| `message` | 失敗内容を表す人間向けメッセージ（検証メッセージや API ステータスなど）。 |

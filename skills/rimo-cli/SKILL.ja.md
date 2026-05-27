---
name: rimo-cli
description: "CLI から Rimo Voice の会議メモを検索・取得する AI エージェント向けスキル"
---

# Rimo CLI

`rimo` CLI は Rimo Voice API をラップしており、エージェントが会議メモの検索・取得・
質問を行えます。すべてのコマンドはデフォルトで JSON を出力します。

## インストール

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

## 認証

```bash
rimo auth login   # OAuth デバイスフロー。ブラウザが開きます
```

非対話環境や CI では、代わりに `RIMO_TOKEN` 環境変数を設定してください。

## よくあるワークフロー

参加したメモを一覧表示し、1 件を読む:

```bash
rimo note list --attended
rimo note get <note-id> --document
```

意味で検索し、統合された回答を得る:

```bash
rimo note search "Q3 の価格決定"
rimo note ask "価格について何を決めたか?"
```

## 出力とパース

- デフォルトで stdout に JSON を出力。必要なフィールドだけ残すには `--fields`
  （トークン効率的）、不要なフィールドを除くには `--excludes` を使用。
- `rimo note ask` は回答をプレーンテキストでストリーミングします。
- 失敗時の終了コードは 0 以外。エラーは stdout に JSON で出力されます。

## 権限

`rimo` は認証ユーザーがアクセスできる範囲しか返しません:

- `rimo note list` は自分が所有するメモを返し、`--attended` で参加したメモも含めます。
- `rimo note get <id>` はそのメモにアクセスできない場合は失敗します。

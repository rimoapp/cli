# 設定

[English](../en/configuration.md) | [日本語](../ja/configuration.md)

## 設定ファイル

アカウントメタデータは `~/.config/rimo/config.yaml` に保存されます:

```yaml
default_account: alice-rimo-personal
accounts:
  alice-rimo-personal:
    user_id: user_123
    org_id: org_456
    email: alice@rimo.app
    display_name: Alice
    org_name: Personal
```

このファイルは `rimo auth login` / `logout` / `switch` によって作成・管理されます。
通常、手作業で編集することはありません。

## トークンの保存

トークンが `config.yaml` に書き込まれることは**ありません**。トークンは
オペレーティングシステムの認証情報ストアに安全に保存され、プレーンテキストで
書き込まれることはありません。

ログインフローとトークン解決の順序については [認証](authentication.md) を
参照してください。

## 環境変数

| 変数 | 使用者 | 目的 |
|----------|---------|---------|
| `RIMO_INSTALL_DIR` | インストールスクリプト | バイナリのインストール先ディレクトリ（デフォルト `~/.local/bin`）。 |
| `RIMO_NO_UPDATE_CHECK` | バイナリ | 空でない任意の値を設定すると、バックグラウンドの「更新あり」通知を無効化する。 |
| `CI` | バイナリ | 設定されていると、バックグラウンドの更新通知が自動的に抑制される。 |

## ファイルの場所まとめ

| 内容 | 場所 |
|------|-------|
| アカウントメタデータ | `~/.config/rimo/config.yaml` |
| トークン | OS の認証情報ストア（`rimo auth` が管理） |
| バイナリ（デフォルトのインストール先） | `~/.local/bin/rimo` |
| 更新チェックのキャッシュ | OS のキャッシュディレクトリ、`rimo/update_check.json` |

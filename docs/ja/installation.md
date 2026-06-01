# インストール

[English](../en/installation.md) | [日本語](../ja/installation.md)

## クイックインストール（推奨）

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

このスクリプトは OS とアーキテクチャを検出し、GitHub から該当するリリースを
ダウンロードし、チェックサムを検証して、`rimo` バイナリを `~/.local/bin` に
インストールします。`sudo` は不要です。

`~/.local/bin` が `PATH` に含まれていない場合、スクリプトはシェルのプロファイルに
追加すべき行を表示します。例:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

インストールを確認:

```bash
rimo version
```

## 手動インストール

スクリプトをシェルにパイプしたくない場合は、[リリースページ](https://github.com/rimoapp/cli/releases)
からお使いのプラットフォーム向けのアーカイブをダウンロードし、`rimo` バイナリを
展開して `PATH` 上に配置してください。

各リリースでは、これらのアーカイブと `checksums.txt` が公開されます:

| OS | アーキテクチャ | アーカイブ |
|----|------|---------|
| linux | amd64 | `rimo_<ver>_linux_amd64.tar.gz` |
| linux | arm64 | `rimo_<ver>_linux_arm64.tar.gz` |
| darwin | amd64 | `rimo_<ver>_darwin_amd64.tar.gz` |
| darwin | arm64 | `rimo_<ver>_darwin_arm64.tar.gz` |
| windows | amd64 | `rimo_<ver>_windows_amd64.zip` |
| windows | arm64 | `rimo_<ver>_windows_arm64.zip` |

```bash
# 例: macOS arm64 (Apple Silicon)
VERSION=1.0.0
curl -fsSL -O "https://github.com/rimoapp/cli/releases/download/v${VERSION}/rimo_${VERSION}_darwin_arm64.tar.gz"
tar -xzf "rimo_${VERSION}_darwin_arm64.tar.gz"
mv rimo ~/.local/bin/
rimo version
```

インストール前にチェックサムを検証:

```bash
curl -fsSL -O "https://github.com/rimoapp/cli/releases/download/v${VERSION}/checksums.txt"
shasum -a 256 -c checksums.txt --ignore-missing
```

## アップグレード

```bash
rimo upgrade           # 最新リリースへアップグレード
rimo upgrade --check   # インストールせずに、新しいバージョンがあるか報告
```

または、インストールスクリプトを再実行します（常に最新リリースを取得します）:

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

すべてのフラグについては [`rimo upgrade`](commands.md#rimo-upgrade) を参照してください。

## アンインストール

```bash
rimo auth logout          # 保存されたトークンを失効・削除（任意）
rm ~/.local/bin/rimo      # バイナリを削除
rm -rf ~/.config/rimo     # 設定を削除（任意）
```

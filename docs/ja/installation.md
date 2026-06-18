# インストール

[English](../en/installation.md) | [日本語](../ja/installation.md)

## クイックインストール（推奨）

### Linux / macOS

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

### Windows

PowerShell で:

```powershell
irm https://rimo.app/cli/install.ps1 | iex
```

このスクリプトはアーキテクチャを検出し、GitHub から該当するリリースをダウンロードし、
チェックサムを検証して、`rimo.exe` を `%USERPROFILE%\.local\bin` にインストールします。
管理者権限は不要です。

インストール先がユーザー `PATH` に含まれていない場合、スクリプトが自動的に追加します。
変更を反映するため、インストール完了後は新しい PowerShell ウィンドウを開いてください。

### インストールを確認

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
| Linux | amd64 | `rimo_<ver>_linux_amd64.tar.gz` |
| Linux | arm64 | `rimo_<ver>_linux_arm64.tar.gz` |
| Mac | amd64 | `rimo_<ver>_darwin_amd64.tar.gz` |
| Mac | arm64 | `rimo_<ver>_darwin_arm64.tar.gz` |
| Windows | amd64 | `rimo_<ver>_windows_amd64.zip` |
| Windows | arm64 | `rimo_<ver>_windows_arm64.zip` |

### Linux / macOS

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

### Windows

```powershell
# 例: Windows amd64
$Version = "1.0.0"
$Archive = "rimo_${Version}_windows_amd64.zip"
$BinDir  = "$env:USERPROFILE\.local\bin"
Invoke-WebRequest -Uri "https://github.com/rimoapp/cli/releases/download/v${Version}/${Archive}" -OutFile $Archive
Expand-Archive -Path $Archive -DestinationPath . -Force
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Move-Item -Path .\rimo.exe -Destination $BinDir -Force
rimo version
```

インストール前にチェックサムを検証:

```powershell
Invoke-WebRequest -Uri "https://github.com/rimoapp/cli/releases/download/v${Version}/checksums.txt" -OutFile "checksums.txt"
$line = (Select-String -Path checksums.txt -Pattern $Archive).Line
$expected = ($line.Trim() -split '\s+')[0]
$actual = (Get-FileHash -Algorithm SHA256 -Path $Archive).Hash.ToLower()
if ($expected -ne $actual) { throw "checksum mismatch" }
```

`%USERPROFILE%\.local\bin` が `PATH` に含まれていない場合、PowerShell から追加できます:

```powershell
[Environment]::SetEnvironmentVariable(
    "PATH",
    "$env:USERPROFILE\.local\bin;" + [Environment]::GetEnvironmentVariable("PATH", "User"),
    "User"
)
```

変更を反映するため、新しい PowerShell ウィンドウを開いてください。

## アップグレード

```bash
rimo upgrade           # 最新リリースへアップグレード
rimo upgrade --check   # インストールせずに、新しいバージョンがあるか報告
```

または、インストールスクリプトを再実行します（常に最新リリースを取得します）:

```bash
# Linux / macOS
curl -fsSL https://rimo.app/cli/install.sh | sh
```

```powershell
# Windows
irm https://rimo.app/cli/install.ps1 | iex
```

すべてのフラグについては [`rimo upgrade`](commands.md#rimo-upgrade) を参照してください。

## アンインストール

### Linux / macOS

```bash
rimo auth logout          # 保存されたトークンを失効・削除（任意）
rm ~/.local/bin/rimo      # バイナリを削除
rm -rf ~/.config/rimo     # 設定を削除（任意）
```

### Windows

```powershell
rimo auth logout                                     # 保存されたトークンを失効・削除（任意）
Remove-Item "$env:USERPROFILE\.local\bin\rimo.exe"   # バイナリを削除
Remove-Item -Recurse "$env:USERPROFILE\.config\rimo" # 設定を削除（任意）
```

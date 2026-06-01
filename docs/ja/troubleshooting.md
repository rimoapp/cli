# トラブルシューティング

[English](../en/troubleshooting.md) | [日本語](../ja/troubleshooting.md)

## `rimo: command not found`

インストール先が `PATH` に含まれていません。インストーラーが追加すべき行を表示します。
デフォルトの場所の場合:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

シェルのプロファイル（`~/.zshrc`、`~/.bashrc` など）に追加し、シェルを再起動してください。

## `rimo` 実行時に `permission denied`

バイナリに実行権限があるか確認してください:

```bash
chmod +x ~/.local/bin/rimo
```

## macOS: 「"rimo" がマルウェアでないことを Apple では確認できません」

初回実行時に Gatekeeper がブロックする場合は、隔離属性を削除してください:

```bash
xattr -d com.apple.quarantine ~/.local/bin/rimo
```

（`curl … | sh` ワンライナーでインストールしたバイナリには通常 quarantine が付かないため、
これに遭遇するのはブラウザで手動ダウンロードした場合がほとんどです。）

## `rimo auth login` でブラウザが開かない

ブラウザが自動で開かない場合は、`--no-browser` を指定してください:

```bash
rimo auth login --no-browser
```

`rimo` が URL を出力するので、別の端末（スマートフォンや他のラップトップなど）で
その URL を開いてください。サインインすると、ページに短いコードが表示されるので、
それをターミナルに貼り付けます。

## `--no-browser` のコードが拒否される / 期限切れになる

承認ページに表示される短いコードは短時間で失効します。
`rimo auth login --no-browser` を再実行して新しい URL を取得し、ブラウザでの
操作を速やかに完了してください。コードは大文字小文字を区別し、`XXXX-XXXX` の
形式です。表示されたとおりに正確に貼り付けてください。

## プロキシ / ファイアウォール環境

CLI は `https://rimo.app` と（インストール / アップグレード用に）`https://api.github.com`
と通信します。両方への HTTPS 送信を許可し、プロキシを使う場合は `HTTPS_PROXY` 環境変数を
設定してください。

## 古いバージョンが実行され続ける

`PATH` 上で最初に見つかるバイナリを確認してください:

```bash
which -a rimo
rimo version
```

古いコピーを削除するか、インストールスクリプトを再実行して `~/.local/bin/rimo` を更新します。

## インストール時のチェックサム不一致

ダウンロードしたアーカイブが `checksums.txt` と一致しませんでした。多くは部分的 / 破損した
ダウンロードが原因なので、インストールを再実行してください。解消しない場合は
[セキュリティポリシー](../../SECURITY.md) から報告してください。

解決しない場合は、`rimo version`・OS・実行したコマンドと出力を添えて、このリポジトリで
issue を作成してください。

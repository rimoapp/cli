# コマンド

[English](../en/commands.md) | [日本語](../ja/commands.md)

すべての `rimo` コマンドの完全なリファレンスです。インストールについては
[インストール](installation.md) を、出力の取り決めとエラー形式については
[出力とエラー](output-and-errors.md) を参照してください。

**出力の取り決め。** すべてのコマンドはデフォルトで stdout に JSON を出力します。
一部の人間向けコマンドは成功時にプレーンテキストを出力します（エラーは常に JSON）:
`rimo version`、`rimo upgrade`、`rimo note ask`、および `--transcript` /
`--document` / `--full` / `--document-id` を指定した `rimo note get`。

**グローバルフラグ**（すべてのコマンドに適用）:

| フラグ | 説明 |
|------|-------------|
| `--account` | 使用するアカウントのエイリアス（設定の `active_account` を上書き） |
| `--fields` | 含めるフィールド: `""` (すべて)、`"compact"`、または `"f1,f2"` |
| `--excludes` | 出力から除外するフィールド（カンマ区切り） |
| `--dry-run` | 副作用なしでコマンドをシミュレーション（書き込み系のみ） |

---

## 認証

### `rimo auth login`

ブラウザベースのログインで Rimo に認証します。

**構文**

```
rimo auth login
```

（トップレベルの `rimo login` としても利用できます。）

**フロー**

デフォルトでは、`rimo auth login` はブラウザを開きます:

1. 既定のブラウザを開き、この CLI の認可ページに遷移します。
2. 必要に応じてサインインし、リクエストを承認するのを待機します。
3. アクセストークンとリフレッシュトークンを OS の認証情報ストアに安全に保存します。
4. `~/.config/rimo/config.yaml` にエイリアスを登録し、アクティブに設定します。

**`--no-browser` フロー**

ブラウザが利用できない環境向け:

1. URL を stderr に出力します。
2. 別の端末でその URL を開き、必要に応じてサインインしてリクエストを承認します。
   ページに短いコードが表示されます。
3. プロンプトでそのコードをターミナルに貼り付けます。
4. 上記と同様にトークンを保存し、エイリアスを登録します。

**フラグ**

| フラグ | 説明 |
|------|-------------|
| `--no-browser` | 別の端末で開く URL を出力し、表示された短いコードをターミナルに貼り付ける形式でログインします。 |

**エイリアスの生成。** メールアドレスと組織名から自動生成されます:

| メール | 組織名 | 生成されるエイリアス |
|-------|----------|-----------------|
| `alice@rimo.app` | （空） | `alice-rimo-personal` |
| `alice@rimo.app` | "Client A" | `alice-rimo-client-a` |
| `bob@gmail.com` | "Acme Co" | `bob-gmail-acme-co` |

同じ `(user_id, org_id)` で再ログインすると、元のエイリアスを維持してメタデータを
更新します。

**出力（stdout, JSON）**

```json
{
  "status": "logged_in",
  "alias": "alice-rimo-personal",
  "email": "alice@rimo.app",
  "name": "Alice",
  "org": "Personal"
}
```

---

### `rimo auth logout`

トークンを失効させ、設定と認証情報ストアからアカウントを削除します。

**構文**

```
rimo auth logout [--account <alias|email|org>]
```

`--account` を省略した場合、アクティブなアカウントがログアウトされます。アクティブな
アカウントが設定されていない場合は、保存済みアカウントを一覧表示し、`--account` での
指定を求めます。

**挙動**

1. 入力を正確なエイリアスに解決します（エイリアス → メール → 組織名の順）。
2. 失効エンドポイントを呼び出します（ベストエフォート。失敗は stderr に記録されますが、
   中断はしません）。
3. OS の認証情報ストアからトークンを削除します。
4. `config.yaml` からアカウントを削除します。アクティブだった場合は、アクティブ
   アカウントがクリアされます（自動昇格はありません）。

**出力（stdout, JSON）**

```json
{
  "status": "logged_out",
  "alias": "alice-rimo-personal",
  "active_account": ""
}
```

---

### `rimo auth status`

保存済みのすべてのアカウントとそのトークン状態を一覧表示します。

**構文**

```
rimo auth status
```

**出力（stdout, JSON）**

```json
{
  "active_account": "alice-rimo-personal",
  "accounts": [
    {
      "alias": "alice-rimo-personal",
      "email": "alice@rimo.app",
      "name": "Alice",
      "org": "Personal",
      "active": true,
      "token_status": "valid"
    }
  ]
}
```

`token_status` の値: `valid`、`expiring_soon`、`expired`、`unknown`
（トークンの有効期限を判定できなかった）。

---

### `rimo auth switch`

アクティブなアカウントを切り替えます。

**構文**

```
rimo auth switch <alias|email|org-name> [--org <org-name>]
```

`rimo auth use` としても利用できます。

**解決の順序**

1. `alias` の完全一致。
2. `email` の一致 — `email` が複数の組織に対応し、`--org` が指定されていない場合はエラーになります。
3. `org-name` の一致。 - 現在有効なメールアドレスが所属する組織が優先されます。

**フラグ**

| フラグ | 説明 |
|------|-------------|
| `--org` | メールアドレスが複数の組織に登録されている場合に曖昧さを解消するための組織名。 |

**例**

```bash
rimo auth switch alice-rimo-personal                       # 完全なエイリアス
rimo auth switch alice@rimo.app                            # メールで指定（複数組織の場合はエラー）
rimo auth switch "Client A"                                # 組織名で指定
rimo auth switch alice@rimo.app --org "Rimo Engineering"   # メール + 組織で曖昧さを解消
```

**出力（stdout, JSON）**

```json
{
  "status": "switched",
  "alias": "alice-rimo-client-a",
  "email": "alice@rimo.app",
  "name": "Alice",
  "org": "Client A"
}
```

---

## note

ノートコマンドが返す内容はアクセス権によって異なります:

- `rimo note list`（デフォルト）は**自分が所有する**ノートのみを返します。
- `rimo note list --attended` は**自分が参加した**ノートを返します。
- URL のみで共有された（所有や参加によらない）ノートはどの一覧にも**表示されません**が、
  ID があれば `rimo note get <id>` で直接取得できます。
- アクセスできないノートに対する `rimo note get` は、ノートの存在を明かさずに
  not-found エラーを返します。

### `rimo note list`

ノートを一覧表示します。

**構文**

```
rimo note list [--attended] [--page-size <int>] [--page-token <string>]
```

**デフォルトモード。** 認証済みユーザーが作成したノートを一覧表示します。

**`--attended` モード。** 認証済みユーザーが参加したノートを一覧表示します。

どちらのモードも `--page-size` と `--page-token` でページネーションできます。

**フラグ**

| フラグ | 型 | デフォルト | 説明 |
|------|------|---------|-------------|
| `--attended` | bool | `false` | 参加したノートを一覧表示 |
| `--page-size` | int | `0` | ページサイズ（`0` の場合はサーバー側のデフォルトに従う） |
| `--page-token` | string | `""` | 前回の呼び出しの `next_page_token` |

**例**

```bash
rimo note list
rimo note list --fields id,title,created_at
rimo note list --page-size 50
rimo note list --attended --page-size 50
rimo note list --attended --page-size 50 --page-token "eyJpZCI6..."
```

**出力（stdout, JSON）**

```json
{
  "notes": [
    {
      "id": "note_abc123",
      "title": "Weekly sync",
      "created_at": "2026-05-12T08:30:00Z",
      "owner": { "email": "alice@rimo.app" }
    }
  ],
  "next_page_token": "..."
}
```

---

### `rimo note get`

単一のノートを取得します。デフォルトのではメタデータのみが JSON 形式で出力され、追加のフラグを指定することによって文字起こしや議事録コンテンツを取得することができます。

**構文**

```
rimo note get <note_id> [flags]
```

**フラグ**

| フラグ | 説明 |
|------|-------------|
| `--transcript` | 文字起こしを `Speaker: content` 形式のプレーンテキストで出力。 |
| `--document` | メインのドキュメントを Markdown のプレーンテキストで出力。 |
| `--full` | 文字起こしに続けてメインのドキュメントを出力。 |
| `--list-documents` | ノートに添付されたドキュメントを一覧表示（JSON）。 |
| `--document-id <id>` | ID で指定したドキュメントの Markdown を出力。 |

**注意点**

- `--list-documents` / `--document-id` は `--transcript` / `--document` / `--full` と
  併用できません。

- 各フラグ（`--transcript`、`--document`、`--full`、`--document-id`）は stdout に 
JSON ではなく、プレーンテキストを出力します。

**例**

```bash
rimo note get note_abc123                          # メタデータ JSON
rimo note get note_abc123 --transcript             # プレーンテキストの文字起こし
rimo note get note_abc123 --document               # 主ドキュメントの Markdown
rimo note get note_abc123 --full                    # 文字起こし + ドキュメント
rimo note get note_abc123 --list-documents         # ドキュメントの JSON 一覧
rimo note get note_abc123 --document-id doc_xyz    # 特定ドキュメントの Markdown
rimo note get note_abc123 --fields id,title        # JSON メタデータをフィルタ
```

**エラー**

エラーの JSON 形式と終了コードについては [出力とエラー](output-and-errors.md) を参照してください。

---

### `rimo note search`

意味的類似度（デフォルト）またはキーワードフィルターでノートを検索します。
`rimo note list` と同じ `{notes, total_count}` 形式の JSON を返します。一覧ではなく
統合された回答が欲しい場合は [`rimo note ask`](#rimo-note-ask) を使ってください。

**構文**

```
rimo note search <query> [--mode=semantic|filter] [flags]
```

**フラグ**

| フラグ | 説明 |
|------|-------------|
| `--mode` | `semantic`（デフォルト）は意味でノートをランク付けし、`filter` はページネーション付きのキーワード検索を行う。 |
| `--limit` | `--mode=semantic` の最大結果数。 |
| `--page` | `--mode=filter` のページ番号（1 始まり、デフォルト 1）。 |
| `--per` | `--mode=filter` のページサイズ（デフォルト 10）。 |
| `--content-type` | `--mode=filter` を次のいずれかに限定: `all` `transcripts` `headings` `annotations` `title` `document`。 |

**出力**

stdout に JSON `{notes: [...], total_count: <int>}` を出力します。`Fetch a note:` の
ヒントは **stderr** に出力されるため、stdout は `| jq` 向けにパイプがクリーンなまま
保たれます。

```json
{
  "notes": [
    { "id": "wn9K...", "title": "Release plan: Q3 launch", "owner_name": "Alice Smith", "held_at": "2026-04-28T09:21:00Z" }
  ],
  "total_count": 12
}
```

フィルターモードは各結果に `snippet`、`channel_id`、`owner_name`、`held_at`、
`created_at` を含みます。セマンティックモードは結果ごとのメタデータが少ないため
`id` と `title` のみを含みます。

**例**

```bash
rimo note search "release plan"                                # セマンティック（デフォルト）
rimo note search "release plan" --limit 5
rimo note search "release" --mode=filter --per 5 --content-type transcripts
rimo note search "release" --mode=filter | jq '.notes[].id'
```

**エラー**

エラーの JSON 形式と終了コードについては [出力とエラー](output-and-errors.md) を参照してください。

---

### `rimo note ask`

自然言語で質問すると、ノートから AI が統合した回答を返します。AI による回答を生成する
唯一のコマンドです。

**構文**

```
rimo note ask <question>
```

フラグはありません。モデルはサーバー側で固定されています。

**出力（プレーンテキスト、ストリーミング）**

```
The release is planned for Q3, with grandfathered pricing for existing
annual contracts until renewal.

Sources:
  - wn9K36p46RKJKaktjDvA  Pricing sync 2026-04-28
  - 3K72YiEy2dEius6xpTHy  Q3 planning offsite

Fetch a note:
  rimo note get wn9K36p46RKJKaktjDvA --document      # markdown
  rimo note get wn9K36p46RKJKaktjDvA --transcript    # speaker: text
  rimo note get wn9K36p46RKJKaktjDvA                 # metadata JSON
```

回答はモデルが生成するにつれてストリーミングされます。`Sources:` ブロックが正式な
引用元の表示です。

**使い分け**

- `rimo note search` — 返されたノートを自分で開いて読みたいとき。
- `rimo note ask` — 回答に対する答えを引き出すために開きたいとき。

**例**

```bash
rimo note ask "what did we decide about Q3 pricing?"
rimo note ask "今週の議事録を要約して"
```

**エラー**

エラーの JSON 形式と終了コードについては [出力とエラー](output-and-errors.md) を参照してください。

---

## その他

### `rimo version`

CLI のバージョンを出力します。

**構文**

```
rimo version
```

**出力（stdout, プレーンテキスト）**

```
rimo version 1.0.0
```

---

### `rimo upgrade`

インストール済みバイナリを最新リリースへアップグレードします。

`rimo upgrade` は常に**最新**リリースをインストールします — 古いバージョンへの固定（ピン留め）やダウングレードを行うフラグはありません。リリースアーカイブは HTTPS でダウンロードされ、実行中のバイナリを置き換える前にリリースの `checksums.txt` でチェックサムが検証されます。ログインは不要です。

**構文**

```
rimo upgrade [--check] [--use-sudo]
```

**フラグ**

| フラグ | 説明 |
|------|-------------|
| `--check` | 更新が利用可能かどうかを報告する。ダウンロードやインストールはしない。 |
| `--use-sudo` | インストールパスが書き込み不可の場合、`sudo install -m 0755` で再試行する。オプトイン。 |

**出力（stdout, プレーンテキスト）**

次のいずれか:

```
Already on the latest version (v1.0.0).
Update available: v1.0.0 → v1.1.0. Run: rimo upgrade
Upgraded rimo from v1.0.0 → v1.1.0.
```

進捗メッセージは **stderr** に出力されるため、stdout をキャプチャするスクリプトには
最終的なステータス行のみが表示されます。

**例**

```bash
rimo upgrade --check                   # 新しいリリースはあるか？
rimo upgrade                           # 最新
sudo rimo upgrade --use-sudo           # root 所有のインストールディレクトリ向けに sudo で再試行
```

**エラー**

エラーの JSON 形式と終了コードについては [出力とエラー](output-and-errors.md) を参照してください。

**起動時の更新通知**

呼び出しのたびに、ノンブロッキングのバックグラウンドバージョンチェックが実行されます。
新しいリリースが利用可能な場合、1 行が **stderr** に出力されます（stdout には決して
出力されません）:

```
rimo: update available v1.0.0 → v1.1.0 (run: rimo upgrade)
```

この通知は、バイナリがローカルの開発ビルドである場合、`RIMO_NO_UPDATE_CHECK` が
設定されている場合、`CI` が設定されている場合、または `upgrade`、`version`、`--help` の
呼び出しでは抑制されます。結果は 24 時間キャッシュされます。

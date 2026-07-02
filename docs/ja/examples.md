# 使用例

`rimo` の一般的なワークフローの実用的なレシピです。

## シェルパイプライン

### 直近 10 件のノートをタイトルのみで一覧表示

```bash
rimo note list --fields id,title,created_at | jq '.notes[:10]'
```

### 出席したミーティングのノート ID をすべて取得

```bash
rimo note list --attended --fields id | jq -r '.notes[].id'
```

### すべてのノートをページネーションで取得

```bash
PAGE_TOKEN=""
while true; do
  RESULT=$(rimo note list --page-size 50 ${PAGE_TOKEN:+--page-token "$PAGE_TOKEN"})
  echo "$RESULT" | jq '.notes[].title'
  PAGE_TOKEN=$(echo "$RESULT" | jq -r '.next_page_token // empty')
  [ -z "$PAGE_TOKEN" ] && break
done
```

### 検索して上位結果のトランスクリプトを取得

```bash
NOTE_ID=$(rimo note search "Q3 リリース" --limit 1 | jq -r '.notes[0].id')
rimo note get "$NOTE_ID" --transcript
```

### キーワードに一致するノートのタイトルをすべて抽出

```bash
rimo note search "料金" --mode=filter --per 20 | jq -r '.notes[].title'
```

---

## AI エージェントの活用

### 直近のミーティングについて質問する

```bash
rimo note ask "先週のスプリントレビューで出たアクションアイテムは何ですか？"
```

### 日本語で要約を取得

```bash
rimo note ask "今週のミーティングの重要な決定事項を日本語でまとめてください"
```

### 概念でノートを検索（キーワードなしで）

```bash
rimo note search "顧客オンボーディングの課題" --mode=semantic --limit 5
```

---

## CI / スクリプト活用

### 個人用 APIキーで CI 認証する

ブラウザログインを省略できます。Web アプリで作成した `rimo_pat_…` キーを（CI のシークレットとして）`RIMO_API_KEY` に設定します。[個人用 APIキー](personal-api-keys.md) を参照してください。

```bash
export RIMO_API_KEY="$RIMO_API_KEY"   # CI のシークレットストアから
rimo note list --fields id,title
```

### コマンド実行前に認証を確認

```bash
AUTH=$(rimo auth status)
STATUS=$(echo "$AUTH" | jq -r '.accounts[0].token_status')
if [ "$STATUS" != "valid" ]; then
  echo "Rimo の認証が切れています — 再認証してください" >&2
  exit 1
fi
```

### CI で更新通知を抑制

```bash
export CI=true
rimo note list
```

### 大規模なパイプライン向けにコンパクトな出力を使用

```bash
rimo note list --fields compact | jq '.notes[] | {id, title}'
```

---

## 複数アカウントの活用

### 仕事用アカウントに切り替えてノートを一覧表示

```bash
rimo auth switch alice@company.com --org "Engineering"
rimo note list --fields id,title
```

### 切り替えなしで特定のアカウントに対してコマンドを実行

```bash
rimo note list --account alice-company-engineering --fields id,title
```

### すべてのアカウントの状態を確認

```bash
rimo auth status | jq '.accounts[] | {alias, token_status}'
```

---

## MCP エージェントレシピ（Claude Code）

`.mcp.json` で `rimo mcp` を設定した後、Claude Code に自然言語で問いかけできます:

```
今週の Rimo ノートを要約して、未解決のアクションアイテムをリストアップして。
```

```
Q3 リリース計画についての Rimo ノートを見つけて、1 段落で要約して。
```

```
Rimo ノート <id> の全文字起こしを取得して、重要な決定事項を抽出して。
```

```
予算承認に関する Rimo ノートを検索して、最終的に承認された金額を教えて。
```

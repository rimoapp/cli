# Examples

Practical recipes for common `rimo` workflows.

## Shell pipelines

### List the 10 most recent notes (titles only)

```bash
rimo note list --fields id,title,created_at | jq '.notes[:10]'
```

### Get all note IDs from attended meetings

```bash
rimo note list --attended --fields id | jq -r '.notes[].id'
```

### Paginate through all your notes

```bash
PAGE_TOKEN=""
while true; do
  RESULT=$(rimo note list --page-size 50 ${PAGE_TOKEN:+--page-token "$PAGE_TOKEN"})
  echo "$RESULT" | jq '.notes[].title'
  PAGE_TOKEN=$(echo "$RESULT" | jq -r '.next_page_token // empty')
  [ -z "$PAGE_TOKEN" ] && break
done
```

### Search and then fetch the top result's transcript

```bash
NOTE_ID=$(rimo note search "Q3 release" --limit 1 | jq -r '.notes[0].id')
rimo note get "$NOTE_ID" --transcript
```

### Extract all note titles matching a keyword

```bash
rimo note search "pricing" --mode=filter --per 20 | jq -r '.notes[].title'
```

---

## AI agent use cases

### Ask a question about recent meetings

```bash
rimo note ask "what action items came out of last week's sprint review?"
```

### Summarize in Japanese

```bash
rimo note ask "今週のミーティングの重要な決定事項を日本語でまとめてください"
```

### Find notes about a concept (no exact keyword)

```bash
rimo note search "customer onboarding friction" --mode=semantic --limit 5
```

---

## CI / scripting

### Authenticate in CI with a personal API key

Skip the browser login entirely — set `RIMO_API_KEY` to a `rimo_pat_…` key from the web app (stored as a CI secret). See [Personal API keys](personal-api-keys.md).

```bash
export RIMO_API_KEY="$RIMO_API_KEY"   # from your CI secret store
rimo note list --fields id,title
```

### Check authentication in CI before running commands

```bash
AUTH=$(rimo auth status)
STATUS=$(echo "$AUTH" | jq -r '.accounts[0].token_status')
if [ "$STATUS" != "valid" ]; then
  echo "Rimo auth expired — re-authenticate" >&2
  exit 1
fi
```

### Suppress update notices in CI

```bash
export CI=true
rimo note list
```

### Compact output for large pipelines

```bash
rimo note list --fields compact | jq '.notes[] | {id, title}'
```

---

## Multiple accounts

### Switch to a work account and list notes

```bash
rimo auth switch alice@company.com --org "Engineering"
rimo note list --fields id,title
```

### Run a command against a specific account without switching

```bash
rimo note list --account alice-company-engineering --fields id,title
```

### Check all account statuses

```bash
rimo auth status | jq '.accounts[] | {alias, token_status}'
```

---

## MCP agent recipes (Claude Code)

Once `rimo mcp` is wired in via `.mcp.json`, you can prompt Claude Code naturally:

```
Summarize my Rimo notes from this week and list any open action items.
```

```
Find Rimo notes about the Q3 release plan and give me a one-paragraph summary.
```

```
Get the full transcript of Rimo note <id> and extract the key decisions.
```

```
Search my Rimo notes for anything about budget approvals, then answer:
what was the final approved amount?
```

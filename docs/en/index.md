---
layout: home

hero:
  name: "Rimo CLI"
  text: "Search, fetch, and ask questions about your meetings — from the terminal."
  tagline: "A single binary. JSON by default. Built for humans and AI agents alike."
  actions:
    - theme: brand
      text: Get Started
      link: /en/getting-started
    - theme: alt
      text: Command Reference
      link: /en/commands
---

<div class="home-custom">

<!-- ─── WHY ──────────────────────────────────────────────────── -->
<div class="hs">
  <div class="hs-eye">What it does</div>
  <h2 class="hs-heading">Everything in your meeting history,<br>one command away</h2>
  <p class="hs-sub">Rimo CLI connects your terminal — and your AI agent — directly to your Rimo Voice meeting notes.</p>

  <div class="problem-grid">
    <div class="problem-card">
      <span class="prob-num">01 / Search</span>
      <div class="prob-title">Find notes by meaning, not just keywords</div>
      <p class="prob-body">Semantic search ranks notes by meaning. Keyword filter searches across transcripts, headings, and documents. Both return clean JSON you can pipe directly into <code>jq</code> or any agent.</p>
    </div>
    <div class="problem-card">
      <span class="prob-num">02 / Fetch</span>
      <div class="prob-title">Get transcripts and documents as plain text</div>
      <p class="prob-body">Pull metadata, full transcripts, or AI-generated documents from any note you have access to. Content flags print plain text so you can pipe output straight into your workflow without parsing JSON.</p>
    </div>
    <div class="problem-card">
      <span class="prob-num">03 / Ask</span>
      <div class="prob-title">Get a synthesised answer across all your notes</div>
      <p class="prob-body"><code>rimo note ask</code> queries your entire note history and streams an AI-generated answer with cited sources. Use it when you want a direct answer rather than a list of notes to read yourself.</p>
    </div>
  </div>
</div>


<!-- ─── QUICKSTART ───────────────────────────────────────────── -->
<div class="hs">
  <div class="hs-eye">Quick start</div>
  <h2 class="hs-heading">Up and running<br>in three commands</h2>

  <div class="qs-steps">
    <div class="qs-step">
      <div class="qs-step-num">01</div>
      <div>
        <div class="qs-step-title">Install</div>
        <div class="qs-step-body">One command on Linux, macOS, or Windows. No admin rights required. The script verifies the checksum before placing the binary on your <code>PATH</code>.<br><br><code>curl -fsSL https://rimo.app/cli/install.sh | sh</code></div>
      </div>
    </div>
    <div class="qs-step">
      <div class="qs-step-num">02</div>
      <div>
        <div class="qs-step-title">Log in</div>
        <div class="qs-step-body">Browser-based login stores tokens in your OS credential store. On headless machines, use <code>--no-browser</code> and paste a short code instead.<br><br><code>rimo auth login</code></div>
      </div>
    </div>
    <div class="qs-step">
      <div class="qs-step-num">03</div>
      <div>
        <div class="qs-step-title">Search your notes</div>
        <div class="qs-step-body">Run your first search or question. Pipe the JSON output into <code>jq</code>, feed it to an agent, or fetch a full transcript to read directly.<br><br><code>rimo note search "Q3 release plan"</code></div>
      </div>
    </div>
  </div>
</div>

<!-- ─── CTA ──────────────────────────────────────────────────── -->
<div class="home-cta">
  <h2 class="home-cta-heading">Ready to get started?</h2>
  <p class="home-cta-sub">Install in one command. Read the full guide or jump straight to the command reference.</p>
  <div class="cta-buttons">
    <a href="./getting-started" class="cta-btn-primary">Get Started →</a>
    <a href="./mcp" class="cta-btn-secondary">MCP Server Setup</a>
  </div>
</div>

</div>

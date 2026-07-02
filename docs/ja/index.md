---
layout: home

hero:
  name: "Rimo CLI"
  text: "会議ノートの検索・取得・質問を、ターミナルから。"
  tagline: "シングルバイナリ。デフォルトで JSON 出力。人間にも AI エージェントにも対応。"
  actions:
    - theme: brand
      text: はじめる
      link: /getting-started
    - theme: alt
      text: コマンドリファレンス
      link: /commands
---

<div class="home-custom">

<!-- ─── WHY ──────────────────────────────────────────────────── -->
<div class="hs">
  <div class="hs-eye">できること</div>
  <h2 class="hs-heading">会議の記録すべてに、<br>1 コマンドでアクセス</h2>
  <p class="hs-sub">Rimo CLI は、ターミナルと AI エージェントを Rimo Voice の会議ノートに直接つなぎます。</p>

  <div class="problem-grid">
    <div class="problem-card">
      <span class="prob-num">01 / 検索</span>
      <div class="prob-title">キーワードだけでなく、意味でノートを探す</div>
      <p class="prob-body">セマンティック検索は意味でノートをランク付けします。キーワードフィルターはトランスクリプト・見出し・ドキュメントを横断検索します。どちらもクリーンな JSON を返すので、<code>jq</code> やエージェントにそのまま渡せます。</p>
    </div>
    <div class="problem-card">
      <span class="prob-num">02 / 取得</span>
      <div class="prob-title">トランスクリプトとドキュメントをプレーンテキストで取得</div>
      <p class="prob-body">アクセス権のあるノートからメタデータ・全文トランスクリプト・AI 生成ドキュメントを取得できます。コンテンツフラグはプレーンテキストを出力するので、JSON を解析せずそのままワークフローに渡せます。</p>
    </div>
    <div class="problem-card">
      <span class="prob-num">03 / 質問</span>
      <div class="prob-title">全ノートを横断して AI が回答を合成</div>
      <p class="prob-body"><code>rimo note ask</code> はノート全体を検索し、引用付きの AI 回答をストリーミングで返します。ノートの一覧を自分で読みたいときではなく、直接的な答えが欲しいときに使います。</p>
    </div>
  </div>
</div>


<!-- ─── QUICKSTART ───────────────────────────────────────────── -->
<div class="hs">
  <div class="hs-eye">クイックスタート</div>
  <h2 class="hs-heading">3 コマンドで<br>使い始められる</h2>

  <div class="qs-steps">
    <div class="qs-step">
      <div class="qs-step-num">01</div>
      <div>
        <div class="qs-step-title">インストール</div>
        <div class="qs-step-body">Linux・macOS・Windows いずれも 1 コマンド。管理者権限不要。スクリプトがチェックサムを検証してからバイナリを <code>PATH</code> に配置します。<br><br><code>curl -fsSL https://rimo.app/cli/install.sh | sh</code></div>
      </div>
    </div>
    <div class="qs-step">
      <div class="qs-step-num">02</div>
      <div>
        <div class="qs-step-title">ログイン</div>
        <div class="qs-step-body">ブラウザベースのログインでトークンを OS の認証情報ストアに保存します。ヘッドレス環境では <code>--no-browser</code> を使い、短いコードを貼り付けるだけです。<br><br><code>rimo auth login</code></div>
      </div>
    </div>
    <div class="qs-step">
      <div class="qs-step-num">03</div>
      <div>
        <div class="qs-step-title">ノートを検索</div>
        <div class="qs-step-body">最初の検索や質問を実行してみましょう。JSON 出力を <code>jq</code> にパイプしたり、エージェントに渡したり、全文トランスクリプトをそのまま読んだりできます。<br><br><code>rimo note search "Q3 リリース計画"</code></div>
      </div>
    </div>
  </div>
</div>

<!-- ─── CTA ──────────────────────────────────────────────────── -->
<div class="home-cta">
  <h2 class="home-cta-heading">さっそく始めてみましょう</h2>
  <p class="home-cta-sub">1 コマンドでインストール。ガイドを読むか、コマンドリファレンスへ直接どうぞ。</p>
  <div class="cta-buttons">
    <a href="./getting-started" class="cta-btn-primary">はじめる →</a>
    <a href="./mcp" class="cta-btn-secondary">MCP サーバーのセットアップ</a>
  </div>
</div>

</div>

import { defineConfig, type Plugin } from 'vitepress'

// The markdown under docs/ is written to be browsed on GitHub. Adapt it for
// the site at build time instead of maintaining a second copy:
// - drop the per-page language-switch line (the site header has a locale menu)
// - point links that leave docs/ (../../foo) at the GitHub repo instead
const repoBlobUrl = 'https://github.com/rimo/cli/blob/main'

const githubMarkdownForSite = (): Plugin => ({
  name: 'rimo:github-markdown-for-site',
  enforce: 'pre',
  transform(code, id) {
    if (!id.endsWith('.md')) return
    return code
      .replace(/^\[English\]\([^)]+\) \| \[日本語\]\([^)]+\)\s+/m, '')
      .replace(/\]\(\.\.\/\.\.\/([^)]+)\)/g, `](${repoBlobUrl}/$1)`)
  },
})

const enSidebar = [
  {
    text: 'Getting Started',
    items: [
      { text: 'Introduction', link: '/en/getting-started' },
      { text: 'Installation', link: '/en/installation' },
      { text: 'Authentication', link: '/en/authentication' },
      { text: 'API Keys', link: '/en/personal-api-keys' },
    ],
  },
  {
    text: 'Reference',
    items: [
      { text: 'Commands', link: '/en/commands' },
      { text: 'Configuration', link: '/en/configuration' },
      { text: 'Output & Errors', link: '/en/output-and-errors' },
    ],
  },
  {
    text: 'Integrations',
    items: [
      { text: 'MCP Server', link: '/en/mcp' },
    ],
  },
  {
    text: 'Resources',
    items: [
      { text: 'Examples', link: '/en/examples' },
      { text: 'FAQ', link: '/en/faq' },
      { text: 'Troubleshooting', link: '/en/troubleshooting' },
    ],
  },
]

const jaSidebar = [
  {
    text: 'はじめに',
    items: [
      { text: 'イントロダクション', link: '/getting-started' },
      { text: 'インストール', link: '/installation' },
      { text: '認証', link: '/authentication' },
      { text: 'APIキー', link: '/personal-api-keys' },
    ],
  },
  {
    text: 'リファレンス',
    items: [
      { text: 'コマンド', link: '/commands' },
      { text: '設定', link: '/configuration' },
      { text: '出力とエラー', link: '/output-and-errors' },
    ],
  },
  {
    text: 'インテグレーション',
    items: [
      { text: 'MCP サーバー', link: '/mcp' },
    ],
  },
  {
    text: 'リソース',
    items: [
      { text: '使用例', link: '/examples' },
      { text: 'よくある質問', link: '/faq' },
      { text: 'トラブルシューティング', link: '/troubleshooting' },
    ],
  },
]

export default defineConfig({
  title: 'Rimo CLI',
  description: 'Command-line interface for the Rimo Voice platform',
  base: '/cli/',

  // Repo layout is docs/ja + docs/en (GitHub-browsable); the site serves
  // Japanese at the root and English under /en/.
  rewrites: {
    'ja/:page*': ':page*',
  },

  vite: {
    plugins: [githubMarkdownForSite()],
  },

  head: [
    ['link', { rel: 'icon', href: '/cli/favicon.ico' }],
  ],

  locales: {
    root: {
      label: '日本語',
      lang: 'ja-JP',
      themeConfig: {
        nav: [
          { text: 'ガイド', link: '/getting-started' },
          { text: 'コマンド', link: '/commands' },
          { text: 'MCP サーバー', link: '/mcp' },
          { text: 'GitHub', link: 'https://github.com/rimo/cli' },
        ],
        sidebar: jaSidebar,
        lastUpdated: {
          text: '最終更新',
        },
        docFooter: {
          prev: '前のページ',
          next: '次のページ',
        },
        outline: {
          label: 'このページの内容',
        },
        returnToTopLabel: 'トップに戻る',
        sidebarMenuLabel: 'メニュー',
        darkModeSwitchLabel: 'テーマ',
      },
    },
    en: {
      label: 'English',
      lang: 'en-US',
      themeConfig: {
        nav: [
          { text: 'Guide', link: '/en/getting-started' },
          { text: 'Commands', link: '/en/commands' },
          { text: 'MCP Server', link: '/en/mcp' },
          { text: 'GitHub', link: 'https://github.com/rimo/cli' },
        ],
        sidebar: enSidebar,
        lastUpdated: {
          text: 'Last updated',
        },
        docFooter: {
          prev: 'Previous',
          next: 'Next',
        },
      },
    },
  },

  themeConfig: {
    logo: { src: '/logo.png', alt: 'Rimo' },
    search: {
      provider: 'local',
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/rimo/cli' },
    ],
    footer: {
      message: 'Use of Rimo CLI is governed by the <a href="https://rimo.app/policies/terms">Rimo Terms of Service</a>.',
      copyright: 'Copyright © Rimo Inc.',
    },
  },
})

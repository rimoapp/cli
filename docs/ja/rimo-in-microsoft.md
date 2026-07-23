# Microsoft Copilot で Rimo を使う

[English](../en/rimo-in-microsoft.md) | [日本語](../ja/rimo-in-microsoft.md)

Rimo を **Microsoft Copilot Studio エージェント**につなぐと、Microsoft Teams や Microsoft 365 Copilot の中で自分のミーティングノートについて質問できます。エージェントが Rimo を調べて答えてくれます。

- *「Rimo のノートで、月曜の打ち合わせで何が決まった？」*
- *「Rimo の先週のクライアント面談を要約して。」*

従業員ごとに MCP サーバーをインストールしたり設定したりする必要はありません。作成者が一度だけエージェントに Rimo を追加します。エージェントを公開した後は、各従業員がエージェントを開き、自分の Rimo アカウントでサインインします。

**追加するサーバー URL:**

```
https://mcp.rimo.app/mcp
```

> Claude または ChatGPT をお使いですか? [Claude で Rimo を使う](rimo-in-claude.md) または [ChatGPT で Rimo を使う](rimo-in-chatgpt.md) を参照してください。

---

## 組織でのセットアップの仕組み

設定は次の 3 つに分かれます。

1. **作成者**が Copilot Studio エージェントを 1 つ作成し、Rimo MCP サーバーを追加します。
2. **管理者**が公開されたエージェントを承認して組織に展開します。少人数の試験では、作成者がインストールリンクを共有することもできます。
3. 各 **エンドユーザー**がエージェントを開き、初回だけ自分の Rimo アカウントでサインインします。ユーザーが MCP URL を入力したり、作成者の Rimo 接続を共有したりすることはありません。

Rimo は **ユーザー認証**を使用します。各ユーザーが参照できるのは、自分の Rimo アカウントから見えるノートだけです。エージェントが初めて Rimo ツールを必要としたときに Copilot Studio がサインインを求め、その後はアクセスの期限切れや取り消しがない限り再認証は不要です。[Microsoft のユーザー認証ガイド](https://learn.microsoft.com/en-us/microsoft-copilot-studio/configure-enduser-authentication)を参照してください。

ここで説明する通常の組織展開では、Microsoft アカウントが同じ **Microsoft Entra テナント**に所属している必要があります。

---

## Microsoft プランを選ぶ

| Microsoft の構成 | 作成できるユーザー | 公開 | エンドユーザーに必要なもの | 利用料金 |
|---|---|---:|---|---|
| **Copilot Studio 試用版** | 試用ユーザー | 不可 | 対象外 | テストパネルのみ |
| **Microsoft 365 Copilot** — アドオン、Microsoft 365 Copilot Business、または Microsoft 365 E7 に含まれる権利 | 対象ライセンスと環境アクセスを持つユーザー | 可能 | Microsoft 365 Copilot で確実に利用するには、各ユーザーに対象となる Microsoft 365 Copilot の権利を割り当てる | 認証済み従業員向け利用はフェアユース制限内で含まれる |
| **Copilot Studio スタンドアロン クレジットパック** | 無料の Copilot Studio User License を持つ作成者 | 可能 | 公開済みエージェントのユーザーに特別な Copilot Studio ライセンスは不要。ただし Teams など利用チャネルへのアクセスは必要 | テナントの Copilot Credits |
| **Copilot Studio 従量課金または事前購入プラン** | Copilot Studio Author グループの作成者 | 可能 | 公開済みエージェントのユーザーに特別な Copilot Studio ライセンスは不要。ただし利用チャネルへのアクセスは必要 | テナントの課金プラン / Copilot Credits |
| **Copilot Studio Teams プラン** | クラシック エージェントの作成者 | Teams のみ | Teams へのアクセス | **このガイドの対象外。** Teams プランでは Power Platform コネクターが利用できず、Copilot Studio の MCP 接続は Power Platform コネクターに依存します |

プランに関する重要事項:

- **試用版では作成とテストは可能**ですが、**公開はできません**。
- スタンドアロン クレジットパックでは、管理者がテナント容量を購入し、作成者ごとに `$0` の **Copilot Studio User License** を割り当てます。
- 従量課金または事前購入プランでは、管理者が環境に課金を関連付け、作成者に **Copilot Studio Author** ロールを付与します。
- **公開済み**エージェントのユーザーに特別な Copilot Studio ライセンスは不要です。Microsoft 365 Copilot ライセンスがないユーザーの利用は、テナントの Copilot Studio 容量または従量課金として消費されます。
- Microsoft 365 Copilot ライセンスを持つ認証済み従業員の場合、Microsoft 365 Copilot、Teams、SharePoint での対象となる Copilot Studio エージェント利用は Microsoft のフェアユース制限内で含まれます。

[Copilot Studio のライセンス](https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing)、[ユーザーライセンスとアクセスの管理](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-licensing)、[Microsoft 365 Copilot のライセンスモデル](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/prerequisites#agent-capabilities-and-licensing-models)、[2026 年 6 月版 Copilot Studio Licensing Guide](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/microsoft/bade/documents/products-and-services/en-us/bizapps/Microsoft-Copilot-Studio-Licensing-Guide-June-2026-PUB.pdf) を参照してください。

### 2 アカウントでの推奨テスト

最初の組織内テストでは、次のように分けます。

- **アカウント A — 作成者兼テスト管理者**
  - 試用版ではない、公開可能な Copilot Studio の権利。
  - エージェントがある Power Platform 環境へのアクセス。
  - エージェントの所有者または編集者権限。
  - このアカウントで組織展開も承認する場合は **AI Administrator**。
- **アカウント B — 通常のエンドユーザー**
  - 同じ Entra テナントの通常の Member/User アカウント。
  - 最初のテストでは Teams へのアクセス。
  - Copilot Studio の作成者ロールや管理者ロールは不要。
  - 自分の Rimo アカウント。

Teams ではなく Microsoft 365 Copilot アプリ内でテストする場合は、最も明確にサポートされる構成としてアカウント B に Microsoft 365 Copilot ライセンスを割り当ててください。

---

## 組織に公開するためのロール

作成者がテナント管理者である必要はありません。

| 作業 | 最小のロールまたは権限 |
|---|---|
| エージェントの作成・設定・公開 | エージェントの所有者/編集者権限と、上記の Copilot Studio User License または Copilot Studio Author の権利 |
| Microsoft 365 管理センターでの承認と管理 | **AI Administrator**。Global Administrator でも可能ですが、権限が大幅に広くなります |
| Teams アプリの利用可否、自動インストール、ピン留めの管理 | **Teams Administrator** |
| 公開済みエージェントの利用 | エージェントと利用チャネルへのアクセスを持つ通常のテナントユーザー |

Microsoft は、エージェント承認に Global Administrator ではなく、最小権限の **AI Administrator** を使うことを推奨しています。[エージェント管理のロールと権限](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-roles-perms?view=o365-worldwide)を参照してください。

---

## Rimo を Copilot Studio に追加する

以下の設定は作成者が一度だけ行います。

1. [Microsoft Copilot Studio](https://copilotstudio.microsoft.com/) でエージェントを開きます。
2. **ツール（Tools）** を開きます。
3. **ツールの追加（Add a tool）→ 新しいツール（New tool）→ Model Context Protocol** を選びます。
4. 次のように入力します。
   - **サーバー名（Server name）:** `Rimo`
   - **サーバーの説明（Server description）:** `サインイン中のユーザーの Rimo ミーティングノート、トランスクリプト、ドキュメント、参加者、チームを検索して読み取ります。`
   - **サーバー URL（Server URL）:** `https://mcp.rimo.app/mcp`
5. **認証（Authentication）** で **OAuth 2.0** を選びます。
6. OAuth の種類で **動的検出（Dynamic discovery）** を選びます。
7. **作成（Create）** を選びます。
8. ツール追加ダイアログが表示されたら、Copilot Studio から求められた場合は接続を作成し、**エージェントに追加（Add to agent）** を選びます。

[既存の MCP サーバーを Copilot Studio エージェントに接続する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent)を参照してください。

<!-- screenshot: ../images/assets/ja/microsoft-mcp-details.png — Rimo の名前、説明、サーバー URL を入力した MCP オンボーディングウィザード -->
<!-- screenshot: ../images/assets/ja/microsoft-dynamic-discovery.png — OAuth 2.0 で Dynamic discovery を選んだ画面 -->

---

## 作成者として Rimo にサインインする

ツールの追加またはテスト時に、Copilot Studio から作成者用の Rimo 接続を求められる場合があります。

1. **接続（Connect）** または **サインイン（Sign in）** をクリックします。
2. Rimo 自身のページで、いつもの Rimo アカウントにサインインします。
3. 接続に許可する Rimo 組織を選びます。
4. **承認（Approve）** をクリックします。組織を選ぶまでボタンは無効です。

この作成者用接続は作成とテストのためのものです。**全従業員が作成者の Rimo ID を共有するわけではありません。** 展開後は各エンドユーザーが個別にサインインします。

---

## 公開前にテストする

1. エージェントの **テスト（Test）** パネルを開きます。
2. 新しいテスト会話を開始します。
3. 次のように質問します。

   ```text
   最新の Rimo ノートを 5 件表示して。
   ```

4. アクティビティマップで Rimo ツールが呼ばれたことを確認します。
5. 2 つ目の質問も試します。

   ```text
   価格に関する議論を Rimo ノートから検索して、決まったことを教えて。
   ```

テストでは、作成者が接続した Rimo アカウントから見えるノートだけが返ることを確認してください。

---

## Teams と Microsoft 365 Copilot に公開する

公開可能なプランが必要です。試用版の場合は前のテスト手順までです。

1. エージェントを開き、**公開（Publish）** を選びます。
2. 確認画面でもう一度 **公開** を選びます。
3. **チャネル（Channels）** を開きます。
4. **Teams and Microsoft 365 Copilot** を選びます。
5. Teams に加えて Microsoft 365 Copilot でも利用する場合は、**Make agent available in Microsoft 365 Copilot** をオンのままにします。
6. **チャネルを追加（Add channel）** を選びます。
7. **詳細を編集（Edit details）** で、組織が必要とする Rimo の名前、説明、アイコン、プライバシーステートメント、利用規約を設定します。
8. チャネルやエージェント内容を変更した後、もう一度公開します。

[Teams と Microsoft 365 Copilot 用にエージェントを接続して設定する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams)を参照してください。

---

## 1 人のエンドユーザーで試験する

組織のストアに申請する前に、アカウント B でテストします。

### 作成者 / アカウント A

1. **チャネル → Teams and Microsoft 365 Copilot → 利用可能オプション（Availability options）** を開きます。
2. アカウント B、アカウント B を含むセキュリティグループ、または組織全体にエージェントの利用権限があることを確認します。
3. **リンクをコピー（Copy link）** を選びます。
4. インストールリンクをアカウント B に送ります。

テナントで Teams の Power Platform アプリが許可されている必要があります。リンクがブロックされる場合は、Teams Administrator にエージェント/アプリの許可を依頼してください。

### エンドユーザー / アカウント B

1. プライベートブラウザでリンクを開き、アカウント B で Teams にサインインします。
2. **追加（Add）** を選びます。
3. Rimo エージェントを開き、次のように質問します。

   ```text
   最新の Rimo ノートを表示して。
   ```

4. 求められたら **接続（Connect）** または **Rimo でサインイン（Sign in with Rimo）** を選びます。
5. **アカウント B 自身の Rimo アカウント**でサインインし、Rimo 組織を選んで **承認** をクリックします。
6. 会話に戻り、必要に応じて質問を再実行します。

アカウント B が MCP URL を入力することはありません。アカウント B の Rimo サインインはアカウント A とは別で、エージェントが読めるノートの範囲を決めます。

権限分離を強く確認するには、アカウント A と B を異なる Rimo ユーザーに接続し、それぞれが許可されたノートだけを見られることを確認してください。

---

## エージェントを組織で利用可能にする

試験に成功したら、作成者がエージェントを申請し、管理者が承認します。

### ステップ 1 — 作成者が申請する

1. **チャネル → Teams and Microsoft 365 Copilot → 利用可能オプション** を開きます。
2. 現在 **Built with Power Platform** に表示している場合は、ストアで重複しないよう先にその表示を解除します。
3. **組織内の全員に表示（Show to everyone in my org）** を選びます。
4. **管理者の承認を申請（Submit for admin approval）** を選び、確認します。

### ステップ 2 — 管理者が承認する

**AI Administrator** または Global Administrator ロールのアカウントで操作します。

1. [Microsoft 365 管理センター](https://admin.microsoft.com/)を開きます。
2. **Agents → All agents → Requests** に移動します。
3. 申請中の Rimo エージェントを開きます。
4. 発行元、機能、データアクセス、ツール、セキュリティ情報、作成者を確認します。
5. 承認する場合は **公開（Publish）**、作成者に戻す場合は **拒否（Reject）** を選びます。
6. **ユーザー（Users）** で、次のいずれかまたは両方を設定します。
   - **Available to** — ユーザーがエージェントを検索してインストールできます。
   - **Deployed to** — 組織全体または選択したユーザー/グループへ自動展開します。

承認後、Teams の **Built for your org** または Microsoft 365 Agent Store の **Built by your org** から利用できます。Teams Administrator は、選択したユーザーに自動インストールしてピン留めすることもできます。

[Microsoft 365 Copilot の Agent Store](https://learn.microsoft.com/en-us/microsoft-365/copilot/copilot-agent-store)と[エージェントの利用可能範囲の設定](https://learn.microsoft.com/en-us/microsoft-365/copilot/agent-essentials/agent-lifecycle/agent-availability)を参照してください。

---

## 各従業員が行うこと

管理者がエージェントを展開した後、各従業員が行うのは次の操作だけです。

1. Teams または Microsoft 365 Copilot で Rimo エージェントを開きます。
2. 管理者が自動展開ではなく「利用可能」にした場合は、エージェントを追加します。
3. Rimo が必要な質問をします。
4. 初回だけ Rimo にサインインし、組織を選んでアクセスを承認します。

次の作業は不要です。

- `https://mcp.rimo.app/mcp` を自分で追加する。
- Rimo MCP サーバーを自分で設定する。
- 作成者の Rimo トークンを受け取ったり再利用したりする。
- 公開済みエージェントを使うために Copilot Studio 作成者ロールを取得する。

---

## エージェントを更新する

- **内容やツールの変更:** エージェントを再公開します。既存ユーザーに更新内容が反映され、通常は組織での再承認は不要です。
- **アイコンや説明などストア情報の変更:** もう一度管理者の承認を申請します。
- **新しい Rimo ツールが表示されない:** Copilot Studio で Rimo ツールを開き、接続またはツール検出を更新/再作成してから再公開します。

---

## 質問の例

- 「今週の Rimo ノートを見せて。」
- 「前回のスプリントで参加した Rimo ミーティングは？」
- 「直近の Rimo ミーティングのトランスクリプトを取得して。」
- 「そのミーティングには誰がいた？」
- 「価格戦略に関する Rimo ノートを探して。」
- 「オンボーディングに関するノートを探して。その言葉を使っていないものも含めて。」
- 「Rimo のノートを見て、Q3 リリースについて何を決めたか教えて。」

Rimo がエージェントに見せるのは、サインイン中のユーザーが承認した Rimo 組織で参照できるものだけです。

---

## 組織の切り替えと停止

- **一度に 1 つの Rimo 組織。** 別の組織を使う場合は、ユーザーの接続設定で Rimo を切断し、別の組織を選んで再接続します。
- **ユーザーのアクセスを解除する。** ユーザーは接続ページから Rimo 接続を取り消したり更新したりできます。
- **組織での利用を停止する。** 管理者は Microsoft 365 管理センターでエージェントをブロック、削除、または展開解除できます。
- **エージェントをオフラインにする。** 作成者は Teams and Microsoft 365 Copilot チャネルを削除できますが、管理者承認済みのストア表示は管理者側でも削除する必要があります。

---

## うまくいかないとき

**テストはできるが公開できない。** Copilot Studio 試用版では公開できません。Microsoft 365 Copilot、Copilot Studio スタンドアロン クレジットパック、従量課金、またはその他の公開可能な Copilot Studio 権利を使用してください。

**動的検出に失敗する。** **OAuth 2.0 → 動的検出（Dynamic discovery）** を選んだこと、クライアント ID やシークレットを入力していないこと、URL が正確に `https://mcp.rimo.app/mcp` であることを確認してください。

**エンドユーザーに作成者の Rimo ノートが表示される。** 展開を停止し、ツールが Agent author authentication ではなく **User authentication** を使っていることを確認してください。各従業員に個別の Rimo 接続が必要です。

**エンドユーザーがエージェントをインストールできない。** 両方の Microsoft アカウントが同じテナントにあること、ユーザーがエージェントのアクセス割り当てに含まれること、Teams で Power Platform アプリが許可されていること、Teams and Microsoft 365 Copilot チャネルで公開済みであることを確認してください。

**組織のストアにエージェントが表示されない。** 作成者の申請だけでは完了しません。AI Administrator または Global Administrator が **Microsoft 365 管理センター → Agents → All agents → Requests** で承認する必要があります。

**Rimo にサインインできたが承認ボタンが無効。** 先に Rimo 組織を選んでください。

**存在するはずのノートが表示されない。** エージェントが読めるのは、サインイン中の Rimo ユーザーが承認した 1 つの Rimo 組織で参照できるノートだけです。

---

## Microsoft 公式ヘルプ

- [既存の MCP サーバーを Copilot Studio エージェントに接続する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent)
- [ツールのユーザー認証を設定する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/configure-enduser-authentication)
- [Copilot Studio のライセンス](https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing)
- [ユーザーライセンスとアクセスを管理する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-licensing)
- [Teams と Microsoft 365 Copilot に公開する](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams)
- [エージェント管理のロールと権限](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-roles-perms?view=o365-worldwide)
- [Microsoft 365 Copilot の Agent Store](https://learn.microsoft.com/en-us/microsoft-365/copilot/copilot-agent-store)

---

## 関連ページ

- [Claude で Rimo を使う](rimo-in-claude.md) — Claude に Rimo を接続する
- [ChatGPT で Rimo を使う](rimo-in-chatgpt.md) — ChatGPT に Rimo を接続する
- [MCP でできること](mcp.md) — 利用できる Rimo ツールと質問例
- [認証](authentication.md) — Rimo のサインインとアカウントの仕組み

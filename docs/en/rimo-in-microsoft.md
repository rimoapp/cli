# Rimo in Microsoft Copilot

[English](../en/rimo-in-microsoft.md) | [日本語](../ja/rimo-in-microsoft.md)

Connect Rimo to a **Microsoft Copilot Studio agent** and ask about your meeting notes in Microsoft Teams or Microsoft 365 Copilot. The agent looks things up in Rimo and answers:

- *"What did we decide in Monday's call, according to my Rimo notes?"*
- *"Summarise last week's client meeting from Rimo."*

There is **nothing for each employee to install or configure as an MCP server**. A maker adds Rimo to the agent once. After the agent is published, each employee opens it and signs in with their own Rimo account.

**The server URL to add:**

```
https://mcp.rimo.app/mcp
```

> Using Claude or ChatGPT instead? See [Rimo in Claude](rimo-in-claude.md) or [Rimo in ChatGPT](rimo-in-chatgpt.md).

---

## How organization setup works

There are three separate parts:

1. A **maker** creates one Copilot Studio agent and adds the Rimo MCP server.
2. An **administrator** approves and deploys the published agent to the organization, or the maker shares an installation link for a small pilot.
3. Each **end user** opens the agent and signs in to Rimo once. Users do not enter the MCP URL and do not need the maker's Rimo connection.

Rimo uses **user authentication**. Each user can only access notes that their own Rimo account can see. Copilot Studio prompts the user to sign in when the agent first needs a Rimo tool, and prompts again only if access expires or is revoked. See [Microsoft's user-authentication guide](https://learn.microsoft.com/en-us/microsoft-copilot-studio/configure-enduser-authentication).

The Microsoft accounts must belong to the **same Microsoft Entra tenant** for the normal organization rollout described here.

---

## Choose your Microsoft plan

| Microsoft setup | Who can build | Can publish? | What end users need | How usage is paid |
|---|---|---:|---|---|
| **Copilot Studio trial** | The trial user | No | Not applicable | Test panel only |
| **Microsoft 365 Copilot** — the add-on, Microsoft 365 Copilot Business, or Microsoft 365 E7 entitlement | A licensed user with environment access | Yes | For the assured Microsoft 365 Copilot experience, assign an eligible Microsoft 365 Copilot entitlement to each user | Included for authenticated employee-facing use, subject to fair-use limits |
| **Standalone Copilot Studio credit pack** | A maker with the free Copilot Studio User License | Yes | No special Copilot Studio license for users of the published agent; they still need access to the channel, such as Teams | Tenant Copilot Credits |
| **Copilot Studio pay-as-you-go or a pre-purchase plan** | A maker in the Copilot Studio Author group | Yes | No special Copilot Studio license for users of the published agent; they still need access to the channel | Tenant billing plan / Copilot Credits |
| **Copilot Studio Teams plan** | Classic-agent makers | Teams only | Teams access | **Not covered by this guide.** The Teams plan lacks Power Platform connectors, while Copilot Studio MCP access relies on them |

Important plan details:

- A **trial can create and test** the agent, but it **cannot publish** it.
- With a standalone credit pack, the administrator purchases tenant capacity and assigns the `$0` **Copilot Studio User License** to each maker.
- With pay-as-you-go or a pre-purchase plan, the administrator links billing to the environment and grants makers the **Copilot Studio Author** role.
- Users of a **published** agent do not need a special Copilot Studio license. If they don't have Microsoft 365 Copilot, their use consumes the tenant's Copilot Studio capacity or pay-as-you-go meter.
- When an authenticated employee has a Microsoft 365 Copilot license, eligible Copilot Studio agent use in Microsoft 365 Copilot, Teams, or SharePoint is included, subject to Microsoft's fair-use limits.

See [Copilot Studio licensing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing), [assign licenses and manage access](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-licensing), [Microsoft 365 Copilot licensing models](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/prerequisites#agent-capabilities-and-licensing-models), and the [June 2026 Copilot Studio Licensing Guide](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/microsoft/bade/documents/products-and-services/en-us/bizapps/Microsoft-Copilot-Studio-Licensing-Guide-June-2026-PUB.pdf).

### Recommended two-account test

For a first organization test:

- **Account A — maker and test administrator**
  - A publish-capable Copilot Studio entitlement; not a trial.
  - Access to the Power Platform environment that contains the agent.
  - Owner or Editor access to the agent.
  - **AI Administrator** if this account will also approve the organization deployment.
- **Account B — normal end user**
  - A normal Member/User account in the same Entra tenant.
  - Teams access for the simplest first test.
  - No Copilot Studio maker or administrator role.
  - Its own Rimo account.

If you want to test inside the Microsoft 365 Copilot app rather than Teams, assign Account B a Microsoft 365 Copilot license for the clearest supported path.

---

## Roles for publishing to the organization

The maker does not have to be a tenant administrator.

| Task | Minimum role or permission |
|---|---|
| Build, configure, and publish the agent | Agent Owner/Editor plus the Copilot Studio User License or Copilot Studio Author entitlement described above |
| Approve and manage the agent in the Microsoft 365 admin center | **AI Administrator**; Global Administrator also works but has much broader access |
| Manage Teams app availability, automatic installation, and pinning | **Teams Administrator** |
| Use the published agent | Normal tenant user with access to the agent and its channel |

Microsoft recommends using the least-privileged **AI Administrator** role instead of Global Administrator for agent approval. See [agent management roles and permissions](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-roles-perms?view=o365-worldwide).

---

## Add Rimo to Copilot Studio

The following setup is done once by the maker.

1. Open your agent in [Microsoft Copilot Studio](https://copilotstudio.microsoft.com/).
2. Open **Tools**.
3. Select **Add a tool → New tool → Model Context Protocol**.
4. Enter:
   - **Server name:** `Rimo`
   - **Server description:** `Search and read the signed-in user's Rimo meeting notes, transcripts, documents, participants, and teams.`
   - **Server URL:** `https://mcp.rimo.app/mcp`
5. For **Authentication**, select **OAuth 2.0**.
6. For the OAuth type, select **Dynamic discovery**.
7. Select **Create**.
8. When the Add tool dialog appears, create a connection if Copilot Studio asks for one, then select **Add to agent**.

See [Connect an existing MCP server to a Copilot Studio agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent).

<!-- screenshot: ../images/assets/microsoft-mcp-details.png — MCP onboarding wizard with the Rimo name, description, and server URL -->
<!-- screenshot: ../images/assets/microsoft-dynamic-discovery.png — OAuth 2.0 with Dynamic discovery selected -->

---

## Sign in to Rimo as the maker

Copilot Studio might ask the maker to create a Rimo connection while adding or testing the tool.

1. Click **Connect** or **Sign in**.
2. Sign in on Rimo's own page with your usual Rimo account.
3. Choose the Rimo organization that the connection may access.
4. Click **Approve**. The button remains disabled until you choose an organization.

This maker connection is for building and testing. It is **not shared as the identity for all employees**. Each end user signs in separately after deployment.

---

## Test before publishing

1. Open the agent's **Test** panel.
2. Start a new test conversation.
3. Ask:

   ```text
   Show my latest five Rimo notes.
   ```

4. Confirm that the activity map calls a Rimo tool.
5. Try a second prompt:

   ```text
   Search my Rimo notes for the pricing discussion and tell me what we decided.
   ```

The test should return only notes visible to the Rimo account connected by the maker.

---

## Publish to Teams and Microsoft 365 Copilot

You need a publish-capable plan. A trial stops at the previous test step.

1. Open the agent and select **Publish**.
2. Select **Publish** again to confirm.
3. Open **Channels**.
4. Select **Teams and Microsoft 365 Copilot**.
5. To make the agent available in Microsoft 365 Copilot as well as Teams, leave **Make agent available in Microsoft 365 Copilot** selected.
6. Select **Add channel**.
7. Under **Edit details**, add the Rimo name, description, icon, privacy statement, and terms of use that your organization requires.
8. Publish again after changing the channel or agent content.

See [Connect and configure an agent for Teams and Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams).

---

## Pilot with one end user

Before submitting the agent to the organization store, test it with Account B.

### Maker / Account A

1. Open **Channels → Teams and Microsoft 365 Copilot → Availability options**.
2. Make sure Account B, a security group containing Account B, or everyone in the organization has permission to use the agent.
3. Select **Copy link**.
4. Send the installation link to Account B.

Your tenant must allow Power Platform apps in Teams. If the link is blocked, ask a Teams Administrator to allow the agent/app.

### End user / Account B

1. Open the link in a private browser window and sign in to Teams with Account B.
2. Select **Add**.
3. Open the Rimo agent and ask:

   ```text
   Show my latest Rimo note.
   ```

4. When prompted, select **Connect** or **Sign in with Rimo**.
5. Sign in with **Account B's Rimo account**, choose a Rimo organization, and click **Approve**.
6. Return to the conversation and retry the prompt if necessary.

Account B does not enter the MCP URL. Its Rimo sign-in is separate from Account A's and controls which notes the agent can read.

For a strong permission test, connect Account A and Account B to different Rimo users and confirm that each sees only their own permitted notes.

---

## Make the agent available to the organization

After the pilot succeeds, the maker submits the agent and an administrator approves it.

### Step 1 — the maker submits it

1. Open **Channels → Teams and Microsoft 365 Copilot → Availability options**.
2. If the agent is currently shown under **Built with Power Platform**, remove that listing first to avoid duplicate store entries.
3. Select **Show to everyone in my org**.
4. Select **Submit for admin approval** and confirm.

### Step 2 — an administrator approves it

Using an account with the **AI Administrator** or Global Administrator role:

1. Open the [Microsoft 365 admin center](https://admin.microsoft.com/).
2. Go to **Agents → All agents → Requests**.
3. Open the pending Rimo agent.
4. Review its publisher, capabilities, data access, tools, security information, and maker.
5. Select **Publish** to approve it, or **Reject** to return it to the maker.
6. Under **Users**, configure one or both of these:
   - **Available to** — users can find and install the agent.
   - **Deployed to** — the agent is deployed automatically to the organization or selected users/groups.

After approval, users can find the agent under **Built for your org** in Teams or **Built by your org** in Microsoft 365 Agent Store. A Teams Administrator can also automatically install and pin it for selected users.

See [Agent Store in Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-365/copilot/copilot-agent-store) and [set agent availability](https://learn.microsoft.com/en-us/microsoft-365/copilot/agent-essentials/agent-lifecycle/agent-availability).

---

## What each employee does

After the administrator deploys the agent, each employee only needs to:

1. Open the Rimo agent in Teams or Microsoft 365 Copilot.
2. Add it if the administrator made it available rather than deploying it automatically.
3. Ask a question that needs Rimo.
4. Sign in to Rimo, choose an organization, and approve access the first time.

They do **not**:

- Add `https://mcp.rimo.app/mcp` themselves.
- Configure the Rimo MCP server themselves.
- Receive or reuse the maker's Rimo token.
- Need a Copilot Studio maker role to use the published agent.

---

## Updating the agent

- **Content or tool changes:** publish the agent again. Existing users receive the updated content; a new organization approval isn't normally required.
- **Store details such as the icon or description:** submit the agent for admin approval again.
- **New Rimo tools don't appear:** open the Rimo tool in Copilot Studio and refresh or recreate the connection/tool discovery, then publish again.

---

## Example things to ask

- "Show me my Rimo notes from this week."
- "Which Rimo meetings did I attend last sprint?"
- "Get the transcript of my last Rimo meeting."
- "Who was in that meeting?"
- "Find my Rimo notes about pricing strategy."
- "Find my notes about onboarding, even if they don't use that exact word."
- "Looking at my Rimo notes, what did we decide about the Q3 release?"

Rimo only ever shows the agent what the signed-in user can see in the Rimo organization they approved.

---

## Switching organizations & turning it off

- **One Rimo organization at a time.** To use another organization, open the user's connection settings, disconnect Rimo, and connect again while choosing the other organization.
- **Remove a user's access.** The user can revoke or refresh the Rimo connection from their connection page.
- **Stop organization access.** An administrator can block, remove, or undeploy the agent in the Microsoft 365 admin center.
- **Take the agent offline.** The maker can remove the Teams and Microsoft 365 Copilot channel, but an admin-approved store listing must also be removed by an administrator.

---

## If something doesn't work

**You can test but can't publish.** A Copilot Studio trial cannot publish. Use Microsoft 365 Copilot, a standalone Copilot Studio credit pack, pay-as-you-go, or another publish-capable Copilot Studio entitlement.

**Dynamic discovery fails.** Confirm that you selected **OAuth 2.0 → Dynamic discovery**, did not enter a client ID or secret, and used exactly `https://mcp.rimo.app/mcp`.

**The end user is seeing the maker's Rimo notes.** Stop the rollout and confirm the tool uses **User authentication**, not Agent author authentication. Every employee must have a separate Rimo connection.

**The end user can't install the agent.** Confirm that both Microsoft accounts are in the same tenant, the user is included in the agent's access assignment, Power Platform apps are allowed in Teams, and the agent is published with the Teams and Microsoft 365 Copilot channel.

**The agent doesn't appear in the organization store.** A maker submission isn't enough. An AI Administrator or Global Administrator must approve it under **Microsoft 365 admin center → Agents → All agents → Requests**.

**Rimo sign-in works but Approve is disabled.** Choose a Rimo organization first.

**A known note doesn't appear.** The agent can only read notes visible to the signed-in Rimo user in the one approved Rimo organization.

---

## Official Microsoft help

- [Connect an existing MCP server to a Copilot Studio agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-add-existing-server-to-agent)
- [Configure user authentication for tools](https://learn.microsoft.com/en-us/microsoft-copilot-studio/configure-enduser-authentication)
- [Copilot Studio licensing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing)
- [Assign licenses and manage access](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-licensing)
- [Publish to Teams and Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams)
- [Agent management roles and permissions](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-roles-perms?view=o365-worldwide)
- [Agent Store in Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-365/copilot/copilot-agent-store)

---

## See also

- [Rimo in Claude](rimo-in-claude.md) — connect Rimo to Claude
- [Rimo in ChatGPT](rimo-in-chatgpt.md) — connect Rimo to ChatGPT
- [What you can do with MCP](mcp.md) — available Rimo tools and examples
- [Authentication](authentication.md) — how Rimo sign-in and accounts work

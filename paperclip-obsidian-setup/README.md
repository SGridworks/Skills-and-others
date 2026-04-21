# Paperclip + Obsidian Setup Guide

## Prerequisites

- **Obsidian** — https://obsidian.md (Windows installer)
- **WSL 2** — required for Paperclip server (Node.js/pnpm)
- **VS Code** with **WSL Remote** extension (recommended editor)
- **Git** — https://git-scm.com/download/win

---

## 1. Clone the Template Repository

Open **PowerShell** or **Windows Terminal**:

```powershell
git clone https://github.com/your-org/Skills-and-others.git $env:USERPROFILE%\Skills-and-others
cd $env:USERPROFILE%\Skills-and-others
```

---

## 2. Set Up WSL for Paperclip

Paperclip server runs on Node.js with pnpm. Native Windows Node can work, but symlinks and socket paths cause issues — **WSL is the tested path**.

### Option A: WSL + VS Code (Recommended)

```powershell
# In PowerShell, install WSL if not present
wsl --install -d Ubuntu
```

```bash
# Inside WSL
curl -fsSL https://get.pnpm.io | sh
node --version   # confirm Node 18+
```

### Option B: Node.js directly on Windows (Unsupported)

```powershell
winget install OpenJS.NodeJS.LTS
npm install -g pnpm
```

> Paperclip agents will fail silently on certain file-watching operations without WSL. If you hit unexplained adapter errors, move to Option A.

---

## 3. Configure the Vault

Open **Obsidian** and create a new vault named `vault` in your home folder:

```
C:\Users\YourName\vault
```

### Enable Community Plugins

1. Settings → Community Plugins → Turn on **Restricted mode** (toggle off)
2. Browse community plugins → Install:
   - **Templater** — for dynamic templates
   - **Meta“快"** (or another metadata plugin)

### Configure Templater

1. Settings → Templater → Template folder: `1_templates`
2. Create the folder inside your vault
3. Copy templates from `template/obsidian/vault/1_templates/` in this repo to your vault

### Link Your Vault

In your Windows home folder (`C:\Users\YourName`), create a symlink so WSL can access it:

```bash
# Inside WSL
ln -s /mnt/c/Users/YourName/vault ~/vault
```

> If `ln` fails with "Permission denied", run PowerShell as admin or use `mklink /D` in Windows CMD.

---

## 4. Configure Hermes Adapter

### 4a. Install Hermes Agent (CLI)

```powershell
# On Windows — use the installer script
iwr https://raw.githubusercontent.com/NousResearch/hermes-agent/main/install.ps1 -OutFile install-hermes.ps1
.\install-hermes.ps1
```

Or clone and build manually:

```powershell
git clone https://github.com/NousResearch/hermes-agent.git
cd hermes-agent
pip install -e .
```

### 4b. Configure paperclip-adapter

The adapter connects Hermes to your Paperclip agents.

**In WSL:**

```bash
cd ~
git clone https://github.com/NousResearch/hermes-paperclip-adapter.git
cd hermes-paperclip-adapter
pnpm install
```

**Adapter config** (`~/.hermes/config.yaml`):

```yaml
paperclip:
  adapterPath: /home/youruser/hermes-paperclip-adapter
  model: MiniMax-M2.7-32k
  apiBase: http://127.0.0.1:3100

vault:
  path: /mnt/c/Users/YourName/vault   # WSL path to your Obsidian vault
```

---

## 5. Run a Test Agent

From WSL:

```bash
cd ~/hermes-paperclip-adapter
pnpm start
```

From a new PowerShell window:

```powershell
hermes-agent run --prompt "Hello, test connection"
```

If the vault path is set correctly, the agent should be able to read/write notes in your Obsidian vault.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `EACCES: permission denied` on vault files | Run Obsidian as administrator, or fix NTFS permissions on vault folder |
| Paperclip agents don't start | Confirm WSL is running `systemctl` or `service` status |
| Vault symlink broken after reboot | Re-run `ln -s` command in WSL |
| `pnpm: command not found` | Add pnpm to PATH in `.bashrc`: `export PATH="$PATH:$(pnpm prefix -g)/bin"` |
| Adapter config not found | Set `HERMES_CONFIG=~/.hermes/config.yaml` explicitly |

---

## File Structure

```
C:\Users\YourName\
├── vault\                    # Obsidian vault
│   ├── 1_templates\          # Templater templates
│   ├── companies\           # Company-specific notes
│   └── skills\              # Skill documents
└── .hermes\                  # Hermes config
    └── config.yaml
```

```
WSL ~/:
├── hermes-paperclip-adapter\  # Paperclip server
├── hermes-agent\              # CLI tool
└── vault -> /mnt/c/Users/...  # Symlink to Obsidian vault
```

---

## Next Steps

- Copy company-specific templates from `template/paperclip/companies/` into your vault
- Run `hermes-agent agents list` to confirm Paperclip agents are reachable
- Set up Telegram or Discord gateway for remote access (see Hermes docs)

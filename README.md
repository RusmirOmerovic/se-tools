# se-tools

Kleine Bash-Toolchain zur schnellen Projektinitialisierung, Verwaltung von Repositories und Alltags-Tasks mit Git/GitHub.

---

## Inhalt
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Entwicklungsumgebung Setup (macOS Beispiel)](#entwicklungsumgebung-setup-macos-beispiel)
- [Authentifizierung](#authentifizierung)
  - [Option A – GitHub Login über gh (empfohlen)](#option-a--github-login-über-gh-empfohlen)
  - [Option B – Personal Access Token (PAT) als Fallback/CI](#option-b--personal-access-token-pat-als-fallbackci)
- [Sicherheitshinweise](#sicherheitshinweise)
- [Verwendung der Skripte](#verwendung-der-skripte)
- [Beispiel: newproject Workflow](#beispiel-newproject-workflow)
- [Troubleshooting](#troubleshooting)

---

## Voraussetzungen
- macOS oder Linux mit:
  - `bash` ≥ 5
  - `git` (≥ 2.40)
  - **GitHub CLI** `gh` (≥ 2.70)
- Optional: `curl`, `jq`, `fzf`

---

## Installation

```bash
# Repository klonen
git clone https://github.com/RusmirOmerovic/se-tools.git
cd se-tools

# Skripte ausführbar machen
chmod +x ./bin/*

# PATH anpassen (zsh)
echo 'export PATH="$HOME/se-tools/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Danach stehen die Befehle (`newproject`, `pushrepo` usw.) global im Terminal zur Verfügung.

---

## Entwicklungsumgebung Setup (macOS Beispiel)

### Homebrew (User-spezifisch)
Wir haben Homebrew im Homeverzeichnis installiert, um Konflikte mit dem Hauptaccount zu vermeiden:

```bash
which brew
/Users/tester/.homebrew/bin/brew

brew --version
Homebrew 4.6.4
```

### Git
```bash
git --version
git version 2.51.0
```

### GitHub CLI (gh)
```bash
gh --version
gh version 2.76.2 (2025-07-30)
```

### Visual Studio Code
VS Code wurde installiert und der CLI-Pfad (`code`) gesetzt:

```bash
code .   # öffnet VS Code im aktuellen Verzeichnis
```

### Git-Konfiguration
```bash
git config --global user.name "Rusmir Omerovic"
git config --global user.email "DEINE-GITHUB-EMAIL@beispiel.tld"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global credential.helper osxkeychain
```

---

## Authentifizierung

### Option A – GitHub Login über gh (empfohlen)

```bash
gh auth login
gh auth status
```

Beispielausgabe:
```
github.com
  ✓ Logged in to github.com account RusmirOmerovic (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

Token-Export (nur falls Skripte es explizit benötigen):
```bash
export GH_TOKEN="$(gh auth token)"
export GITHUB_TOKEN="$GH_TOKEN"
```

### Option B – Personal Access Token (PAT) als Fallback/CI

1. PAT unter `https://github.com/settings/tokens` erstellen.  
   Scopes minimal halten: `repo`, optional `workflow`, nur bei Bedarf `delete_repo`.

2. Token exportieren oder in `.env.local` speichern:
```bash
export GH_TOKEN="ghp_xxx"
export GITHUB_TOKEN="$GH_TOKEN"

# optional in .env.local (immer in .gitignore!)
umask 177
cat > .env.local <<'EOF'
GH_TOKEN=ghp_xxx
GITHUB_TOKEN=ghp_xxx
EOF
```

---

## Sicherheitshinweise

- Keine Tokens oder Secrets ins Repo committen.  
- `.env*`, `*.pem`, `*.key`, `secrets/` immer in `.gitignore`.  
- `gh auth token` bevorzugen statt PAT-Dateien.  
- Least Privilege: nur die Scopes freigeben, die gebraucht werden.  

---

## Verwendung der Skripte

### newproject
Legt ein neues GitHub-Repository an und initialisiert es lokal.

```bash
newproject --name my-app --private --description "Demo Repo"
```

### pushrepo
Fügt Remote hinzu und pusht lokalen Code nach GitHub.

```bash
pushrepo
```

### deleterepo
Löscht ein GitHub-Repository (benötigt Scope `delete_repo`).

```bash
deleterepo --name my-app
```

### Weitere Skripte
- `mergerepo` – PRs zusammenführen  
- `supabase-*` – Helper für Supabase-Integration (Tokens per ENV)  

---

## Beispiel: newproject Workflow

```bash
# Auth sicherstellen
gh auth status || gh auth login
export GH_TOKEN="$(gh auth token)"
export GITHUB_TOKEN="$GH_TOKEN"

# Neues Repo anlegen
newproject --name playground-demo --private

# Lokalen Commit erzeugen und pushen
git init -b main
echo "# playground-demo" > README.md
git add README.md && git commit -m "init"
git remote add origin https://github.com/<USER>/playground-demo.git
git push -u origin main
```

---

## Troubleshooting

- **`gh auth token` leer** → `gh auth login` ausführen.  
- **`git push` fragt nach Passwort** → `git config --global credential.helper osxkeychain`.  
- **SSH statt HTTPS nutzen** (optional):  
```bash
ssh-keygen -t ed25519 -C "deine-github-mail@example.com" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
gh ssh-key add ~/.ssh/id_ed25519.pub -t "MacBook Air"
ssh -T git@github.com
```
- **CI ohne gh** → PAT als Secret `GH_TOKEN`/`GITHUB_TOKEN` setzen.

---

## TL;DR

- Lokales Setup: ✔️ Homebrew, Git, gh, VS Code  
- Auth: ✔️ via `gh auth login` (empfohlen)  
- Token: ✔️ `export GH_TOKEN="$(gh auth token)"`  
- Skripte: ✔️ `newproject`, `pushrepo`, `deleterepo` usw.  
- Sicherheit: ✔️ keine Tokens im Repo

---

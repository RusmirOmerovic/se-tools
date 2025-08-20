# 🧰 se-tools

**se-tools** ist ein leichtgewichtiges Tool-Set aus Bash-Skripten, um neue Projekte in Sekunden anzulegen, sicher zu pushen, Repos zu löschen und standardisierte Merges/Deploys durchzuführen.  
Es richtet sich an DevOps-/DevSecOps-Workflows mit GitHub.

## Tipp:
öffne deine Konfigurationsdatei .zshrc/.bashrc im Terminal mit nano .zshrc/.bashrc, danach füge die Pfade für die Bash-Befehle sowie die 
GitHub-Token ein. 
Das sollte dann ungefähr so aussehen: 
```
# --------------------------------------------------------------------
# Custom PATHs
# --------------------------------------------------------------------
export PATH="$HOME/se-tools:$PATH"

# --------------------------------------------------------------------
# GitHub CLI Token Handling (via gh auth token)
# GH_TOKEN = wird dynamisch von gh erzeugt
# GITHUB_TOKEN = wird von Skripten (z. B. newproject) erwartet
# --------------------------------------------------------------------
export GH_TOKEN="$(gh auth token)"
export GITHUB_TOKEN="$GH_TOKEN"
```
-> control(^) + O - Speichern ; Enter - Bestätigen ; control(^) + X - Schließen 
-> damit ist deine Konfiguration im Hintergrund schon richtig vorbereitet für alle weiteren Vorgänge! ✅



> ## Kurzfassung der Befehle:  
> - `newproject` erzeugt ein neues Repo aus einer Template-Vorlage  
> - `pushrepo` pusht sicher mit Checks  
> - `deleterepo` räumt lokal/remote auf  
> - `merge-main` / `merge-test` automatisieren Merges  
> - `projectnew` integriert dein Projekt zusätzlich in Supabase (Projekte & Meilensteine)  

👉 **Alle Details & Anleitungen findest du im [Wiki](https://github.com/RusmirOmerovic/se-tools/wiki).**


---

## Voraussetzungen

- **Git** und **GitHub CLI (`gh`)**  
- **Homebrew** (empfohlen für Installation auf macOS)  
- Optional: **Supabase CLI** (für `projectnew`)  

---

## Installation

```bash
git clone https://github.com/RusmirOmerovic/se-tools.git
cd se-tools
chmod +x ./*
echo 'export PATH="$HOME/se-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## Erste Schritte

1. Mit GitHub anmelden:
   ```bash
   gh auth login
   ```

2. Neues Projekt starten:
   ```bash
   newproject meinProjekt
   ```

3. Code committen & pushen:
   ```bash
   pushrepo
   ```

---

## Mehr Informationen

👉 Detaillierte Dokumentation, Token-Handling und Supabase-Integration findest du im  
➡️ [se-tools Wiki](https://github.com/RusmirOmerovic/se-tools/wiki)

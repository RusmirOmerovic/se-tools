# se-tools

**se-tools** ist ein leichtgewichtiges Tool-Set aus Bash-Skripten, um neue Projekte in Sekunden anzulegen, sicher zu pushen, Repos zu löschen und standardisierte Merges/Deploys durchzuführen.  
Es richtet sich an DevOps-/DevSecOps-Workflows mit GitHub.

> **Kurzfassung:**  
> - `newproject` erzeugt ein neues Repo aus einer Template-Vorlage  
> - `pushrepo` pusht sicher mit Checks  
> - `deleterepo` räumt lokal/remote auf  
> - `merge-main` / `merge-test` automatisieren Merges  
> - `projectnew` integriert dein Projekt zusätzlich in Supabase (Projekte & Meilensteine)  

👉 **Alle Details & Anleitungen findest du im [Wiki](https://github.com/RusmirOmerovic/se-tools/wiki).**

---

## Inhalt des Repos

- `newproject` – neues Projekt aus Template anlegen und auf GitHub veröffentlichen  
- `projectnew` – wie `newproject`, zusätzlich Anlage im Supabase-Backend (Projekte & Milestones)  
- `pushrepo` – sicherer Commit + Push mit Checks (verhindert versehentliches Pushen von Secrets)  
- `deleterepo` – löscht ein Projekt lokal und remote auf GitHub  
- `merge-main` – automatischer Merge von Feature-Branch in `main`  
- `merge-test` – automatischer Merge in Test-Branch  

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
   newproject --name demo-app --private
   ```

3. Code committen & pushen:
   ```bash
   pushrepo
   ```

---

## Mehr Informationen

👉 Detaillierte Dokumentation, Token-Handling und Supabase-Integration findest du im  
➡️ [se-tools Wiki](https://github.com/RusmirOmerovic/se-tools/wiki)

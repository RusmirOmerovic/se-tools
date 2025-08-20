# 🧰 se-tools

**se-tools** ist ein leichtgewichtiges Tool-Set aus Bash-Skripten, um neue Projekte in Sekunden anzulegen, sicher zu pushen, Repos zu löschen und standardisierte Merges/Deploys durchzuführen.  
Es richtet sich an DevOps-/DevSecOps-Workflows mit GitHub.

## Tipp:
öffne deine Konfigurationsdatei .zshrc/.bashrc im Terminal mit nano .zshrc/.bashrc und prüfe die enthaltenen Pfade. 
Das sollte dann ungefähr so aussehen: 
```
#se-tools global Befehle ausführen
export PATH="$HOME/se-tools:$PATH"

```
Falls nicht, trage das genau so ein!

-> control(^) + O - **Speichern** ; Enter - **Bestätigen** ; control(^) + X - **Schließen**


-> die Einrichtung ist abgeschlossen! ✅

-> Beim Erstellen deines ersten Projekts mit "newproject" wirst du einmalig aufgefordert deinen Token einzugeben. 
   Dazu gehts du in deinem GitHub-Account auf settings/token 
   -> "classic tokens" & Rechte: repo, workflow, read:org, 
   -> Token generieren, kopieren und im Terminal einfügen, dann 'Enter' drücken

   FERTIG ☑️ - das Token wird versteckt in einer Hintergrund-Datei gespeichert (~/.config/se-tools/gh_token.txt) 
   ⏳ die Gültigkeitsdauer wird ständig überprüft und vor dem Ablauf von 90 Tagen, wirst du erneut aufgefordert 
      das Token zu erneuern. Dann wiederholst du den Prozess und kopierst wieder das Token in die Abfrage! 



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

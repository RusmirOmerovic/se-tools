# 🧰 se-tools

**se-tools** ist ein leichtgewichtiges Tool-Set aus Bash-Skripten, um neue Projekte in Sekunden anzulegen, sicher zu pushen, Repos zu löschen und standardisierte Merges/Deploys durchzuführen.  
Es richtet sich an DevOps-/DevSecOps-Workflows mit GitHub & Supabase.

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

## Voraussetzungen

- **Git**  
- **GitHub CLI (`gh`)** → ersetzt komplett das alte Token-Handling  
- Optional: **Supabase CLI** (für Edge-Functions/Testing)  

---

## Erste Schritte

1. **GitHub einrichten (einmalig):**
   ```bash
   gh auth login
   gh auth status
   ```
   Danach brauchst du kein Token mehr – alle Befehle nutzen automatisch deine GitHub-Session.

2. **Projekt anlegen (GitHub + Supabase):**
   ```bash
   projectnew meinProjekt
   ```
   - Du wirst nach deiner **E-Mail + Passwort** gefragt (wie im Frontend)  
   - Repo wird automatisch aus Template erstellt und gepusht  
   - Projekt + Meilenstein wird in Supabase angelegt  

3. **Weitere Standardbefehle:**
   ```bash
   newproject <name>   # nur GitHub-Repo anlegen
   pushrepo            # commits sicher pushen
   deleterepo          # Repo lokal & remote löschen
   merge-main          # Feature → main mergen
   merge-test          # Feature → test mergen
   ```

---

## Was sich geändert hat (2025)

- 🔑 **Kein GitHub-Token** mehr nötig – alles läuft über `gh`.  
- 🔐 **Keine Supabase-Secrets** mehr im Code – User loggt sich mit eigenen Credentials ein.  
- 🌍 **Skalierbar**: Jeder registrierte User kann Projekte sowohl im Frontend (Vercel) als auch über CLI erstellen.  

---

## Konfiguration der Shell

Öffne deine Konfigurationsdatei `.zshrc` oder `.bashrc` im Terminal:
```bash
nano ~/.zshrc
```

Füge den Pfad zu den Skripten hinzu:
```bash
# se-tools global Befehle
export PATH="$HOME/se-tools:$PATH"
```

Dann speichern (**Ctrl+O** → Enter), schließen (**Ctrl+X**) und Shell neu laden:
```bash
source ~/.zshrc
```

---

## Mehr Infos

👉 Detaillierte Workflows, Edge-Function-Integration und Beispiele findest du im  
➡️ [se-tools Wiki](https://github.com/RusmirOmerovic/se-tools/wiki)

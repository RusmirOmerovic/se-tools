# 🧰 se-tools – Bash-Tools für Software-Engineering-Projekte

Dieses Repository enthält nützliche Bash-Tools, um häufige Arbeitsschritte in GitHub-Projekten zu automatisieren.  
Du kannst damit z. B. neue Repos erstellen, automatisch pushen oder Branches zusammenführen.

---

## ✅ Installation (einmalig)

### 1. Repository klonen

Öffne dein Terminal und führe aus:

```bash
git clone https://github.com/RusmirOmerovic/se-tools.git
```

### 2. Ordnerpfad zur Shell-Konfiguration hinzufügen

Damit du die Befehle (wie `newproject`, `pushrepo`, usw.) **überall verwenden kannst**, musst du den Pfad zum `se-tools` Ordner in deine Shell-Konfigurationsdatei einfügen.

#### So geht’s:

1. **Wechsle ins Home-Verzeichnis:**

```bash
cd ~
```

2. **Öffne deine Konfigurationsdatei im Editor:**

- Für Zsh (Standard bei macOS):

```bash
nano .zshrc
```

- Für Bash (z. B. bei Linux oder WSL):

```bash
nano .bashrc
```

3. **Füge ganz unten folgende Zeile ein:**  
*(Passe den Pfad an deinen Speicherort an)*

```bash
export PATH="$HOME/Pfad/zum/se-tools:$PATH"
```

📌 Beispiel:

```bash
export PATH="$HOME/Documents/code/se-tools:$PATH"
```

4. **Speichern und schließen:**  
Drücke `CTRL + O`, dann `Enter`, dann `CTRL + X`.

5. **Änderungen aktivieren:**

```bash
source ~/.zshrc
```

oder

```bash
source ~/.bashrc
```

---

## 🚀 Verfügbare Befehle

| Befehl        | Beschreibung                                      |
|---------------|---------------------------------------------------|
| `newproject`  | Erstellt ein neues GitHub-Repository inkl. Setup |
| `pushrepo`    | Commit + Push der aktuellen Änderungen            |
| `merge-test`  | Merged `develop` → `testing`                      |
| `merge-main`  | Merged `testing` → `main` und löscht preview.yml |
| `delete-repo` | Löscht ein lokales + remote Projektverzeichnis sicher |
| `sync-repo`   | einheitlicher Inhalt aller Branches -> synchronisieren |

Alle Befehle funktionieren **ohne `.sh`**, sobald der Pfad gesetzt ist.

---

## ℹ️ Hinweise

- Du kannst die Tools jederzeit erweitern oder anpassen.
- Wenn du möchtest, kannst du auch eine `README.md` im Hauptprojekt verlinken.
- Forks und Verbesserungen sind willkommen!

---

## 📄 Lizenz

MIT License


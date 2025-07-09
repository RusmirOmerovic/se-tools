# 🛠️ Setup-Anleitung: GitHub-Template & Bash-Tools

Diese Anleitung zeigt dir Schritt für Schritt, wie du dein Terminal einrichtest, um die Befehle `newproject`, `push` und `deleterepo` zu nutzen und automatisch neue Software-Engineering-Projekte mit GitHub & Pages zu erstellen.

---

## ✅ Voraussetzungen

- GitHub-Account
- macOS/Linux Terminal (zsh oder bash)
- Git installiert
- Optional: VS Code (empfehlenswert)

---

## 📁 1. Bash-Tool-Verzeichnis anlegen

```bash
mkdir -p ~/Bash
cd ~/Bash
git clone https://github.com/<DEIN-TOOL-REPO>/scripts.git .
chmod +x *.sh
```

---

## ⚙️ 2. `.zshrc` oder `.bashrc` anpassen

Füge am Ende deiner Datei folgendes hinzu:

```bash
# Tools ins PATH aufnehmen
export PATH="$HOME/Bash:$PATH"

# GitHub Token setzen (nur wenn setup-token nicht genutzt wird)
export GITHUB_TOKEN=ghp_ABC123...

# Befehle als Aliase
alias newproject="bash ~/Bash/newproject.sh"
alias push="bash ~/Bash/pushrepo.sh"
alias deleterepo="bash ~/Bash/delete_repo.sh"
```

Dann:

```bash
source ~/.zshrc  # oder source ~/.bashrc
```

---

## 🔐 3. GitHub Token einrichten (empfohlen)

```bash
cd ~/Bash
./setup-token
```

Das Skript fragt dich nach deinem GitHub-Personal Access Token und speichert es automatisch.

---

## 🚀 4. Projekt erstellen und live deployen

```bash
newproject mein-projekt
cd mein-projekt
push
```

Das Projekt wird automatisch auf GitHub erstellt, initialisiert und live auf **GitHub Pages** deployed.

---

## 🧪 Optional: Branches initialisieren

```bash
git checkout -b develop
git push -u origin develop

git checkout -b feature/demo
git push -u origin feature/demo
```

---

## 🧠 Tipp

Erstelle dein eigenes `tools-repo`, um das Setup mit anderen zu teilen – z. B.:
https://github.com/DeinBenutzername/se-tools


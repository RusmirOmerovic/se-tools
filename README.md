# 🧰 se-tools – GitHub Bash-Toolset für SE-Projekte

Mit diesem Repository richtest du dein Terminal so ein, dass du in wenigen Sekunden neue GitHub-Projekte aufsetzen, pushen und verwalten kannst – inkl. automatischer GitHub Pages-Veröffentlichung.

---

## 🚀 Funktionen

✅ Neues Projekt aus Template anlegen  
✅ Automatischer Commit & Push  
✅ GitHub Pages Deploy inklusive  
✅ Setup-Skript für GitHub Token  
✅ Löschen von lokalen Projektverzeichnissen  
✅ Schnellstart in < 5 Minuten

---

## ⚙️ Setup in 3 Schritten

### 1. Tools klonen & aktivieren

```bash
git clone https://github.com/RusmirOmerovic/se-tools.git ~/Bash
chmod +x ~/Bash/*.sh
```

### 2. Terminal einrichten (einmalig)

Öffne deine `.zshrc` oder `.bashrc` mit ls -a zum ansehen, dann nano .zshrc oder .bashrc oder open .zshrc/bashrc und füge hinzu:

```bash
export PATH="$HOME/Bash:$PATH"
alias newproject="bash ~/Bash/newproject.sh"
alias push="bash ~/Bash/pushrepo.sh"
alias deleterepo="bash ~/Bash/delete_repo.sh"
```

Dann:

```bash
source ~/.zshrc  # oder ~/.bashrc
```

### 3. Token einrichten

```bash
cd ~/Bash
./setup-token
```

---

## 📦 Projekt starten

```bash
newproject dashboard-demo
cd dashboard-demo
push
```

➡️ Dein Projekt ist live unter:  
`https://<dein-benutzername>.github.io/<projektname>/`

---

## 📘 Mehr Details?

👉 [Komplette Anleitung: setup.md](setup.md)

---

## 🧑‍💻 Getestet mit

- macOS mit zsh
- Linux (Ubuntu)
- GitHub CLI & Pages
- Git Bash (Windows)

---

## 📄 Lizenz

MIT – frei nutzbar, anpassbar und erweiterbar.

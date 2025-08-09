# se-tools

**se-tools** ist ein leichtgewichtiges Tool‑Set aus Bash‑Skripten, um neue Projekte in Sekunden anzulegen, sicher zu pushen, Repos zu löschen und standardisierte Merges/Deploys durchzuführen. Es richtet sich an DevOps‑/DevSecOps‑Workflows mit GitHub.

> **Kurzfassung:** `newproject` erzeugt ein neues Repo aus einer Template‑Vorlage, `pushrepo` pusht sicher mit Checks, `deleterepo` räumt lokal/remote auf, `merge-main`/`merge-test` automatisieren Merges. Optional integriert `projectnew` dein Projekt zusätzlich in Supabase (Projekte & Meilensteine).

---

## Inhalt des Repos

- `newproject` – neues Projekt aus Template anlegen und auf GitHub veröffentlichen
- `projectnew` – wie `newproject`, zusätzlich Anlage im Supabase‑Backend (Projekte & Milestones)
- `pushrepo` – sicherer Commit/Push inkl. Check auf sensible Dateien und `git pull --rebase`
- `deleterepo` – lokales Verzeichnis entfernen und GitHub‑Repo löschen (per `gh`)
- `merge-main` – Merge **testing → main** (Release auf Produktion)
- `merge-test` – Merge **develop → testing** (Staging aktualisieren)
- `.gitignore` – Standard‑Ignorierregeln für Node/macOS/Env‑Files

> Hinweis: Die Skripte verwenden ANSI‑Farben und Emojis für klare CLI‑Rückmeldungen.

---

## Voraussetzungen

- **Bash** (getestet ab Bash 4)
- **git** (inkl. gültiger globaler User‑Konfiguration)
- **GitHub CLI `gh`** (für Repo‑Löschen & ggf. Auth)
- **curl**
- **jq** (für JSON‑Operationen in API‑Calls, empfohlen)
- Optional für Editor‑Start: **VS Code** (`code` im PATH)
- Optional (für `projectnew`): **SUPABASE_URL** und **SUPABASE_SERVICE_ROLE** als Umgebungsvariablen

---

## Installation / Nutzung

1. **Repository klonen**
   ```bash
   git clone https://github.com/RusmirOmerovic/se-tools.git
   cd se-tools
   ```

2. **Skripte ausführbar machen**
   ```bash
   chmod +x newproject projectnew pushrepo deleterepo merge-main merge-test
   ```

3. **(Optional) ins PATH aufnehmen**
   ```bash
   mkdir -p ~/.local/bin
   cp newproject projectnew pushrepo deleterepo merge-main merge-test ~/.local/bin/
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # oder ~/.zshrc
   source ~/.bashrc
   ```

4. **GitHub‑Token einrichten**  
   `newproject`/`projectnew` nutzen einen Token‑Speicher unter `~/.config/se-tools/gh_token.txt` mit Drehung nach ~80 Tagen.  
   ```bash
   mkdir -p ~/.config/se-tools
   echo "<DEIN_GITHUB_TOKEN>" > ~/.config/se-tools/gh_token.txt
   chmod 600 ~/.config/se-tools/gh_token.txt
   ```
   **Scopes** (Empfehlung): `repo`, `workflow`, `delete_repo`.

---

## Schnellstart

### Neues Projekt (nur GitHub)
```bash
cd ~/code
newproject
# Interaktive Abfragen: Projektname, Template, ggf. Tokenprüfung
```

### Neues Projekt (GitHub + Supabase)
```bash
export SUPABASE_URL="https://<dein-projekt>.supabase.co"
export SUPABASE_SERVICE_ROLE="<service_role_jwt>"
projectnew
```

### Sicher pushen
```bash
pushrepo
# Führt Sicherheits‑Checks aus, commitet und pusht mit rebase‑Pull
```

### Repo aufräumen/löschen
```bash
deleterepo <repoName>
# Fragt nach lokalem Löschen und Remote‑Löschen (gh repo delete RusmirOmerovic/<repoName>)
```

### Merges
```bash
# testing -> main (Release)
merge-main

# develop -> testing (Staging aktualisieren)
merge-test
```

---

## Sicherheits‑Checks (pushrepo)

`pushrepo` prüft bekannte sensible Muster (z. B. `.env`, `.env.local`, `.DS_Store`, `*.key`, `secrets/`, `*.pem`, evtl. `.supabase/`). Wird etwas gefunden, bricht das Skript mit Hinweis ab, bevor versehentlich Geheimnisse committed werden.

---

## Supabase‑Integration (projectnew)

- Legt einen **Project‑Eintrag** und **Milestones** per `curl` am REST‑Endpoint an:
  - Tabellen: `projects`, `milestones` (erwartete Felder siehe Wiki)
  - Auth: `apikey` + `Authorization: Bearer <SERVICE_ROLE>` Header
- Gibt nach Erfolg direkte Links aus (GitHub‑Repo, Dashboard).

> Stelle sicher, dass die RLS‑Regeln und Tabellenstruktur in Supabase zu deinen Anforderungen passen. Details im Wiki.

---

## Best Practices

- Vor `merge-*`: Arbeitsbaum sauber halten (`git status`), lokal rebasen.
- Branch‑Strategie: `develop` → `testing` → `main` (Production).
- **Secrets niemals commiten** – nutze `.env` lokal und Actions‑Secrets in GitHub.
- Token im Ordner `~/.config/se-tools` mit `600`‑Rechten speichern.
- Optional: GitHub Actions für Lint/Build/Test/Deploy (siehe Wiki).

---

## Mitwirken

PRs und Issues sind willkommen. Bitte halte dich an die Sicherheitsleitlinien (keine Secrets in Beispielen) und bevorzuge kleine, nachvollziehbare Commits.

---

## Lizenz

*(Füge hier dein gewünschtes Lizenzmodell ein, z. B. MIT.)*

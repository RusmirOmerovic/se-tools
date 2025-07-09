#!/bin/bash

# === KONFIGURATION ===
TEMPLATE_REPO="https://github.com/RusmirOmerovic/html-template-se.git"
USERNAME="RusmirOmerovic"
GITHUB_API="https://api.github.com"
PROJEKTPFAD="$(pwd)"

# === EINGABEPRÜFUNG ===
if [ -z "$1" ]; then
  echo "❌ Fehler: Bitte gib einen Projektnamen an: newproject <projektname>"
  exit 1
fi

PROJECT_NAME=$1
ZIELORDNER="$PROJEKTPFAD/$PROJECT_NAME"

# === SCHRITT 1: Verzeichnis erstellen ===
echo "📦 Erstelle Projekt: $PROJECT_NAME in $ZIELORDNER ..."
mkdir -p "$ZIELORDNER"
cd "$ZIELORDNER" || exit

# === SCHRITT 2: Template klonen ===
echo "📥 Klone Template..."
git clone "$TEMPLATE_REPO" .
rm -rf .git
git init
git add .
git commit -m "🆕 Neues Projekt aus Template: $PROJECT_NAME"

# === SCHRITT 3: GitHub-Repo erstellen über API ===
echo "🌐 Erstelle GitHub-Repository..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
  -d "{\"name\":\"$PROJECT_NAME\", \"private\":false}" \
  "$GITHUB_API/user/repos")

if [ "$RESPONSE" = "201" ]; then
  echo "✅ GitHub-Repo erstellt: https://github.com/$USERNAME/$PROJECT_NAME"
else
  echo "❌ Fehler beim Erstellen des GitHub-Repos (Statuscode $RESPONSE)"
  exit 1
fi

# === SCHRITT 4: Remote setzen und pushen ===
git remote add origin "https://github.com/$USERNAME/$PROJECT_NAME.git"
git branch -M main
git push -u origin main

# === SCHRITT 5: Editor öffnen ===
if command -v code &> /dev/null; then
  code .
fi

echo "🎉 Projekt '$PROJECT_NAME' wurde lokal erstellt und auf GitHub veröffentlicht!"
#!/bin/bash

# Farben
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Projektname & Branch
PROJECT_NAME=$(basename "$(pwd)")
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo -e "${CYAN}📁 Projekt: $PROJECT_NAME  |  🌿 Branch: $BRANCH${NC}"

# Lock-Dateien prüfen und löschen
LOCKS=(".git/index.lock" ".git/ORIG_HEAD.lock" ".git/refs/remotes/origin/$BRANCH.lock")
for lock in "${LOCKS[@]}"; do
  if [ -f "$lock" ]; then
    echo -e "${RED}⚠️  Lock-Datei gefunden: $lock – wird entfernt...${NC}"
    rm -f "$lock"
  fi
done

# Unstaged Changes prüfen
if ! git diff --quiet; then
  echo -e "${RED}❌ Du hast noch nicht gespeicherte Änderungen im Arbeitsverzeichnis.${NC}"
  git status
  echo -e "${CYAN}💡 Bitte committest oder stashst zuerst manuell.${NC}"
  exit 1
fi

# Git Pull (nur wenn sauber)
echo "🔄 Hole aktuelle Änderungen von GitHub (git pull)..."
git pull --rebase origin "$BRANCH"
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Fehler beim Pull – bitte Konflikte manuell lösen.${NC}"
  exit 1
fi

# Dateien hinzufügen
git add .

# Commit-Nachricht
read -r -p "📝 Commit-Nachricht (ENTER = Auto-Nachricht): " message
if [ -z "$message" ]; then
  message="📦 Update: $(date '+%Y-%m-%d %H:%M') – Automatischer Push"
fi

# Commit
git commit -m "$message" 2>/dev/null
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Commit erfolgreich.${NC}"
else
  echo -e "${CYAN}ℹ️  Keine neuen Änderungen zum Committen.${NC}"
fi

# Push
echo "📤 Push läuft..."
git push origin "$BRANCH"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Push abgeschlossen!${NC}"
else
  echo -e "${RED}❌ Push fehlgeschlagen – evtl. vorher Pull nötig.${NC}"
fi

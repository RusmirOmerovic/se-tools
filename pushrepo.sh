#!/bin/bash

# Farben
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Projektname & Branch
PROJECT_NAME=$(basename "$(pwd)")
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo -e "${CYAN}📁 Projekt: $PROJECT_NAME  |  🌿 Branch: $BRANCH${NC}"
echo "🔄 Hole aktuelle Änderungen von GitHub (git pull)..."
git pull origin "$BRANCH"

# Benutzerdefinierte Commit-Message oder Fallback
read -r -p "📝 Commit-Nachricht (ENTER = Auto-Nachricht): " message
if [ -z "$message" ]; then
  message="📦 Update: $(date '+%Y-%m-%d %H:%M') – Automatischer Push"
fi

# Git push
echo "📤 Commit und Push läuft..."
git add .
git commit -m "$message"
git push origin "$BRANCH"

echo -e "${GREEN}✅ Push abgeschlossen!${NC}"
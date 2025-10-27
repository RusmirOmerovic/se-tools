#!/usr/bin/env bash
set -euo pipefail

# ---------- Usage ----------
usage() {
  cat <<'USAGE'
gh-import-backlog.sh --owner <USER_OR_ORG> --repo <owner/repo> \
  --project "<Project Name oder #Nummer>" --csv </pfad/datei.csv> \
  [--mode issues|drafts] [--create-project] [--dry-run] [--update]

CSV erwartet Header:
Phase,Nr,Aufgabe,Status,Priorität,Beschreibung

Beispiele:
  gh-import-backlog.sh --owner RusmirOmerovic --repo RusmirOmerovic/SLA-Vorlage \
    --project "Projektplan SLA-Vorlage" --csv docs/Backlog_SLA-Vorlage.csv --mode issues --update
USAGE
  exit 1
}

# ---------- Args ----------
OWNER=""; REPO=""; PROJECT_ARG=""; CSV_PATH=""; MODE="issues"
CREATE_PROJECT=false; DRY_RUN=false; DO_UPDATE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2;;
    --repo) REPO="$2"; shift 2;;
    --project) PROJECT_ARG="$2"; shift 2;;
    --csv) CSV_PATH="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --create-project) CREATE_PROJECT=true; shift;;
    --dry-run) DRY_RUN=true; shift;;
    --update) DO_UPDATE=true; shift;;
    -h|--help) usage;;
    *) echo "Unbekanntes Argument: $1"; usage;;
  esac
done

[[ -z "$OWNER" || -z "$REPO" || -z "$PROJECT_ARG" || -z "$CSV_PATH" ]] && usage
[[ -f "$CSV_PATH" ]] || { echo "❌ CSV nicht gefunden: $CSV_PATH"; exit 1; }
command -v gh >/dev/null || { echo "❌ gh CLI fehlt. Installiere: https://cli.github.com/"; exit 1; }
command -v jq >/dev/null || { echo "❌ jq fehlt. Installiere: https://stedolan.github.io/jq/"; exit 1; }

echo "➡️  Owner: $OWNER"
echo "➡️  Repo: $REPO"
echo "➡️  Project: $PROJECT_ARG"
echo "➡️  CSV: $CSV_PATH"
echo "➡️  Modus: $MODE"
$CREATE_PROJECT && echo "➡️  create-project: ON"
$DRY_RUN && echo "➡️  dry-run: ON"
$DO_UPDATE && echo "➡️  update: ON"
echo

# ---------- Project Nummer ----------
PROJECT_NUMBER=""
if [[ "$PROJECT_ARG" =~ ^#?[0-9]+$ ]]; then
  PROJECT_NUMBER="${PROJECT_ARG#\#}"
else
  RAW=$(gh api graphql -f login="$OWNER" -f title="$PROJECT_ARG" -f query='
    query($login:String!, $title:String!) {
      user(login:$login) { projectsV2(first:100, query:$title) { nodes { title number } } }
      organization(login:$login) { projectsV2(first:100, query:$title) { nodes { title number } } }
    }' 2>/dev/null || echo "{}")

  PROJECT_NUMBER=$(echo "$RAW" | jq -r --arg T "$PROJECT_ARG" '
    [(.user.projectsV2.nodes? // []), (.organization.projectsV2.nodes? // [])]
    | add | map(select(.title == $T)) | (.[0].number // empty)
  ')

  if [[ -z "${PROJECT_NUMBER}" ]]; then
    if $CREATE_PROJECT; then
      echo "🆕 Erstelle Project: $PROJECT_ARG"
      PROJECT_NUMBER=$(gh project create --owner "$OWNER" --title "$PROJECT_ARG" --format json --jq '.number')
    else
      echo "❌ Project nicht gefunden: $PROJECT_ARG"
      exit 1
    fi
  fi
fi
echo "✅ Project-Nr: #$PROJECT_NUMBER"
echo

# ---------- Felder ----------
field_exists() {
  local FIELD="$1"
  gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
  | jq -e --arg NAME "$FIELD" '
      (if type=="array" then . else (.fields? // .nodes? // .items? // []) end)
      | map(select(.name==$NAME)) | length > 0
    ' >/dev/null
}
ensure_field() { gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "$1" --data-type "$2" >/dev/null 2>&1 || true; }
ensure_select_field() { gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "$1" --data-type "SINGLE_SELECT" --single-select-options "$2" >/dev/null 2>&1 || true; }

echo "🔧 Prüfe Project-Felder..."
ensure_field "Phase" "TEXT"
ensure_field "Nr" "NUMBER"
ensure_field "Priorität" "TEXT"
ensure_select_field "Status" "To Do,In Progress,Done"
echo

# ---------- Labels ----------
if [[ "$MODE" == "issues" ]]; then
  echo "🏷️  Prüfe Labels im Repository..."
  gh label create "backlog" -R "$REPO" --color "d4c5f9" >/dev/null 2>&1 || true
  for p in 1 2 3 4 5; do gh label create "phase:$p" -R "$REPO" --color "0e8a16" >/dev/null 2>&1 || true; done
  for prio in Niedrig Mittel Hoch; do gh label create "prio:$prio" -R "$REPO" --color "fbca04" >/dev/null 2>&1 || true; done
  echo "✅ Labels bereit"
  echo
fi

# ---------- Hilfsfunktionen ----------
map_status() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    "to do"|"todo"|"open") echo "To Do";;
    "in progress"|"doing"|"wip"|"in arbeit") echo "In Progress";;
    "done"|"erledigt"|"closed") echo "Done";;
    *) echo "To Do";;
  esac
}
find_issue_url_by_title() {
  local TITLE="$1"
  gh issue list -R "$REPO" --state all --limit 1000 --json title,url \
  | jq -r --arg T "$TITLE" '.[] | select(.title==$T) | .url' | head -n1
}

# ---------- CSV-Verarbeitung ----------
echo "📥 Import starte..."
tail -n +2 "$CSV_PATH" | while IFS=, read -r PHASE NR AUFGABE STATUS PRIORITAET BESCHREIBUNG; do
  [[ -z "$AUFGABE" ]] && continue
  STATUS=$(map_status "$STATUS")
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📌 $AUFGABE"
  echo "   Status: $STATUS | Priorität: $PRIORITAET | Phase: $PHASE"

  $DRY_RUN && { echo "   [DRY-RUN] Überspringe..."; continue; }

  ISSUE_URL=$(find_issue_url_by_title "$AUFGABE" 2>/dev/null || true)
  if [[ -n "$ISSUE_URL" ]]; then
    echo "   ℹ️  Issue existiert bereits: $ISSUE_URL"
    if $DO_UPDATE; then
      gh issue edit "$ISSUE_URL" -R "$REPO" --body "**Phase:** $PHASE
**Nr:** $NR
**Priorität:** $PRIORITAET

$BESCHREIBUNG" >/dev/null
    fi
  else
    echo "   ✨ Erstelle neues Issue..."
    ISSUE_JSON=$(gh api -X POST "repos/$REPO/issues" \
      -F "title=$AUFGABE" \
      -F "body=**Phase:** $PHASE

**Nr:** $NR
**Priorität:** $PRIORITAET

$BESCHREIBUNG" \
      -F 'labels=["backlog"]' 2>/dev/null || echo "{}")
    ISSUE_URL=$(echo "$ISSUE_JSON" | jq -r '.html_url // empty')
    [[ -z "$ISSUE_URL" ]] && continue
    echo "   ✅ Issue erstellt: $ISSUE_URL"
  fi

  echo "   📎 Füge zum Project hinzu..."
  ITEM_JSON=$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$ISSUE_URL" --format json 2>/dev/null || echo "{}")
  ITEM_ID=$(echo "$ITEM_JSON" | jq -r '.id // empty')
  if [[ -n "$ITEM_ID" ]]; then
    gh project item-edit "$PROJECT_NUMBER" --owner "$OWNER" --id "$ITEM_ID" --field "Phase" --value "$PHASE" >/dev/null
    gh project item-edit "$PROJECT_NUMBER" --owner "$OWNER" --id "$ITEM_ID" --field "Nr" --value "$NR" >/dev/null
    gh project item-edit "$PROJECT_NUMBER" --owner "$OWNER" --id "$ITEM_ID" --field "Priorität" --value "$PRIORITAET" >/dev/null
    gh project item-edit "$PROJECT_NUMBER" --owner "$OWNER" --id "$ITEM_ID" --field "Status" --value "$STATUS" >/dev/null
    echo "   ✅ Erfolgreich verarbeitet"
  fi
done

echo
echo "✅ Import abgeschlossen!"

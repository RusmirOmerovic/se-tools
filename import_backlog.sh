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
command -v gh >/dev/null || { echo "❌ gh CLI fehlt"; exit 1; }
command -v jq >/dev/null || { echo "❌ jq fehlt"; exit 1; }

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
  if [[ -z "$PROJECT_NUMBER" ]]; then
    if $CREATE_PROJECT; then
      echo "🆕 Erstelle Project: $PROJECT_ARG"
      PROJECT_NUMBER=$(gh project create --owner "$OWNER" --title "$PROJECT_ARG" --format json --jq '.number')
      [[ -z "$PROJECT_NUMBER" ]] && { echo "❌ Projekt-Erstellung fehlgeschlagen"; exit 1; }
      echo "✅ Project erstellt: #$PROJECT_NUMBER"
    else
      echo "❌ Project nicht gefunden: $PROJECT_ARG"; exit 1
    fi
  fi
fi
echo "✅ Project-Nr: #$PROJECT_NUMBER"
echo

# ---------- Felder sicherstellen ----------
ensure_field()         { gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "$1" --data-type "$2" >/dev/null 2>&1 || true; }
ensure_select_field()  { gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "$1" --data-type "SINGLE_SELECT" --single-select-options "$2" >/dev/null 2>&1 || true; }

echo "🔧 Prüfe Project-Felder..."
ensure_field "Phase" "TEXT"
ensure_field "Nr" "NUMBER"
ensure_field "Priorität" "TEXT"
ensure_select_field "Status" "To Do,In Progress,Done"
echo

# ---------- Labels (für issues) ----------
if [[ "$MODE" == "issues" ]]; then
  echo "🏷️  Prüfe Labels im Repository..."
  gh label create "backlog" -R "$REPO" --color "d4c5f9" >/dev/null 2>&1 || true
  for p in 1 2 3 4 5; do gh label create "phase:$p" -R "$REPO" --color "0e8a16" >/dev/null 2>&1 || true; done
  for prio in Niedrig Mittel Hoch; do gh label create "prio:$prio" -R "$REPO" --color "fbca04" >/dev/null 2>&1 || true; done
  echo
fi

# ---------- Mapper & Finder ----------
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

# --- Project- und Feld-IDs besorgen ---
PROJECT_NODE_ID=$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.id')
FIELDS_JSON=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json | jq '.fields')

# Helper: hole Feld-ID nach Name, egal wie die Struktur aussieht
field_id_by_name () {
  local name="$1"
  echo "$FIELDS_JSON" | jq -r --arg NAME "$name" '
    .[] | select(.name == $NAME) | .id
  ' | head -n1
}

FIELD_PHASE_ID=$(field_id_by_name "Phase")
FIELD_NR_ID=$(field_id_by_name "Nr")
FIELD_PRIO_ID=$(field_id_by_name "Priorität")
FIELD_STATUS_ID=$(field_id_by_name "Status")

# Option-ID für Statuswerte (To Do / In Progress / Done)
status_option_id () {
  local status="$1"
  echo "$FIELDS_JSON" | jq -r --arg VAL "$status" '
    .[] | select(.name=="Status") | .options[] | select(.name==$VAL) | .id
  ' | head -n1
}

map_status() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    "todo"|"to do"|"todo "*)      echo "Todo" ;;
    "in progress"|"doing"|"wip"*) echo "In Progress" ;;
    "done"|"erledigt"|"closed"*)  echo "Done" ;;
    *)                            echo "Todo" ;;
  esac
}


# --- Helfer: Item zum Project + Felder setzen ---
add_to_project() {
  local issue_url="$1"
  local item_json item_id
  item_json=$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$issue_url" --format json 2>/dev/null || echo "{}")
  item_id=$(echo "$item_json" | jq -r '.id // empty')
  echo "$item_id"
}
set_fields() {
  local item_id="$1" phase="$2" nr="$3" prio="$4" status="$5"
  [[ -z "$item_id" ]] && return 0
  gh project item-edit --id "$item_id" --project-id "$PROJECT_NODE_ID" --field-id "$FIELD_PHASE_ID" --text "$phase"   >/dev/null || true
  gh project item-edit --id "$item_id" --project-id "$PROJECT_NODE_ID" --field-id "$FIELD_PRIO_ID"  --text "$prio"    >/dev/null || true
  gh project item-edit --id "$item_id" --project-id "$PROJECT_NODE_ID" --field-id "$FIELD_NR_ID"    --number "$nr"    >/dev/null || true
  local opt_id; opt_id=$(status_option_id "$status")
  [[ -n "$opt_id" ]] && gh project item-edit --id "$item_id" --project-id "$PROJECT_NODE_ID" --field-id "$FIELD_STATUS_ID" --single-select-option-id "$opt_id" >/dev/null || true
}

# ---------- CSV-Verarbeitung ----------
echo "📥 Import starte..."
tail -n +2 "$CSV_PATH" | while IFS=, read -r PHASE NR AUFGABE STATUS PRIORITAET BESCHREIBUNG; do
  [[ -z "${AUFGABE//\"/}" ]] && continue
  PHASE=${PHASE//\"/}; NR=${NR//\"/}; AUFGABE=${AUFGABE//\"/}
  STATUS=$(map_status "${STATUS//\"/}"); PRIORITAET=${PRIORITAET//\"/}
  BESCHREIBUNG=${BESCHREIBUNG//\"/}

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

$BESCHREIBUNG" >/dev/null || true
    fi
  else
    echo "   ✨ Erstelle neues Issue..."
    BODY="**Phase:** $PHASE

**Nr:** $NR
**Priorität:** $PRIORITAET

$BESCHREIBUNG"
    ISSUE_URL=$(
      gh issue create -R "$REPO" -t "$AUFGABE" -b "$BODY" -l "backlog" --json url --jq .url 2>/dev/null || true
    )
    if [[ -z "$ISSUE_URL" ]]; then
      # Fallback, falls ältere gh-Version kein --json unterstützt
      CREATE_OUT=$(gh issue create -R "$REPO" -t "$AUFGABE" -b "$BODY" -l "backlog" 2>&1 || true)
      ISSUE_URL=$(echo "$CREATE_OUT" | grep -Eo 'https://github.com/[^ ]+/issues/[0-9]+' | head -n1)
      [[ -z "$ISSUE_URL" ]] && { echo "   ❌ Issue-Erstellung fehlgeschlagen"; echo "$CREATE_OUT"; continue; }
    fi
    echo "   ✅ Issue erstellt: $ISSUE_URL"
  fi

  echo "   📎 Füge zum Project hinzu & setze Felder…"
  ITEM_ID=$(add_to_project "$ISSUE_URL")
  set_fields "$ITEM_ID" "$PHASE" "$NR" "$PRIORITAET" "$STATUS"
  echo "   ✅ Erfolgreich verarbeitet"
done

echo
echo "✅ Import abgeschlossen!"

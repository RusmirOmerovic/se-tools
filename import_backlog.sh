#!/usr/bin/env bash
set -euo pipefail

# ---------- Usage ----------
usage() {
  cat <<'USAGE'
gh-import-backlog.sh --owner <USER_OR_ORG> --repo <owner/repo> \
  --project "<Project Name oder #Nummer>" --csv </pfad/datei.csv> \
  [--mode issues|drafts] [--create-project] [--dry-run]

Beispiele:
  gh-import-backlog.sh --owner RusmirOmerovic --repo RusmirOmerovic/SLA-Vorlage \
    --project "Projektplan SLA-Vorlage" --csv docs/Backlog_SLA-Vorlage.csv --mode issues

  gh-import-backlog.sh --owner RusmirOmerovic --repo RusmirOmerovic/SLA-Vorlage \
    --project "#12" --csv backlog.csv --mode drafts
USAGE
  exit 1
}

# ---------- Args ----------
OWNER=""; REPO=""; PROJECT_ARG=""; CSV_PATH=""; MODE="issues"; CREATE_PROJECT=false; DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2;;
    --repo) REPO="$2"; shift 2;;
    --project) PROJECT_ARG="$2"; shift 2;;
    --csv) CSV_PATH="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;                # issues | drafts
    --create-project) CREATE_PROJECT=true; shift;;
    --dry-run) DRY_RUN=true; shift;;
    -h|--help) usage;;
    *) echo "Unbekanntes Argument: $1"; usage;;
  esac
done

[[ -z "$OWNER" || -z "$REPO" || -z "$PROJECT_ARG" || -z "$CSV_PATH" ]] && usage
[[ -f "$CSV_PATH" ]] || { echo "CSV nicht gefunden: $CSV_PATH"; exit 1; }
command -v gh >/dev/null || { echo "gh fehlt"; exit 1; }
command -v jq >/dev/null || { echo "jq fehlt"; exit 1; }

echo "➡️  Owner:          $OWNER"
echo "➡️  Repo:           $REPO"
echo "➡️  Project:        $PROJECT_ARG"
echo "➡️  CSV:            $CSV_PATH"
echo "➡️  Modus:          $MODE"
$CREATE_PROJECT && echo "➡️  create-project: ON"
$DRY_RUN && echo "➡️  dry-run: ON"
echo

# ---------- Project Nummer ermitteln / anlegen ----------
PROJECT_NUMBER=""
if [[ "$PROJECT_ARG" =~ ^#?[0-9]+$ ]]; then
  PROJECT_NUMBER="${PROJECT_ARG#\#}"
else
  PROJECT_NUMBER=$(gh project list --owner "$OWNER" --format json \
    | jq -r ".[] | select(.title==\"$PROJECT_ARG\") | .number")
  if [[ -z "${PROJECT_NUMBER}" ]]; then
    if $CREATE_PROJECT; then
      echo "🆕 Erstelle Project: $PROJECT_ARG"
      PROJECT_NUMBER=$(gh project create --owner "$OWNER" --title "$PROJECT_ARG" \
        --format json | jq -r '.number')
    else
      echo "❌ Project nicht gefunden: $PROJECT_ARG (nutze --create-project, um anzulegen)"; exit 1
    fi
  fi
fi
echo "✅ Project-Nr: #$PROJECT_NUMBER"
echo

# ---------- Felder sicherstellen ----------
ensure_field() {
  local NAME="$1"; local TYPE="$2"
  gh project field-list --owner "$OWNER" --project "$PROJECT_NUMBER" --format json \
    | jq -e ".[] | select(.name==\"$NAME\")" >/dev/null || {
      echo "➕ Feld anlegen: $NAME ($TYPE)"
      gh project field-create --owner "$OWNER" --project "$PROJECT_NUMBER" \
        --name "$NAME" --data-type "$TYPE" >/dev/null
    }
}

ensure_field "Phase" "TEXT"
ensure_field "Nr" "NUMBER"
ensure_field "Priorität" "TEXT"
# Status ist meist vorhanden – falls nicht, Single-Select:
if ! gh project field-list --owner "$OWNER" --project "$PROJECT_NUMBER" --format json \
     | jq -e '.[] | select(.name=="Status")' >/dev/null; then
  echo "➕ Feld anlegen: Status (SINGLE_SELECT)"
  gh project field-create --owner "$OWNER" --project "$PROJECT_NUMBER" \
    --name "Status" --data-type "SINGLE_SELECT" \
    --single-select-options "To Do,In Progress,Done" >/dev/null
fi
echo

# ---------- Labels vorbereiten (nur wenn MODE=issues) ----------
if [[ "$MODE" == "issues" ]]; then
  echo "🏷️  Basis-Labels prüfen"
  gh label create "backlog" -R "$REPO" >/dev/null 2>&1 || true
  for p in 1 2 3 4 5; do gh label create "phase:$p" -R "$REPO" >/dev/null 2>&1 || true; done
  for prio in Niedrig Mittel Hoch; do gh label create "prio:$prio" -R "$REPO" >/dev/null 2>&1 || true; done
  echo
fi

# ---------- Helfer: Status-Mapping ----------
map_status() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    "to do"|"todo"|"to-do"|"open") echo "To Do";;
    "in progress"|"doing"|"wip")   echo "In Progress";;
    "done"|"erledigt"|"geschlossen") echo "Done";;
    *) echo "To Do";;
  esac
}

# ---------- CSV einlesen und verarbeiten ----------
echo "📥 Import starte…"
# Erwartete CSV: Phase,Nr,Aufgabe,Status,Priorität,Beschreibung
tail -n +2 "$CSV_PATH" | while IFS=, read -r PHASE NR AUFGABE STATUS PRIORITAET BESCHREIBUNG; do
  # Quotes & Whitespace trimmen
  PHASE=${PHASE//\"/}; NR=${NR//\"/}; AUFGABE=${AUFGABE//\"/}
  STATUS=$(map_status "${STATUS//\"/}"); PRIORITAET=${PRIORITAET//\"/}
  BESCHREIBUNG=${BESCHREIBUNG//\"/}
  PHASE_TRIM=$(echo "$PHASE" | xargs); AUFGABE_TRIM=$(echo "$AUFGABE" | xargs)
  PRIORITAET_TRIM=$(echo "$PRIORITAET" | xargs); BESCHREIBUNG_TRIM=$(echo "$BESCHREIBUNG" | xargs)

  [[ -z "$AUFGABE_TRIM" ]] && continue

  echo "• $AUFGABE_TRIM  [$STATUS | $PRIORITAET_TRIM | $PHASE_TRIM]"

  if $DRY_RUN; then
    continue
  fi

  if [[ "$MODE" == "issues" ]]; then
    # Issue erstellen
    PHASE_NUM=$(echo "$PHASE_TRIM" | sed -nE 's/.*([0-9]+).*/\1/p' || true)
    LABELS="backlog"
    [[ -n "$PHASE_NUM" ]] && LABELS="$LABELS,phase:$PHASE_NUM"
    [[ -n "$PRIORITAET_TRIM" ]] && LABELS="$LABELS,prio:$PRIORITAET_TRIM"

    ISSUE_JSON=$(gh issue create -R "$REPO" \
      --title "$AUFGABE_TRIM" \
      --body $"Phase: $PHASE_TRIM\nNr: $NR\nPriorität: $PRIORITAET_TRIM\n\n$BESCHREIBUNG_TRIM" \
      --label "$LABELS" --format json)
    ISSUE_URL=$(echo "$ISSUE_JSON" | jq -r '.url')

    # Ins Project aufnehmen
    ITEM_ID=$(gh project item-add --owner "$OWNER" --project "$PROJECT_NUMBER" \
      --url "$ISSUE_URL" --format json --jq '.id')
  else
    # Draft-Item direkt im Project
    ITEM_ID=$(gh project item-add --owner "$OWNER" --project "$PROJECT_NUMBER" \
      --title "$AUFGABE_TRIM" --format json --jq '.id')
  fi

  # Felder setzen
  gh project item-edit --owner "$OWNER" --project "$PROJECT_NUMBER" \
    --id "$ITEM_ID" --field "Phase" --value "$PHASE_TRIM" >/dev/null
  gh project item-edit --owner "$OWNER" --project "$PROJECT_NUMBER" \
    --id "$ITEM_ID" --field "Nr" --value "$NR" >/dev/null
  gh project item-edit --owner "$OWNER" --project "$PROJECT_NUMBER" \
    --id "$ITEM_ID" --field "Priorität" --value "$PRIORITAET_TRIM" >/dev/null
  gh project item-edit --owner "$OWNER" --project "$PROJECT_NUMBER" \
    --id "$ITEM_ID" --field "Status" --value "$STATUS" >/dev/null
done

echo
echo "✅ Fertig. Project: https://github.com/$OWNER/projects/$PROJECT_NUMBER"


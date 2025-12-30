#!/usr/bin/env bash
set -u

# =========================
# ARC1-M2 — Le Livre des Rites
# Auto-check Debian stable
# Usage: ./check_arc1_m2.sh STUDENT_ID
# Sortie structurée (1 ligne) :
# RESULT;STUDENT_ID;ARC_ID;MISSION_ID;SCORE;SCORE_MAX;XP;BADGES
# =========================

ARC_ID="ARC1"
MISSION_ID="ARC1-M2"
SCORE_MAX=20

STUDENT_ID="${1:-}"
if [[ -z "$STUDENT_ID" ]]; then
  echo "Erreur: STUDENT_ID manquant."
  echo "Usage: $0 MON_ID_ETUDIANT"
  exit 2
fi

BASE_DIR="$HOME/linux101/ARC1/M2"
RESULTS_DIR="$HOME/linux101/results"
mkdir -p "$RESULTS_DIR"

score=0
badges=()

# Poids : 2,2,3,3,5,5
w_q1=2; w_q2=2; w_q3=3; w_q4=3; w_q5=5; w_q6=5

ok_q1=0; ok_q2=0; ok_q3=0; ok_q4=0; ok_q5=0; ok_q6=0

print_check() {
  local q="$1" status="$2" pts="$3" maxpts="$4"
  printf "%-10s : %-10s (%s/%s)\n" "$q" "$status" "$pts" "$maxpts"
}

require_file() { [[ -f "$1" ]]; }
contains() { grep -qE "$2" "$1"; }
non_empty() { [[ -s "$1" ]]; }

expected_flag() {
  echo -n "${STUDENT_ID}-ARC1-M2" | sha256sum | awk '{print substr($1,1,12)}'
}

check_q1() {
  local f="$BASE_DIR/man_ls_synopsis.txt"
  require_file "$f" || return 1
  contains "$f" "^SOURCE=man ls" || return 1
  contains "$f" "SYNOPSIS" || return 1
  contains "$f" "(^|[[:space:]])ls([[:space:]]|$)" || return 1
  return 0
}

check_q2() {
  local f="$BASE_DIR/help_ls_options.txt"
  require_file "$f" || return 1
  contains "$f" "^SOURCE=ls --help" || return 1
  contains "$f" "^OPTION_A=.+" || return 1
  contains "$f" "^OPTION_L=.+" || return 1
  contains "$f" "(-a|--all)" || return 1
  contains "$f" "(-l|--format)" || return 1
  return 0
}

check_q3() {
  local f="$BASE_DIR/info_extract.txt"
  require_file "$f" || return 1
  contains "$f" "^SOURCE=info" || return 1
  # Accepte soit preuve info, soit fallback man
  if contains "$f" "^FALLBACK=man ls"; then
    contains "$f" "(^|[[:space:]])ls([[:space:]]|$)" || return 1
    return 0
  fi
  # Indices fréquents dans les exports info
  contains "$f" "(Invoking ls|ls invocation|coreutils|GNU)" || return 1
  return 0
}

check_q4() {
  local report="$BASE_DIR/search_report.txt"
  local proof="$BASE_DIR/du_proof.txt"
  require_file "$report" || return 1
  require_file "$proof" || return 1

  contains "$report" "^QUERY=disk usage" || return 1
  contains "$report" "^SEARCH_TOOL=(apropos|man -k)" || return 1
  contains "$report" "^SELECTED=du" || return 1
  contains "$report" "^JUSTIFICATION=.+" || return 1

  contains "$proof" "linux101/ARC1" || return 1
  return 0
}

check_q5() {
  local flagf="$BASE_DIR/flag_ARC1_M2_${STUDENT_ID}.txt"
  local method="$BASE_DIR/rite_method.txt"
  local card="$BASE_DIR/command_card.md"

  require_file "$flagf" || return 1
  require_file "$method" || return 1
  require_file "$card" || return 1

  local exp got
  exp="$(expected_flag)"
  got="$(tr -d '\r\n ' < "$flagf" 2>/dev/null || true)"
  [[ "$got" == "$exp" ]] || return 1

  non_empty "$method" || return 1
  non_empty "$card" || return 1
  return 0
}

check_q6() {
  local dossier="$BASE_DIR/ritual_dossier.txt"
  local p1="$BASE_DIR/proof_mkdir_p.txt"
  local p2="$BASE_DIR/proof_ls_al.txt"
  local p3="$BASE_DIR/proof_grep_i.txt"

  require_file "$dossier" || return 1
  require_file "$p1" || return 1
  require_file "$p2" || return 1
  require_file "$p3" || return 1

  # Vérifie structure A/B/C (souple mais réel)
  contains "$dossier" "A" || return 1
  contains "$dossier" "B" || return 1
  contains "$dossier" "C" || return 1
  contains "$dossier" "NEED=" || return 1
  contains "$dossier" "SOURCE=" || return 1
  contains "$dossier" "COMMAND=" || return 1
  contains "$dossier" "WHY=" || return 1

  # Preuves cohérentes
  contains "$p1" "boss" || return 1
  contains "$p2" "\.secret|boss" || return 1
  contains "$p3" "(Alpha|ALPHA|alpha)" || return 1

  return 0
}

echo "== Auto-correction $MISSION_ID — Sentinelle: $STUDENT_ID =="
echo "Dossier vérifié: $BASE_DIR"
echo

if check_q1; then ok_q1=1; score=$((score+w_q1)); print_check "Q1" "OK" "$w_q1" "$w_q1"
else print_check "Q1" "A corriger" 0 "$w_q1"; fi

if check_q2; then ok_q2=1; score=$((score+w_q2)); print_check "Q2" "OK" "$w_q2" "$w_q2"
else print_check "Q2" "A corriger" 0 "$w_q2"; fi

if check_q3; then ok_q3=1; score=$((score+w_q3)); print_check "Q3" "OK" "$w_q3" "$w_q3"
else print_check "Q3" "A corriger" 0 "$w_q3"; fi

if check_q4; then ok_q4=1; score=$((score+w_q4)); print_check "Q4" "OK" "$w_q4" "$w_q4"
else print_check "Q4" "A corriger" 0 "$w_q4"; fi

if check_q5; then ok_q5=1; score=$((score+w_q5)); print_check "Q5" "OK" "$w_q5" "$w_q5"
else print_check "Q5" "A corriger" 0 "$w_q5"; fi

if check_q6; then ok_q6=1; score=$((score+w_q6)); print_check "Q6" "OK" "$w_q6" "$w_q6"
else print_check "Q6" "A corriger" 0 "$w_q6"; fi

echo
xp=$((score*10))

# Badges (univers cohérent)
if [[ "$score" -ge 10 ]]; then badges+=("Lecteur_des_Runes"); fi
if [[ "$score" -ge 16 ]]; then badges+=("Archiviste_du_Livre"); fi
if [[ "$ok_q5" -eq 1 ]]; then badges+=("Porteur_du_Sceau"); fi
if [[ "$score" -eq "$SCORE_MAX" ]]; then badges+=("Maître_des_Rites_Niveau_I"); fi

badges_str="Aucun"
if [[ "${#badges[@]}" -gt 0 ]]; then
  badges_str="$(IFS=,; echo "${badges[*]}")"
fi

printf "Score: %d/%d | XP: %d | Badges: %s\n" "$score" "$SCORE_MAX" "$xp" "$badges_str"
echo "RESULT;${STUDENT_ID};${ARC_ID};${MISSION_ID};${score};${SCORE_MAX};${xp};${badges_str}"

echo "$(date -Is);RESULT;${STUDENT_ID};${ARC_ID};${MISSION_ID};${score};${SCORE_MAX};${xp};${badges_str}" \
  >> "${RESULTS_DIR}/arc1_m2_results.log"

if [[ "$score" -eq "$SCORE_MAX" ]]; then
  exit 0
else
  exit 1
fi

#!/usr/bin/env bash
set -u

# =========================
# ARC1-M1 — La Porte Noire
# Auto-check Debian stable
# Usage: ./check_arc1_m1.sh STUDENT_ID
# Sortie structurée (1 ligne) :
# RESULT;STUDENT_ID;ARC_ID;MISSION_ID;SCORE;SCORE_MAX;XP;BADGES
# =========================

ARC_ID="ARC1"
MISSION_ID="ARC1-M1"
SCORE_MAX=20

STUDENT_ID="${1:-}"
if [[ -z "$STUDENT_ID" ]]; then
  echo "Erreur: STUDENT_ID manquant."
  echo "Usage: $0 MON_ID_ETUDIANT"
  exit 2
fi

BASE_DIR="$HOME/linux101/ARC1/M1"
RESULTS_DIR="$HOME/linux101/results"
mkdir -p "$RESULTS_DIR"

# --- scoring
score=0
badges=()

# Poids : Q1=2, Q2=2, Q3=3, Q4=3, Q5=5, Q6=5
w_q1=2; w_q2=2; w_q3=3; w_q4=3; w_q5=5; w_q6=5

ok_q1=0; ok_q2=0; ok_q3=0; ok_q4=0; ok_q5=0; ok_q6=0

print_check() {
  local q="$1" status="$2" pts="$3" maxpts="$4"
  printf "%-10s : %-10s (%s/%s)\n" "$q" "$status" "$pts" "$maxpts"
}

require_file() {
  local f="$1"
  [[ -f "$f" ]]
}

contains_prefix_line() {
  local f="$1" prefix="$2"
  grep -qE "^${prefix}=" "$f"
}

check_q1() {
  local f="$BASE_DIR/identity.txt"
  require_file "$f" || return 1
  contains_prefix_line "$f" "USER" || return 1
  grep -qE "^UID_LINE=.*uid=" "$f" || return 1
  contains_prefix_line "$f" "HOST" || return 1
  contains_prefix_line "$f" "PWD" || return 1
  return 0
}

check_q2() {
  local f="$BASE_DIR/command_log.txt"
  require_file "$f" || return 1
  grep -qE "^HISTORY_COUNT=[0-9]+$" "$f" || return 1
  # au moins 6 lignes (1 + 5)
  local lc
  lc=$(wc -l < "$f" | tr -d ' ')
  [[ "$lc" -ge 6 ]] || return 1
  return 0
}

check_q3() {
  local f="$BASE_DIR/system_snapshot.txt"
  require_file "$f" || return 1
  contains_prefix_line "$f" "DATE" || return 1
  contains_prefix_line "$f" "KERNEL" || return 1
  contains_prefix_line "$f" "OS" || return 1
  contains_prefix_line "$f" "SHELL" || return 1
  return 0
}

check_q4() {
  local f="$BASE_DIR/env_report.txt"
  require_file "$f" || return 1
  contains_prefix_line "$f" "HOME" || return 1
  contains_prefix_line "$f" "PATH" || return 1
  contains_prefix_line "$f" "PWD" || return 1
  contains_prefix_line "$f" "NECRO_ID" || return 1
  return 0
}

expected_flag() {
  echo -n "${STUDENT_ID}-ARC1-M1" | sha256sum | awk '{print substr($1,1,12)}'
}

check_q5() {
  local f="$BASE_DIR/flag_ARC1_M1_${STUDENT_ID}.txt"
  local explain="$BASE_DIR/seal_explain.txt"
  require_file "$f" || return 1
  require_file "$explain" || return 1

  local exp
  exp="$(expected_flag)"
  local got
  got="$(tr -d '\r\n ' < "$f" 2>/dev/null || true)"

  [[ "$got" == "$exp" ]] || return 1
  # explication non vide
  [[ -s "$explain" ]] || return 1
  return 0
}

check_q6() {
  local script="$BASE_DIR/rituel_entree.sh"
  local out="$BASE_DIR/ritual_output.txt"
  require_file "$script" || return 1
  require_file "$out" || return 1

  head -n 1 "$script" | grep -qE "^#!/.*bash" || return 1
  [[ -x "$script" ]] || return 1

  grep -qE "^USER=" "$out" || return 1
  grep -qE "^HOST=" "$out" || return 1
  grep -qE "^DATE=" "$out" || return 1
  grep -qE "^PWD=" "$out" || return 1

  return 0
}

echo "== Auto-correction $MISSION_ID — Sentinelle: $STUDENT_ID =="
echo "Dossier vérifié: $BASE_DIR"
echo

# Q1
if check_q1; then ok_q1=1; score=$((score+w_q1)); print_check "Q1" "OK" "$w_q1" "$w_q1"
else print_check "Q1" "A corriger" 0 "$w_q1"; fi

# Q2
if check_q2; then ok_q2=1; score=$((score+w_q2)); print_check "Q2" "OK" "$w_q2" "$w_q2"
else print_check "Q2" "A corriger" 0 "$w_q2"; fi

# Q3
if check_q3; then ok_q3=1; score=$((score+w_q3)); print_check "Q3" "OK" "$w_q3" "$w_q3"
else print_check "Q3" "A corriger" 0 "$w_q3"; fi

# Q4
if check_q4; then ok_q4=1; score=$((score+w_q4)); print_check "Q4" "OK" "$w_q4" "$w_q4"
else print_check "Q4" "A corriger" 0 "$w_q4"; fi

# Q5
if check_q5; then ok_q5=1; score=$((score+w_q5)); print_check "Q5" "OK" "$w_q5" "$w_q5"
else print_check "Q5" "A corriger" 0 "$w_q5"; fi

# Q6
if check_q6; then ok_q6=1; score=$((score+w_q6)); print_check "Q6" "OK" "$w_q6" "$w_q6"
else print_check "Q6" "A corriger" 0 "$w_q6"; fi

echo
echo "== Résultat =="
xp=$((score*10))

# Badges
if [[ "$score" -ge 10 ]]; then badges+=("Néophyte_du_Terminal"); fi
if [[ "$score" -ge 16 ]]; then badges+=("Initié_du_Shell"); fi
if [[ "$ok_q5" -eq 1 ]]; then badges+=("Porteur_du_Sceau"); fi
if [[ "$score" -eq "$SCORE_MAX" ]]; then badges+=("Sentinelle_de_la_Porte_Noire"); fi

badges_str="Aucun"
if [[ "${#badges[@]}" -gt 0 ]]; then
  badges_str="$(IFS=,; echo "${badges[*]}")"
fi

printf "Score: %d/%d | XP: %d | Badges: %s\n" "$score" "$SCORE_MAX" "$xp" "$badges_str"

# Ligne structurée pour appli web
echo "RESULT;${STUDENT_ID};${ARC_ID};${MISSION_ID};${score};${SCORE_MAX};${xp};${badges_str}"

# Log local (traçabilité)
echo "$(date -Is);RESULT;${STUDENT_ID};${ARC_ID};${MISSION_ID};${score};${SCORE_MAX};${xp};${badges_str}" \
  >> "${RESULTS_DIR}/arc1_m1_results.log"

# Code retour
if [[ "$score" -eq "$SCORE_MAX" ]]; then
  exit 0
else
  exit 1
fi

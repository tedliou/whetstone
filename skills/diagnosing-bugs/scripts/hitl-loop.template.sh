#!/usr/bin/env bash
# Human-in-the-loop reproduction script.
# Copy this file outside the repo, edit the steps between the markers,
# and ask the user to run it in their own terminal:
#   bash hitl-loop.template.sh
#
# Helpers:
#   step "<instruction>"        show the instruction, wait for Enter
#   capture VAR "<question>"    show the question, store the answer in VAR
#
# The script ends by printing every captured value as KEY=VALUE.
# Captured values are shown on screen, so never capture a credential;
# put sign-in in a step instead.

set -euo pipefail

CAPTURED=()

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
  CAPTURED+=("$var")
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the Export button. Did it show an error? (y/n)"

capture ERROR_MSG "Paste the error message, or type none:"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
for var in "${CAPTURED[@]}"; do
  printf '%s=%s\n' "$var" "${!var}"
done

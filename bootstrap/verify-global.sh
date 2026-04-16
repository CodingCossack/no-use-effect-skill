#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

FAILURES=0

pass() {
  printf 'OK   %s\n' "$1"
}

fail() {
  printf 'FAIL %s\n' "$1"
  FAILURES=$((FAILURES + 1))
}

required_paths=(
  "$CANONICAL_DIR/SKILL.md"
  "$CANONICAL_DIR/PACKAGING.md"
  "$CANONICAL_DIR/agents/openai.yaml"
  "$CANONICAL_DIR/bootstrap/install-global.sh"
  "$CANONICAL_DIR/bootstrap/uninstall-global.sh"
  "$CANONICAL_DIR/bootstrap/verify-global.sh"
  "$CANONICAL_DIR/scripts/build-zip.sh"
  "$CANONICAL_DIR/rules/01-triage.md"
  "$CANONICAL_DIR/rules/02-replacements.md"
  "$CANONICAL_DIR/rules/03-allowed-effects.md"
  "$CANONICAL_DIR/rules/04-enforcement.md"
  "$CANONICAL_DIR/examples/before-after.md"
  "$CANONICAL_DIR/reference/react-rationale.md"
)

if [[ -d "$CANONICAL_DIR" ]]; then
  pass "Canonical source directory exists at ${CANONICAL_DIR}"
else
  fail "Canonical source directory missing at ${CANONICAL_DIR}"
fi

for path in "${required_paths[@]}"; do
  if [[ -e "$path" ]]; then
    pass "Required path exists: ${path}"
  else
    fail "Required path missing: ${path}"
  fi
done

verify_install "$CODEX_DEST" "$CODEX_STATE" "$CANONICAL_DIR" "Codex skill" || FAILURES=$((FAILURES + 1))
verify_install "$CLAUDE_DEST" "$CLAUDE_STATE" "$CANONICAL_DIR" "Claude skill" || FAILURES=$((FAILURES + 1))

echo "Summary: ${FAILURES} failure(s)"
if [[ "$FAILURES" -gt 0 ]]; then
  exit 1
fi

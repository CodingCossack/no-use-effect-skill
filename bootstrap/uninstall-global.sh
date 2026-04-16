#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

REMOVE_CODEX=true
REMOVE_CLAUDE=true

for arg in "$@"; do
  case "$arg" in
    --codex-only)
      REMOVE_CODEX=true
      REMOVE_CLAUDE=false
      ;;
    --claude-only)
      REMOVE_CODEX=false
      REMOVE_CLAUDE=true
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ "$REMOVE_CODEX" == true ]]; then
  remove_owned_install "$CODEX_DEST" "$CODEX_STATE" "$CANONICAL_DIR" "Codex skill"
fi

if [[ "$REMOVE_CLAUDE" == true ]]; then
  remove_owned_install "$CLAUDE_DEST" "$CLAUDE_STATE" "$CANONICAL_DIR" "Claude skill"
fi

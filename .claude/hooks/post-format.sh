#!/usr/bin/env bash
# Post-edit auto-format hook for Claude Code.
#
# Runs the right formatter for the file Claude just touched.
# Silent if no formatter is configured for that extension.
# Never fails the hook — a missing formatter shouldn't break the workflow.

set -euo pipefail

PAYLOAD="$(cat)"
FILE="$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; t=json.load(sys.stdin).get("tool_input",{}); print(t.get("file_path") or t.get("filePath") or "")' 2>/dev/null || true)"

if [[ -z "${FILE:-}" || ! -f "$FILE" ]]; then
  exit 0
fi

ext="${FILE##*.}"
case "$ext" in
  py)
    command -v ruff >/dev/null && ruff format "$FILE" >/dev/null 2>&1 || true
    ;;
  js|jsx|ts|tsx|json|css|html|md)
    if command -v biome >/dev/null; then
      biome format --write "$FILE" >/dev/null 2>&1 || true
    elif command -v prettier >/dev/null; then
      prettier --write "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  go)
    command -v gofmt >/dev/null && gofmt -w "$FILE" >/dev/null 2>&1 || true
    ;;
  rs)
    command -v rustfmt >/dev/null && rustfmt "$FILE" >/dev/null 2>&1 || true
    ;;
  sh|bash)
    command -v shfmt >/dev/null && shfmt -w "$FILE" >/dev/null 2>&1 || true
    ;;
esac

exit 0

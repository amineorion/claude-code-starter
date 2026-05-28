#!/usr/bin/env bash
# Pre-bash safety hook for Claude Code.
#
# Reads the proposed bash command from stdin (JSON payload from Claude Code),
# blocks if it matches any rule in the blocklist, exits 0 otherwise.
#
# Exit 0  → allow
# Exit 1  → deny (Claude sees the stderr message and asks you before retrying)
# Exit 2+ → error (treated like deny but logged)
#
# Tune the blocklist for your project. Over-blocking is worse than under-blocking
# — Claude will learn to route around you.

set -euo pipefail

# Read JSON payload, extract the bash command.
PAYLOAD="$(cat)"
CMD="$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

if [[ -z "${CMD:-}" ]]; then
  exit 0
fi

deny() {
  echo "🛑 bash-guard blocked: $1" >&2
  echo "    command: $CMD" >&2
  exit 1
}

# ── Blocklist ─────────────────────────────────────────────────────────────

# Recursive deletes outside ./
if [[ "$CMD" =~ rm[[:space:]]+(-[rRf]+[[:space:]]+)+/ ]]; then
  deny "rm -rf with absolute path"
fi
if [[ "$CMD" =~ rm[[:space:]]+(-[rRf]+[[:space:]]+)+~ ]]; then
  deny "rm -rf in home directory"
fi

# Force pushes to main/master
if [[ "$CMD" =~ git[[:space:]]+push.*--force ]] && [[ "$CMD" =~ (main|master) ]]; then
  deny "force-push to main/master"
fi

# Hard resets that nuke history
if [[ "$CMD" =~ git[[:space:]]+reset[[:space:]]+--hard ]] && [[ "$CMD" =~ origin/(main|master) ]]; then
  deny "git reset --hard to remote main/master"
fi

# DROP TABLE / DROP DATABASE
if [[ "$CMD" =~ DROP[[:space:]]+(TABLE|DATABASE|SCHEMA) ]]; then
  deny "DROP statement"
fi

# Mass file removal
if [[ "$CMD" =~ find[[:space:]].+-delete ]]; then
  deny "find ... -delete"
fi

# Sudo (you should be deliberate, not casual)
if [[ "$CMD" =~ ^sudo[[:space:]] ]]; then
  deny "sudo (be explicit — run it yourself if you mean it)"
fi

# Skip git hooks
if [[ "$CMD" =~ --no-verify ]]; then
  deny "skipping git hooks (--no-verify)"
fi

# curl | sh — never
if [[ "$CMD" =~ curl[[:space:]].+\|[[:space:]]*(sh|bash|zsh) ]]; then
  deny "curl piped to shell"
fi

# Production env files
if [[ "$CMD" =~ \.env\.(prod|production) ]] && [[ "$CMD" =~ (rm|cat|cp|mv) ]]; then
  deny "touching .env.production"
fi

exit 0

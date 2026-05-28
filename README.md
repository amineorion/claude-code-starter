# claude-code-starter

The minimum production setup for Claude Code on a real codebase. Drop it into your repo, edit a few lines, and you've got:

- A `CLAUDE.md` that acts as a router, not an encyclopedia (no context bloat)
- A pre-bash safety hook that blocks `rm -rf /`, `git push --force` to main, `DROP TABLE`, and a few other foot-guns
- A post-edit auto-format hook that runs your formatter every time Claude touches a file
- Zero magic. No new dependencies. ~100 lines of bash you can read and tune in 10 minutes.

## Install

```bash
# from your project root
curl -L https://github.com/amineorion/claude-code-starter/archive/refs/heads/main.tar.gz | tar -xz --strip-components=2 claude-code-starter-main/CLAUDE.md claude-code-starter-main/.claude
chmod +x .claude/hooks/*.sh
```

Or clone and copy what you want:

```bash
git clone https://github.com/amineorion/claude-code-starter.git /tmp/cck
cp /tmp/cck/CLAUDE.md ./
cp -r /tmp/cck/.claude ./
chmod +x .claude/hooks/*.sh
```

## What's in here

```
.
├── CLAUDE.md                       3-section router template (Map / Conventions / Don't)
└── .claude/
    ├── settings.json               Wires the two hooks below
    └── hooks/
        ├── bash-guard.sh           Pre-bash safety blocklist
        └── post-format.sh          Post-edit auto-formatter
```

## Edit these before you commit

1. **`CLAUDE.md`** — every bracketed `[YOUR_…]` placeholder. The whole file should fit on one screen.
2. **`.claude/hooks/bash-guard.sh`** — read the blocklist, add your project's foot-guns (e.g. "don't touch `migrations/applied/`").
3. **`.claude/hooks/post-format.sh`** — comment out the languages you don't use.

## Why each piece exists

### `CLAUDE.md` — the router

Every `CLAUDE.md` ships in every Claude Code conversation. Burning 1,500 words of "philosophy" on every turn is how you get a bloated context window and an agent that misses things.

The pattern: tell Claude **where to look** (Map), **what's the house style** (Conventions), and **what's a landmine** (Don't). That's it.

If you find yourself wanting to add more, push it into a sub-folder `CLAUDE.md` that only loads when Claude is in that area. Or write a `skills/` file that loads on demand.

### `bash-guard.sh` — the brake pedal

Claude is a fast intern. You wouldn't give an intern unrestricted shell access. The blocklist here covers the high-leverage foot-guns:

- `rm -rf` with absolute or home paths
- `git push --force` to main/master
- `git reset --hard origin/main`
- `DROP TABLE` / `DROP DATABASE`
- `sudo` (forces you to be deliberate)
- `--no-verify` (no skipping hooks)
- `curl | sh` (no piping the internet to shell)

Tune it. Over-blocking is worse than under-blocking — if you block too much, Claude learns to route around you, which is the worst possible outcome.

### `post-format.sh` — the broom

After every `Edit`/`Write`/`MultiEdit`, runs the right formatter for the file. Stop reviewing whitespace diffs. Auto-detects Python (ruff), JS/TS (biome → prettier), Go (gofmt), Rust (rustfmt), shell (shfmt), markdown. Silent if a formatter isn't installed.

## What's NOT in here (yet)

This is the minimum production setup. Patterns that need more setup (sub-agents, memory architecture, MCP servers, CI integration) live in the full course at <https://ship-up.com>.

The two next things you might want to add:

- **Post-edit typecheck hook.** `tsc --noEmit` / `mypy` / `cargo check` after a batch of edits. Add it once your typechecker is fast enough not to bottleneck.
- **`scripts/dev.sh`** — one command to start your whole stack. Critical for the "verify in the running app" pattern.

## Read the source

The full reasoning behind every piece of this kit is in [The 6 Claude Code patterns that actually matter when you ship to production](https://ship-up.com/pillar-1.html).

If you want the next post + first access when the founder cohort opens, drop your email at <https://ship-up.com>.

## License

MIT. Fork it, ship it, modify it. If you build on top, a link back to <https://ship-up.com> is appreciated but not required.

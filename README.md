# No useEffect Skill

Portable skill for reviewing, refactoring, and writing React code without defaulting to raw `useEffect` or `useLayoutEffect`.

Tags: React, useEffect, useLayoutEffect, hooks, architecture, codex, claude-code, skills

This repository is the skill folder itself. That is intentional. It means people can use it however they already work:

- install it with `npx skills`
- symlink or copy it into local Codex or Claude Code skill directories
- build a clean ZIP for Claude upload or agent handoff
- point another agent at the repo and tell it to install the skill directly

The skill is built for real React work, not generic hook advice:

- classify whether an effect is derivation, event logic, data loading, parent-child sync, external store subscription, reset-by-identity, or real external synchronization
- replace common effect anti-patterns with render-time derivation, event handlers, query APIs, `useSyncExternalStore`, or `key`
- keep surviving effects behind named hooks instead of raw component call sites
- review `useLayoutEffect`, Strict Mode, cleanup symmetry, and SSR behavior explicitly
- enforce the policy with grep, lint rules, and review gates

---

## The fast answer

### Do I need to connect this repo to `skills.sh`?

No.

If this repo is on GitHub, people can install it directly with `npx skills add <owner>/<repo>`. `skills.sh` is useful for discovery, but it is not required for installation.

### Does this repo already work with `npx skills`?

Yes.

The Skills CLI accepts GitHub shorthand, full GitHub URLs, and local paths. This repo keeps a valid `SKILL.md` at the root, so it is installable as a single-skill bundle.

---

## Pick the install path that matches how you work

### 1. I want the easiest install and easiest updates

Use the Skills CLI.

From GitHub:

```bash
npx skills add CodingCossack/no-use-effect-skill --global --yes
```

Useful variants:

```bash
# Let the CLI walk you through placement interactively
npx skills add CodingCossack/no-use-effect-skill

# Install from a full GitHub URL instead of owner/repo shorthand
npx skills add https://github.com/CodingCossack/no-use-effect-skill

# Install from a local folder instead of GitHub
npx skills add /absolute/path/to/no-use-effect-skill
```

Why use this path:

- single command
- guided placement
- easy updates later
- works cleanly for Codex and Claude Code

### 2. I want to install it manually into a local project or global skills folder

Use the raw repo folder directly.

#### Codex - global

```bash
mkdir -p "$HOME/.codex/skills"
ln -s "$(pwd)" "$HOME/.codex/skills/no-use-effect"
```

#### Codex - project-scoped

```bash
mkdir -p /path/to/project/.agents/skills
ln -s "$(pwd)" /path/to/project/.agents/skills/no-use-effect
```

#### Claude Code - global

```bash
mkdir -p "$HOME/.claude/skills"
ln -s "$(pwd)" "$HOME/.claude/skills/no-use-effect"
```

#### Claude Code - project-scoped

```bash
mkdir -p /path/to/project/.claude/skills
ln -s "$(pwd)" /path/to/project/.claude/skills/no-use-effect
```

If you prefer copies instead of symlinks:

```bash
mkdir -p "$HOME/.codex/skills/no-use-effect"
rsync -a --delete --exclude '.git' --exclude '.github' --exclude 'dist' ./ "$HOME/.codex/skills/no-use-effect/"
```

```bash
mkdir -p "$HOME/.claude/skills/no-use-effect"
rsync -a --delete --exclude '.git' --exclude '.github' --exclude 'dist' ./ "$HOME/.claude/skills/no-use-effect/"
```

### 3. I want built-in bootstrap scripts

The repo includes simple install, verify, and uninstall helpers:

```bash
./bootstrap/install-global.sh
./bootstrap/verify-global.sh
./bootstrap/uninstall-global.sh
```

Useful variants:

```bash
./bootstrap/install-global.sh --copy
./bootstrap/install-global.sh --codex-only
./bootstrap/install-global.sh --claude-only
```

### 4. I want a ZIP I can upload or hand around

Build a clean ZIP from the repo root:

```bash
./scripts/build-zip.sh
```

Output:

```text
dist/no-use-effect-skill.zip
```

The ZIP contains the `no-use-effect/` folder as its root and excludes repo-only files.

#### Claude upload

Claude custom skill upload expects the skill folder inside the ZIP, not loose files at the ZIP root.

#### Manual unzip install

```bash
unzip dist/no-use-effect-skill.zip -d "$HOME/.claude/skills"
# or
unzip dist/no-use-effect-skill.zip -d "$HOME/.codex/skills"
```

The final path should end in:

```text
$HOME/.claude/skills/no-use-effect/SKILL.md
# or
$HOME/.codex/skills/no-use-effect/SKILL.md
```

### 5. I want Codex or Claude to install it for me

That is valid too.

Minimal prompt:

```text
Install this No useEffect skill. Keep the folder name no-use-effect and make sure the final path ends in SKILL.md. For Codex use $HOME/.codex/skills/no-use-effect. For Claude Code use $HOME/.claude/skills/no-use-effect.
```

---

## Verify it loaded

### Claude Code

Direct invocation:

```text
/no-use-effect
```

Claude can also auto-load the skill when the task matches the description.

### Codex

Codex can load the skill explicitly or implicitly depending on the client. A good direct prompt is:

```text
Use the no-use-effect skill. First classify each effect by cause, then replace it with the smallest correct primitive, and only keep surviving effects behind named hooks.
```

---

## What this skill actually helps with

Use it when you are working on:

- diffs that add `useEffect` or `useLayoutEffect`
- refactors of existing effect-heavy components
- stale state, dependency churn, render loops, remount bugs, or parent-child sync problems
- fetch-in-effect code that should move to query APIs or framework data loaders
- external store subscriptions that should use `useSyncExternalStore`
- code review or lint policy around raw effects

This repo keeps exactly one public `SKILL.md`. Everything else is supporting material:

- `rules/` for classification, replacements, allowed effects, and enforcement
- `examples/` for compact before/after examples
- `reference/` for the React mental model behind the skill
- `agents/openai.yaml` for UI-facing metadata
- `bootstrap/` and `scripts/` for distribution and installation helpers

---

## Repository layout

```text
.
├── README.md
├── PACKAGING.md
├── SKILL.md
├── agents/
│   └── openai.yaml
├── bootstrap/
│   ├── common.sh
│   ├── install-global.sh
│   ├── uninstall-global.sh
│   └── verify-global.sh
├── examples/
│   └── before-after.md
├── reference/
│   └── react-rationale.md
├── rules/
│   ├── 01-triage.md
│   ├── 02-replacements.md
│   ├── 03-allowed-effects.md
│   └── 04-enforcement.md
└── scripts/
    └── build-zip.sh
```

# React No useEffect Skill

React `useEffect` and `useLayoutEffect` refactoring skill for React hooks
architecture, derived state, event handlers, query APIs,
`useSyncExternalStore`, key-based resets, Strict Mode, and SSR-safe component
logic.

This skill classifies effects, removes effect-driven state, fixes dependency
churn, render loops, parent-child sync, and fetch-in-effect anti-patterns, and
keeps legitimate external synchronization behind named hooks.

## What this React skill actually does

- classifies each raw effect as derivation, event logic, data loading,
  parent-child sync, external store subscription, reset-by-identity, or real
  external synchronization
- replaces common React effect anti-patterns with render-time derivation, event
  handlers, query APIs, `useSyncExternalStore`, or `key`
- rewrites fetch-in-effect patterns toward framework loaders, query libraries,
  or user-triggered actions
- reviews `useLayoutEffect`, Strict Mode behavior, cleanup symmetry, and SSR
  behavior explicitly
- moves any necessary surviving effects behind descriptive named hooks instead
  of leaving raw effects in application components
- supports code review, lint rules, grep-based enforcement, and policy gates for
  teams trying to reduce raw effect usage

## Best use cases

- replacing `useEffect` in React apps
- refactoring `useLayoutEffect` usage
- fixing stale state, dependency churn, render loops, and parent-child sync
- removing fetch-in-effect and set-state-in-effect anti-patterns
- reviewing React hooks architecture in diffs and pull requests
- enforcing a no-raw-`useEffect` policy in frontend codebases

## Outputs

- effect classification by root cause
- recommended replacement primitive
- allowed-effect review for the cases that truly need one
- cleaner React component architecture
- concrete rewrite guidance instead of generic hook advice

## Core capability areas

The core value is in the classification rules and replacement model behind the
skill:

- `rules/01-triage.md` for first-match effect classification
- `rules/02-replacements.md` for effect replacement patterns
- `rules/03-allowed-effects.md` for the narrow surviving effect cases
- `rules/04-enforcement.md` for review and lint enforcement
- `examples/before-after.md` for compact before/after rewrites
- `reference/react-rationale.md` for the React model behind the skill

## Fast install

The install folder name stays `no-use-effect`.

```bash
npx skills add CodingCossack/no-use-effect-skill --global --yes
```

Useful variants:

```bash
# Let the CLI walk you through placement interactively
npx skills add CodingCossack/no-use-effect-skill

# Install from a full GitHub URL
npx skills add https://github.com/CodingCossack/no-use-effect-skill

# Install from a local folder
npx skills add /absolute/path/to/no-use-effect-skill
```

## Manual install

### Codex global

```bash
mkdir -p "$HOME/.codex/skills"
ln -s "$(pwd)" "$HOME/.codex/skills/no-use-effect"
```

### Codex project-scoped

```bash
mkdir -p /path/to/project/.agents/skills
ln -s "$(pwd)" /path/to/project/.agents/skills/no-use-effect
```

### Claude Code global

```bash
mkdir -p "$HOME/.claude/skills"
ln -s "$(pwd)" "$HOME/.claude/skills/no-use-effect"
```

### Claude Code project-scoped

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

## Bootstrap scripts

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

## Zip packaging

Build a clean ZIP from the repo root:

```bash
./scripts/build-zip.sh
```

Output:

```text
dist/no-use-effect-skill.zip
```

Claude custom skill upload expects the skill folder inside the ZIP, not loose
files at the ZIP root.

Manual unzip install:

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

## Verify it loaded

### Claude Code

Direct invocation:

```text
/no-use-effect
```

### Codex

Good direct prompt:

```text
Use the no-use-effect skill. First classify each effect by cause, then replace it with the smallest correct primitive, and only keep surviving effects behind named hooks.
```

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

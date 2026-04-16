# Packaging notes

This repo is both:

- the canonical working repository
- the skill folder that agents install

That is why `SKILL.md` lives at the repo root.

## Public install contract

- The install name is derived from `SKILL.md` frontmatter: `name: no-use-effect`
- Manual installs should end at `.../no-use-effect/SKILL.md`
- `agents/openai.yaml` is UI metadata and should ship with the skill when possible
- ZIP distributions should contain the `no-use-effect/` folder as the archive root

## ZIP build behavior

`./scripts/build-zip.sh` stages a clean folder named from `SKILL.md`, then zips that folder.

The ZIP intentionally excludes repo-only files such as:

- `.git/`
- `.github/`
- `README.md`
- `PACKAGING.md`
- `bootstrap/`
- `scripts/`
- `dist/`
- local OS noise such as `.DS_Store`

The ZIP intentionally includes:

- `SKILL.md`
- `agents/openai.yaml`
- `rules/`
- `examples/`
- `reference/`

## Why the repo name can differ from the skill name

The GitHub repo is named `no-use-effect-skill`, but the installed skill name is `no-use-effect`.

That split is intentional:

- the repo name is clearer for public discovery
- the installed skill name stays short and ergonomic for direct invocation

## Validation checklist

Before publishing:

1. `SKILL.md` frontmatter still has the intended `name` and `description`
2. `agents/openai.yaml` still matches the skill's public purpose
3. `./scripts/build-zip.sh` succeeds
4. the ZIP unpacks to `no-use-effect/SKILL.md`
5. README install commands still point to the correct repo and target paths

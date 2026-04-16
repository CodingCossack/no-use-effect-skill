---
name: no-use-effect
description: Reviews React code with useEffect or useLayoutEffect. Replaces effects with derived state, event handlers, query APIs, key resets, useSyncExternalStore, or named hooks. Use when writing components, refactoring effects, or reviewing diffs.
---

# No useEffect

Default stance: do not add raw `useEffect` or `useLayoutEffect` in application components until the cause is classified.

Use this skill when:
- a diff adds `useEffect` or `useLayoutEffect`
- refactoring existing effects
- debugging stale state, extra renders, render loops, dependency churn, remount issues, or parent/child sync bugs
- deciding between render-time derivation, event handlers, data APIs, `useSyncExternalStore`, `key`, `useMountEffect`, or a named hook

## Fast triage

1. **Pure derivation from props/state?** Compute during render. Use `useMemo` only for measured expensive work.
2. **Specific user interaction?** Put it in the event handler or action. Do not relay through state + effect.
3. **Screen-driven data loading?** Use framework loaders, server components, or a query library. If the request is user-triggered, do it in the handler.
4. **Child effect pushing state or fetched data to a parent?** Lift state or fetch in the parent instead.
5. **External store with subscribe + current snapshot semantics?** Use `useSyncExternalStore` or the library’s hook.
6. **Whole subtree should reset when identity changes?** Remount with `key`.
7. **Only part of state adjusts on prop change?** Derive it during render or redesign the state shape. Do not effect-reset it.
8. **Real external synchronization still remains because the component is on screen?** Hide it in a descriptive custom hook. Use `useLayoutEffect` only for pre-paint layout/scroll work.

## Red flags

- `useEffect(() => setX(f(y)), [y])`
- state flag -> effect -> reset flag
- child effect calling a parent setter
- fetch in effect followed by local `setState`
- chains of effects whose only job is to trigger more state
- empty `[]` effect used as “runs once”
- replacing `useEffect` with `useLayoutEffect` to dodge the rule

## Working mode

1. Search for `useEffect` and `useLayoutEffect`.
2. Classify each with [rules/01-triage.md](rules/01-triage.md).
3. Rewrite with the smallest matching replacement from [rules/02-replacements.md](rules/02-replacements.md).
4. If an effect survives, move it into a named hook and validate it with [rules/03-allowed-effects.md](rules/03-allowed-effects.md).
5. Run the checks in [rules/04-enforcement.md](rules/04-enforcement.md).

## Non-negotiables

- If the external system cannot be named explicitly, the effect is probably wrong.
- `useMountEffect` is only a thin wrapper around `useEffect([])`. It does **not** mean “exactly once” in dev Strict Mode.
- Raw effects in components are exceptional; surviving ones should usually live behind descriptive hooks.
- `useLayoutEffect` is not a loophole. Keep it for pre-paint layout measurement and scroll correction only.

## Additional resources

- [rules/01-triage.md](rules/01-triage.md): first-match classification tree
- [rules/02-replacements.md](rules/02-replacements.md): concrete rewrites for the common anti-patterns
- [rules/03-allowed-effects.md](rules/03-allowed-effects.md): the narrow set of surviving effects, `useMountEffect`, `useLayoutEffect`, cleanup, Strict Mode, and SSR
- [rules/04-enforcement.md](rules/04-enforcement.md): lint and review enforcement
- [examples/before-after.md](examples/before-after.md): compact bad/good examples
- [reference/react-rationale.md](reference/react-rationale.md): the React model this skill is built on

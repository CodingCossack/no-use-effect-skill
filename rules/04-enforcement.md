# Enforcement

Skills steer behavior. Linters and review gates enforce it.

## 1. Search for effects in diffs

```bash
rg -n '\buse(Layout)?Effect\b' --glob '*.{js,jsx,ts,tsx}'
```

During review, classify each match before touching dependencies.

## 2. Baseline lint: ban raw `useEffect`

This is the blunt instrument. It stops the default “just add an effect” failure mode.

```json
{
  "rules": {
    "no-restricted-syntax": [
      "error",
      {
        "selector": "CallExpression[callee.name='useEffect']",
        "message": "Raw useEffect is banned by policy. Use render-time derivation, event handlers, data APIs, key resets, useSyncExternalStore, or a named custom hook."
      }
    ]
  }
}
```

If your codebase also wants to ban direct `useLayoutEffect`, add a second selector. Keep legitimate layout work in centralized wrapper hooks.

## 3. Official React lint: `set-state-in-effect`

If your React hooks lint stack exposes it, enable the official rule that flags synchronous `setState` in effects. It catches a large share of redundant-effect mistakes early.

Example intent:
- deriving state from props in an effect
- transforming data in an effect instead of render
- synchronously initializing state in an effect

## 4. Stronger heuristics: `eslint-plugin-react-you-might-not-need-an-effect`

Optional but useful when you want precise detection beyond a blanket ban.

Recommended config:

```js
import reactYouMightNotNeedAnEffect from "eslint-plugin-react-you-might-not-need-an-effect";

export default [
  reactYouMightNotNeedAnEffect.configs.recommended,
];
```

The plugin ships rules for patterns this skill explicitly cares about, including:
- `no-derived-state`
- `no-chain-state-updates`
- `no-event-handler`
- `no-adjust-state-on-prop-change`
- `no-reset-all-state-on-prop-change`
- `no-pass-live-state-to-parent`
- `no-pass-data-to-parent`
- `no-initialize-state`
- `no-empty-effect`

Use the plugin’s `strict` config if you want them as errors.

## 5. Review rule

For any surviving raw effect:
1. it must live in a named custom hook or a small integration module
2. the external system must be named in the hook name or surrounding comment
3. cleanup must be obvious
4. dev remount must be safe
5. SSR/client behavior must be intentional

If a reviewer cannot answer “what external system is this synchronizing with?” immediately, send it back.

## 6. Verification after refactor

Run the normal project checks after replacing effects:

```bash
npm run lint
npm run typecheck
npm run test
```

Add project-specific filters if your repo uses them.

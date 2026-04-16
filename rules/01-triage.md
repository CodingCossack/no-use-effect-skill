# Effect triage

Use first-match-wins classification. The mistake most agents make is treating `useEffect` as default control flow and only later trying to fix dependencies. Reverse that: classify the cause first, then choose the primitive.

## Classification order

1. **Render-time derivation**
   - The effect reads props/state and writes derived state.
   - Typical smell: `useEffect(() => setX(f(y)), [y])`.
   - Fix: compute `f(y)` during render. Add `useMemo` only if the work is measured and expensive.

2. **Event-specific logic**
   - The effect exists only because a user clicked, submitted, typed, dragged, or confirmed something.
   - Typical smell: state flag -> effect -> reset flag.
   - Fix: do the work in the event handler or action.

3. **Screen-driven data loading**
   - The data is needed because the component is visible.
   - Fix: prefer framework loaders, server components, or query libraries.
   - If the request is caused by a click, do it in the handler instead.

4. **Parent/child synchronization**
   - A child effect calls a parent setter or pushes fetched/live state upward.
   - Fix: lift state up, fetch in the parent, or call the callback in the same event handler that caused the change.

5. **External store subscription**
   - The source has **subscribe + read current snapshot** semantics.
   - Good fits: browser online status, media queries, Redux-like stores, state libraries that live outside React.
   - Fix: `useSyncExternalStore` or the library’s dedicated hook.

6. **Whole-tree reset on identity change**
   - Switching `userId`, `videoId`, `chatId`, or similar should create a fresh instance.
   - Fix: wrap the inner component and pass `key={identity}`.

7. **Partial state adjustment on prop change**
   - Only one field must change when props change, but the whole subtree should not remount.
   - Fix: derive during render, store an ID instead of a full object, or redesign the state shape.
   - This is still not an effect problem.

8. **Application initialization**
   - The logic should happen once per app load, not once per component mount.
   - Fix: entrypoint/module initialization or a guarded root-level pattern.
   - Do not use a component effect as “exactly once” control flow.

9. **Imperative external synchronization**
   - A real external system must be synchronized because the component is on screen.
   - Good fits: page-view analytics, DOM focus/scroll integration, third-party widget lifecycle, imperative subscriptions without a stable snapshot.
   - Fix: keep the effect, but move it into a narrow custom hook with an explicit name.

10. **Pre-paint layout or scroll work**
   - The code must measure layout or correct scroll position before the browser paints.
   - Fix: use `useLayoutEffect` inside a named custom hook.
   - Reject any other reason for `useLayoutEffect`.

## Review questions for surviving effects

A surviving effect should answer **yes** to all of these:
- Is the external system named explicitly?
- Does re-running mean “re-synchronize with that external system” rather than “re-run business logic”?
- Does cleanup mirror setup?
- Is dev Strict Mode remount safe?
- Is SSR/hydration behavior acceptable?

If any answer is “no”, the effect almost certainly wants a different primitive.

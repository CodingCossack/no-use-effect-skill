# Allowed effects

This skill is not built on the false claim that effects are always wrong. React’s own model is that effects synchronize with external systems. The rule here is narrower: **raw effects are not the default tool for application logic**.

## Surviving effects belong in named hooks

Prefer this:

```tsx
function usePageView(route: string) {
  useEffect(() => {
    analytics.page(route);
  }, [route]);
}
```

Over this:

```tsx
function Page({ route }: { route: string }) {
  useEffect(() => {
    analytics.page(route);
  }, [route]);
}
```

The hook name must tell the reviewer what external system is being synchronized:
- `usePageView`
- `useChatConnection`
- `useAutoFocus`
- `useRestoreScroll`
- `useIntersectionObserver`
- `useMapWidget`

“Why does this effect exist?” should be answerable from the hook name alone.

## Legitimate categories

### 1. Analytics and telemetry

Good fit when the reason is “this UI became visible” or “this route changed”.

```tsx
function usePageView(route: string) {
  useEffect(() => {
    analytics.page(route);
  }, [route]);
}
```

Guard for dev duplication if your telemetry stack cannot dedupe.

### 2. Imperative DOM integration

Focus, scroll correction, text selection, media control, or interoperability with a non-React DOM API are legitimate effect territory.

```tsx
function useAutoFocus(ref: React.RefObject<HTMLElement>) {
  useMountEffect(() => {
    ref.current?.focus();
  });
}
```

### 3. Third-party widget lifecycle

Widgets with `create` / `update` / `destroy` behavior are effect-shaped because React is synchronizing an imperative object graph.

```tsx
function useChartWidget(node: HTMLDivElement | null, data: ChartData) {
  useEffect(() => {
    if (!node) return;

    const chart = createChart(node, data);
    return () => chart.destroy();
  }, [node, data]);
}
```

### 4. Subscriptions without snapshot semantics

Some subscriptions do not fit `useSyncExternalStore` cleanly because there is no stable “read current snapshot” API or the subscription is really managing an imperative resource.

Typical examples:
- `IntersectionObserver`
- imperative widget events
- one-off SDK callbacks tied to an object lifecycle

Use a named hook with an effect instead of forcing these into `useSyncExternalStore`.

### 5. Pre-paint layout work

Use `useLayoutEffect` only when paint order matters:
- measuring size/position before paint
- restoring scroll before the user sees the frame
- tooltip/popover positioning
- synchronizing with APIs that must run after DOM commit but before paint

```tsx
function useRestoreScroll(ref: React.RefObject<HTMLElement>, top: number) {
  useLayoutEffect(() => {
    ref.current?.scrollTo({ top });
  }, [top]);
}
```

`useLayoutEffect` blocks paint. Treat it as the most expensive and least common option.

## `useMountEffect`

Keep this helper narrow. It is for stable mount/unmount integration with an external system.

```tsx
export function useMountEffect(setup: () => void | (() => void)) {
  // eslint-disable-next-line no-restricted-syntax
  useEffect(setup, []);
}
```

Rules:
- only use it for mount/unmount shaped work
- the setup must be idempotent
- cleanup must fully mirror setup
- do not use it to silence lints or emulate control flow

## Strict Mode and remount safety

In development Strict Mode, React does setup -> cleanup -> setup for effects. Surviving effects must tolerate that.

Checklist:
- setup can run twice without corrupting external state
- cleanup can run even if setup already partly failed
- no fire-and-forget mutation that cannot be deduped or rolled back
- one-time-per-app logic is not hidden in a component mount effect

## SSR and hydration

Check server behavior explicitly:
- `useEffect` does not run during server rendering
- `useLayoutEffect` is client-only and should not be used for logic required to produce initial HTML
- `useSyncExternalStore` needs a meaningful server snapshot when rendering on the server

## Dependencies

Dependencies must mean “re-synchronize with the external system”, not “re-run my business logic”.

Bad dependency thinking:
- “Add it so the linter shuts up”
- “Omit it so the effect only runs once”
- “Keep retrying until state looks right”

Good dependency thinking:
- “When `roomId` changes, reconnect to the room”
- “When `route` changes, send a page-view event”
- “When `node` or `data` changes, recreate/update the widget”

## Reject these non-justifications

These are not legitimate reasons for a surviving effect:
- “I needed to derive state from props”
- “I needed to reset local state when an ID changed”
- “I wanted the code to happen after render”
- “I needed to respond to a button click”
- “The linter complained, so I moved it into `useLayoutEffect`”

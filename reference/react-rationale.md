# React rationale behind this skill

This skill follows the current React docs rather than inventing a parallel mental model.

## Core model

Effects are an escape hatch for synchronizing with external systems:
- browser APIs
- network / external data sources
- third-party widgets
- imperative systems outside React

If there is no external system, the default assumption should be: **you probably do not need an effect**.

## What React wants instead

### Render-time derivation
If a value can be computed from props or state, compute it during render. Do not mirror it into another state variable through an effect.

### Event handlers
If something should happen because the user clicked, submitted, typed, or dragged, do it in the handler. The event is the cause.

### Reset with `key`
If switching identity should produce a fresh component instance, let React remount the subtree with a new `key`.

### Adjust during render or redesign state
If only part of state changes when props change, avoid effect choreography. Derive the needed value during render or simplify the state shape.

### Lift state up
If parent and child are trying to synchronize copies of the same information, remove one copy and let data flow down.

### `useSyncExternalStore`
If a value lives outside React and offers subscribe + snapshot semantics, read it with `useSyncExternalStore`.

## Important caveats

### Strict Mode
Development Strict Mode re-runs effects with setup -> cleanup -> setup. “Mount-only” logic must tolerate remounting.

### `useLayoutEffect`
`useLayoutEffect` blocks paint. Use it only when you must read or write layout before the browser repaints.

### App initialization
Logic that truly must happen once per app load belongs in the entrypoint, module scope, or an explicitly guarded root pattern. A component effect is the wrong abstraction for that.

## What this skill adds on top of React docs

React says when effects are or are not needed. This skill adds a project policy optimized for agentic coding:
- raw effects are not the default primitive
- surviving effects should usually be hidden behind named hooks
- the first screen of the skill carries the whole decision tree
- detailed rules and examples live in separate files so the entrypoint stays compact

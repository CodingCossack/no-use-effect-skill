# Replacement patterns

These are the replacements this skill prefers, in descending order of frequency.

## 1. Derive during render

```tsx
// BAD
function ProductList({ products }: { products: Product[] }) {
  const [visible, setVisible] = useState<Product[]>([]);

  useEffect(() => {
    setVisible(products.filter((p) => p.inStock));
  }, [products]);

  return <List items={visible} />;
}

// GOOD
function ProductList({ products }: { products: Product[] }) {
  const visible = products.filter((p) => p.inStock);
  return <List items={visible} />;
}
```

If the derivation is genuinely expensive, memoize the calculation rather than syncing a second piece of state:

```tsx
const visible = useMemo(() => expensiveFilter(products), [products]);
```

Use `useMemo` for measured cost or obviously heavy work, not as reflex.

---

## 2. Put event-specific work in the handler

```tsx
// BAD
function LikeButton({ postId }: { postId: string }) {
  const [liked, setLiked] = useState(false);

  useEffect(() => {
    if (!liked) return;
    void postLike(postId);
    setLiked(false);
  }, [liked, postId]);

  return <button onClick={() => setLiked(true)}>Like</button>;
}

// GOOD
function LikeButton({ postId }: { postId: string }) {
  async function handleLike() {
    await postLike(postId);
  }

  return <button onClick={handleLike}>Like</button>;
}
```

If multiple handlers share the same logic, extract a shared function and call it from the handlers. Do not bounce through state just so an effect can “notice” the action.

---

## 3. Use data APIs for screen-driven fetching

```tsx
// BAD
function ProductPage({ productId }: { productId: string }) {
  const [product, setProduct] = useState<Product | null>(null);

  useEffect(() => {
    fetchProduct(productId).then(setProduct);
  }, [productId]);
}

// GOOD
function ProductPage({ productId }: { productId: string }) {
  const { data: product } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
  });
}
```

Prefer, in this order when available:
1. Framework loaders / route data APIs
2. Server components
3. Query libraries such as TanStack Query or SWR
4. A focused custom data hook with cancellation

User-triggered requests still belong in the handler, not in an effect.

---

## 4. Lift state up or fetch in the parent

### Notify parent in the same handler

```tsx
// BAD
function Toggle({ onChange }: { onChange: (next: boolean) => void }) {
  const [isOn, setIsOn] = useState(false);

  useEffect(() => {
    onChange(isOn);
  }, [isOn, onChange]);

  return <button onClick={() => setIsOn(!isOn)}>Toggle</button>;
}

// GOOD
function Toggle({ onChange }: { onChange: (next: boolean) => void }) {
  const [isOn, setIsOn] = useState(false);

  function update(next: boolean) {
    setIsOn(next);
    onChange(next);
  }

  return <button onClick={() => update(!isOn)}>Toggle</button>;
}
```

### Pass data down instead of pushing it up from a child effect

```tsx
// BAD
function Parent() {
  const [data, setData] = useState<Data | null>(null);
  return <Child onFetched={setData} />;
}

function Child({ onFetched }: { onFetched: (data: Data) => void }) {
  const data = useSomeAPI();

  useEffect(() => {
    if (data) onFetched(data);
  }, [data, onFetched]);

  return null;
}

// GOOD
function Parent() {
  const data = useSomeAPI();
  return <Child data={data} />;
}

function Child({ data }: { data: Data | null }) {
  return null;
}
```

---

## 5. Reset with `key`

```tsx
// BAD
function Profile({ userId }: { userId: string }) {
  const [comment, setComment] = useState('');

  useEffect(() => {
    setComment('');
  }, [userId]);

  return <Editor value={comment} onChange={setComment} />;
}

// GOOD
function ProfilePage({ userId }: { userId: string }) {
  return <Profile key={userId} userId={userId} />;
}
```

Use `key` when the component should be a new instance for each identity.

---

## 6. Adjust partial state during render or redesign the state shape

```tsx
// BAD
function List({ items }: { items: Item[] }) {
  const [selection, setSelection] = useState<Item | null>(null);

  useEffect(() => {
    setSelection(null);
  }, [items]);

  return <Grid selection={selection} items={items} />;
}
```

Better options:
- derive what is selected from `selectedId` instead of storing the full object
- compare the current prop to the previous prop during render if you truly must adjust state
- redesign the state so it no longer has to mirror props

Prefer storing identities over duplicated objects:

```tsx
function List({ items }: { items: Item[] }) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const selection = items.find((item) => item.id === selectedId) ?? null;
  return <Grid selection={selection} items={items} onSelect={setSelectedId} />;
}
```

---

## 7. Use `useSyncExternalStore` for subscribe + snapshot sources

```tsx
function useOnlineStatus() {
  return useSyncExternalStore(
    (callback) => {
      window.addEventListener('online', callback);
      window.addEventListener('offline', callback);
      return () => {
        window.removeEventListener('online', callback);
        window.removeEventListener('offline', callback);
      };
    },
    () => navigator.onLine,
    () => true,
  );
}
```

Only use this when the source has:
- a way to subscribe and unsubscribe
- a stable way to read the current value right now
- acceptable server snapshot behavior

Observer-style DOM APIs and widget lifecycles often belong in a named effect hook instead.

---

## 8. App-wide init belongs outside component control flow

```tsx
// BETTER
if (typeof window !== 'undefined') {
  checkAuthToken();
  loadDataFromLocalStorage();
}

function App() {
  return <Routes />;
}
```

If that is too eager, keep the initialization at the root with an explicit one-time guard. Do not call something “mount only” and then act surprised when dev remount exposes the bug.

---

## Output policy for code review

When rewriting a component:
1. delete redundant state first
2. delete the effect second
3. re-express the logic in the smallest primitive that matches the cause
4. only after that, tune performance or naming

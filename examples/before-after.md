# Before / after examples

## Derived state

```tsx
// BAD
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);

// GOOD
const fullName = firstName + ' ' + lastName;
```

## Event relay

```tsx
// BAD
const [pendingSave, setPendingSave] = useState(false);
useEffect(() => {
  if (!pendingSave) return;
  void save(form);
  setPendingSave(false);
}, [pendingSave, form]);

// GOOD
async function handleSave() {
  await save(form);
}
```

## Screen-driven fetch

```tsx
// BAD
const [product, setProduct] = useState<Product | null>(null);
useEffect(() => {
  fetchProduct(productId).then(setProduct);
}, [productId]);

// GOOD
const { data: product } = useQuery({
  queryKey: ['product', productId],
  queryFn: () => fetchProduct(productId),
});
```

## Reset by identity

```tsx
// BAD
useEffect(() => {
  setComment('');
}, [userId]);

// GOOD
return <Profile key={userId} userId={userId} />;
```

## Parent notification

```tsx
// BAD
useEffect(() => {
  onChange(isOn);
}, [isOn, onChange]);

// GOOD
function update(next: boolean) {
  setIsOn(next);
  onChange(next);
}
```

## External store

```tsx
// BAD
useEffect(() => {
  function onResize() {
    setWidth(window.innerWidth);
  }

  window.addEventListener('resize', onResize);
  return () => window.removeEventListener('resize', onResize);
}, []);

// GOOD
const width = useSyncExternalStore(
  (callback) => {
    window.addEventListener('resize', callback);
    return () => window.removeEventListener('resize', callback);
  },
  () => window.innerWidth,
  () => 1024,
);
```

## Legitimate survivor

```tsx
function usePageView(route: string) {
  useEffect(() => {
    analytics.page(route);
  }, [route]);
}
```

The effect survives because it synchronizes with an external analytics system and the hook name says so explicitly.

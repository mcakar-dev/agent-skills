# Common React Anti-Patterns and Fixes

Reference for detecting and fixing common React/TypeScript anti-patterns.

---

## Component Design Anti-Patterns

### God Component

**Detection:** Component > 200 lines, handles data fetching, business logic, and rendering simultaneously.

```tsx
// BAD
const ProductPage = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [filter, setFilter] = useState('');
  const [cart, setCart] = useState<CartItem[]>([]);

  useEffect(() => {
    fetch('/api/products').then(r => r.json()).then(setProducts);
  }, []);

  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(filter.toLowerCase())
  );

  const addToCart = (product: Product) => {
    setCart(prev => [...prev, { product, quantity: 1 }]);
  };

  return (
    <div>
      <input onChange={e => setFilter(e.target.value)} />
      {filtered.map(p => (
        <div key={p.id}>
          <span>{p.name}</span>
          <button onClick={() => addToCart(p)}>Add</button>
        </div>
      ))}
    </div>
  );
};
```

**Architectural Implication:** Violates SRP. Untestable in isolation. Impossible to reuse individual concerns.

**Fix:** Decompose into custom hooks and focused components.

```tsx
// GOOD
const ProductPage = () => {
  const { products } = useProducts();
  const { filter, filteredProducts } = useProductFilter(products);
  const { addToCart } = useCart();

  return (
    <div>
      <ProductFilter filter={filter} />
      <ProductList products={filteredProducts} onAddToCart={addToCart} />
    </div>
  );
};
```

---

### Prop Drilling

**Detection:** A prop is passed through 3+ component levels without being consumed by intermediate components.

```tsx
// BAD — theme passed through 3 levels without use
<App theme={theme}>
  <Layout theme={theme}>        // doesn't use theme
    <Sidebar theme={theme}>     // doesn't use theme
      <MenuItem theme={theme} /> // finally uses it
    </Sidebar>
  </Layout>
</App>
```

**Architectural Implication:** Creates invisible coupling between unrelated components. Refactoring the tree breaks all intermediaries.

**Fix:** Use React Context for cross-cutting concerns.

```tsx
// GOOD
const ThemeContext = React.createContext<Theme>(defaultTheme);

const App = () => (
  <ThemeContext.Provider value={theme}>
    <Layout />
  </ThemeContext.Provider>
);

const MenuItem = () => {
  const theme = useContext(ThemeContext);
  return <li style={{ color: theme.primary }}>...</li>;
};
```

---

### Logic in JSX Return

**Detection:** Complex transformations, filtering, or conditions inside the JSX `return` block.

```tsx
// BAD — business logic inside JSX
return (
  <div>
    {users
      .filter(u => u.role === 'ADMIN' && u.isActive && !u.isBanned)
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, 10)
      .map(u => <UserCard key={u.id} user={u} />)
    }
  </div>
);
```

**Architectural Implication:** Untestable logic, high cognitive complexity, violates SRP.

**Fix:** Move logic to a hook or derived variable before the return.

```tsx
// GOOD
const activeAdmins = useActiveAdmins(users);

return (
  <div>
    {activeAdmins.map(u => <UserCard key={u.id} user={u} />)}
  </div>
);
```

---

## Hooks Anti-Patterns

### Stale Closure in useEffect

**Detection:** Variables or functions used inside `useEffect` are not listed in the dependency array.

```tsx
// BAD — stale closure
const [count, setCount] = useState(0);

useEffect(() => {
  const interval = setInterval(() => {
    console.log(count); // Always logs 0 (stale)
  }, 1000);
  return () => clearInterval(interval);
}, []); // count is missing from deps
```

**Fix:**

```tsx
useEffect(() => {
  const interval = setInterval(() => {
    setCount(prev => prev + 1); // Use functional update to avoid stale closure
  }, 1000);
  return () => clearInterval(interval);
}, []);
```

---

### Infinite Re-render Loop

**Detection:** Object or function created inline is used as a `useEffect` dependency.

```tsx
// BAD — new object reference on every render causes infinite loop
const options = { page: 1 }; // new reference each render

useEffect(() => {
  fetchData(options);
}, [options]); // triggers every render
```

**Fix:**

```tsx
// GOOD — stable reference with useMemo
const options = useMemo(() => ({ page: 1 }), []);

useEffect(() => {
  fetchData(options);
}, [options]);
```

---

### Overusing useEffect

**Detection:** `useEffect` used to transform data that could be derived directly.

```tsx
// BAD — derived state anti-pattern
const [filteredItems, setFilteredItems] = useState([]);

useEffect(() => {
  setFilteredItems(items.filter(i => i.isActive));
}, [items]);
```

**Fix:** Compute during render directly.

```tsx
// GOOD — derived value, no effect needed
const filteredItems = items.filter(i => i.isActive);
```

---

## State Management Anti-Patterns

### Direct State Mutation

**Detection:** Array or object methods that mutate in-place called on state.

```tsx
// BAD
const handleAdd = (item: Item) => {
  items.push(item);     // mutation: push
  setItems(items);
};

const handleUpdate = (id: string, value: string) => {
  const item = items.find(i => i.id === id);
  item.value = value;   // mutation: direct property assignment
  setItems([...items]);
};
```

**Architectural Implication:** React relies on reference equality to detect changes. Mutating state directly causes missed re-renders and undefined behavior.

**Fix:**

```tsx
const handleAdd = (item: Item) => {
  setItems(prev => [...prev, item]);
};

const handleUpdate = (id: string, value: string) => {
  setItems(prev =>
    prev.map(item => item.id === id ? { ...item, value } : item)
  );
};
```

---

### Unnecessary State

**Detection:** `useState` used for values that can be computed from existing state or props.

```tsx
// BAD — redundant state
const [items, setItems] = useState<Item[]>([]);
const [itemCount, setItemCount] = useState(0); // derived from items

useEffect(() => {
  setItemCount(items.length);
}, [items]);
```

**Fix:**

```tsx
// GOOD — derived value
const [items, setItems] = useState<Item[]>([]);
const itemCount = items.length; // computed, not state
```

---

## Performance Anti-Patterns

### Missing React.memo on Pure Components

**Detection:** A component that always renders the same output for the same props but is not wrapped in `React.memo`.

```tsx
// BAD — re-renders on every parent render
const UserAvatar = ({ user }: { user: User }) => (
  <img src={user.avatarUrl} alt={user.name} />
);

// GOOD
const UserAvatar = React.memo(({ user }: { user: User }) => (
  <img src={user.avatarUrl} alt={user.name} />
));
```

---

### Inline Objects and Functions in JSX

**Detection:** Objects, arrays, or arrow functions defined inline in JSX props.

```tsx
// BAD — new style object on every render breaks React.memo
<Button style={{ color: 'red', fontWeight: 'bold' }} onClick={() => handleClick(id)} />

// GOOD
const buttonStyle: React.CSSProperties = { color: 'red', fontWeight: 'bold' };
const handleButtonClick = useCallback(() => handleClick(id), [id, handleClick]);

<Button style={buttonStyle} onClick={handleButtonClick} />
```

---

## TypeScript Anti-Patterns

### Overuse of Type Assertion (`as`)

**Detection:** `as` keyword used to bypass type safety instead of proper type narrowing.

```tsx
// BAD — blindly casting API response
const user = response.data as User;

// GOOD — validate with type guard
function isUser(val: unknown): val is User {
  return (
    typeof val === 'object' &&
    val !== null &&
    typeof (val as User).id === 'string'
  );
}

if (isUser(response.data)) {
  const user = response.data; // correctly typed
}
```

---

### Non-Null Assertion Overuse

**Detection:** `!` non-null assertion used frequently to suppress TypeScript errors.

```tsx
// BAD — silencing the compiler
const name = user!.profile!.name!;

// GOOD — proper optional chaining with fallback
const name = user?.profile?.name ?? 'Unknown';
```

---

## Accessibility Anti-Patterns

### Non-Semantic Click Handlers

**Detection:** `onClick` placed on non-interactive elements without keyboard support.

```tsx
// BAD
<div onClick={handleSelect} className="option">
  {label}
</div>

// GOOD
<button
  type="button"
  onClick={handleSelect}
  className="option"
>
  {label}
</button>
```

**Architectural Implication:** Keyboard-only users and screen readers cannot interact with the element. Violates WCAG 2.1 Success Criterion 2.1.1.

# React Code Review Checklist

Detailed review rules organized by priority. Reference this during Phase 2 analysis.

---

## P1: Security (CRITICAL)

| Check | Detection | Architectural Implication |
|-------|-----------|---------------------------|
| XSS via dangerouslySetInnerHTML | Unsanitized user input passed to `dangerouslySetInnerHTML` | Enables script injection, full DOM takeover |
| Exposed secrets | `apiKey`, `token`, `secret`, `password` literals in source files | Credentials leaked in public bundle |
| Insecure `eval` / `new Function` | Dynamic code execution from user input | Remote code execution vector |
| Open redirect | `window.location.href = userInput` without validation | Phishing, redirect attacks |
| Clickjacking via iframe | Rendering untrusted URLs in `<iframe>` without `sandbox` | UI redress attacks |
| Prototype pollution | Merging user objects without sanitization | Property injection on Object.prototype |

### XSS detection

```tsx
// BAD
const UserContent = ({ htmlContent }: { htmlContent: string }) => (
  <div dangerouslySetInnerHTML={{ __html: htmlContent }} />
);

// GOOD — sanitize before rendering
import DOMPurify from 'dompurify';

const UserContent = ({ htmlContent }: { htmlContent: string }) => (
  <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(htmlContent) }} />
);
```

### Secret detection

```tsx
// BAD — secret in source code
const API_KEY = 'sk-abc123secret';

// GOOD — environment variable (never committed)
const API_KEY = import.meta.env.VITE_API_KEY;
```

---

## P2: Architecture & Design (CRITICAL/MAJOR)

### Single Responsibility Principle (SRP)

| Violation | Check |
|-----------|-------|
| God component | Component > 200 lines or handles data fetching + state + rendering |
| Mixed concerns | Component directly calls API without a service/hook layer |
| Business logic in JSX | Complex conditions / transformations inline in JSX return |

```tsx
// BAD — god component
const UserDashboard = () => {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);
  const admins = users.filter(u => u.role === 'ADMIN');
  // ... 150 more lines of rendering
};

// GOOD — separated concerns
const UserDashboard = () => {
  const { users } = useUsers();
  const admins = useAdminUsers(users);
  return <UserList users={admins} />;
};
```

### Prop Drilling (DIP / Composition)

| Violation | Check |
|-----------|-------|
| Prop drilling > 2 levels | Prop passed through 3+ components without being consumed |
| Callback hell | 4+ handler props passed down component tree |

**Fix:** Use React Context, Zustand, or component composition.

### Open/Closed Principle (OCP)

| Violation | Check |
|-----------|-------|
| Hard-coded behavior | `if (type === 'admin')` chains controlling rendering |
| Switch on variant | `switch(variant)` for component behavior |

---

## P3: Hooks Correctness (CRITICAL/MAJOR)

### Rules of Hooks

```tsx
// BAD — hook inside condition
const MyComponent = ({ isLoggedIn }) => {
  if (isLoggedIn) {
    const [count, setCount] = useState(0); // CRITICAL
  }
};

// GOOD
const MyComponent = ({ isLoggedIn }) => {
  const [count, setCount] = useState(0);
  if (!isLoggedIn) return null;
};
```

### useEffect Dependency Array

| Violation | Check |
|-----------|-------|
| Missing dependency | Variable used inside `useEffect` not in deps array |
| Stale closure | Function or object ref from outer scope not included in deps |
| Infinite loop | Object/function created inline used as dependency |

```tsx
// BAD — missing dependency (stale closure)
useEffect(() => {
  fetchData(userId); // userId used but not in deps
}, []);

// GOOD
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

### Direct State Mutation

```tsx
// BAD — direct mutation
const addItem = (item: Item) => {
  state.items.push(item); // CRITICAL: does not trigger re-render
  setState(state);
};

// GOOD — immutable update
const addItem = (item: Item) => {
  setState(prev => ({ ...prev, items: [...prev.items, item] }));
};
```

### Custom Hook Naming

```tsx
// BAD — custom hook without "use" prefix
const fetchUser = () => { /* uses useState */ };

// GOOD
const useFetchUser = () => { /* uses useState */ };
```

---

## P4: Performance (MAJOR)

### Missing Key Props in Lists

```tsx
// BAD — missing key or using array index
items.map((item, index) => <Item key={index} />);

// GOOD — stable, unique key
items.map(item => <Item key={item.id} />);
```

### Unnecessary Re-renders

| Violation | Check |
|-----------|-------|
| Missing `React.memo` | Pure component without memoization receiving stable props |
| Missing `useCallback` | Handler function passed as prop, recreated every render |
| Missing `useMemo` | Expensive computation inside component body without memoization |
| Inline object/array in JSX | `<Component config={{ size: 'lg' }} />` creates new reference every render |

```tsx
// BAD — new function reference every render
const Parent = () => {
  const handleClick = () => doSomething(); // recreated on every render
  return <Child onClick={handleClick} />;
};

// GOOD
const Parent = () => {
  const handleClick = useCallback(() => doSomething(), []);
  return <Child onClick={handleClick} />;
};
```

### Lazy Loading

```tsx
// BAD — heavy component always imported eagerly
import HeavyChart from './HeavyChart';

// GOOD — lazy load on demand
const HeavyChart = React.lazy(() => import('./HeavyChart'));
```

---

## P5: TypeScript Safety (MAJOR)

### No `any` Type

```tsx
// BAD
const handleEvent = (e: any) => { e.target.value; };

// GOOD
const handleEvent = (e: React.ChangeEvent<HTMLInputElement>) => {
  e.target.value;
};
```

### Avoid Type Assertions Without Validation

```tsx
// BAD
const user = data as User; // blindly casting

// GOOD — validate before casting or use type guards
const isUser = (val: unknown): val is User =>
  typeof val === 'object' && val !== null && 'id' in val;
```

### Prop Types with `interface`

```tsx
// BAD — untyped or implicit any props
const Button = ({ label, onClick }) => { ... };

// GOOD
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}
const Button = ({ label, onClick, disabled = false }: ButtonProps) => { ... };
```

---

## P6: Clean Code (MINOR/MAJOR)

### Naming Conventions

| Rule | Bad | Good |
|------|-----|------|
| Components: PascalCase | `userCard` | `UserCard` |
| Hooks: camelCase with `use` prefix | `fetchUser` | `useFetchUser` |
| Event handlers: `handle` prefix | `click`, `onChange` | `handleClick`, `handleChange` |
| Boolean props: `is`/`has`/`can` | `loading`, `active` | `isLoading`, `isActive` |
| Constants: SCREAMING_SNAKE_CASE | `maxRetries` | `MAX_RETRIES` |

### Magic Literals

```tsx
// BAD
if (status === 3) { ... }
if (role === 'admin') { ... }

// GOOD
const STATUS_ACTIVE = 3;
const ROLE_ADMIN = 'admin' as const;
```

### Conditional Rendering

```tsx
// BAD — potential "0" render bug
{items.length && <List items={items} />}

// GOOD — explicit boolean
{items.length > 0 && <List items={items} />}

// BEST — ternary for clarity
{items.length > 0 ? <List items={items} /> : <Empty />}
```

### DRY Violations

| Detection | Fix |
|-----------|-----|
| Duplicate JSX blocks | Extract to component or shared hook |
| Repeated style values | Extract to CSS variable or design token |
| Copy-pasted hook logic | Extract to custom hook |

---

## P7: Accessibility (MINOR)

| Check | Bad | Good |
|-------|-----|------|
| Image alt text | `<img src="..." />` | `<img src="..." alt="Description" />` |
| Button accessibility | `<div onClick={...}>Click</div>` | `<button onClick={...}>Click</button>` |
| Form labels | `<input type="text" />` | `<input type="text" aria-label="Name" />` or `<label>` |
| Keyboard navigation | Mouse-only handlers | `onKeyDown` alongside `onClick` for custom elements |
| Color contrast | Low contrast text | Ensure WCAG AA compliance (4.5:1 ratio) |

---

## P8: Testing (MAJOR/MINOR)

### Naming Convention

Use `given_when_then` format:

```tsx
// BAD
test('renders button', () => { ... });

// GOOD
test('givenDisabledProp_whenRendered_thenButtonIsNotClickable', () => { ... });
```

### Test Behavior, Not Implementation

```tsx
// BAD — testing implementation detail
expect(component.state.isLoading).toBe(true);

// GOOD — testing observable behavior
expect(screen.getByRole('progressbar')).toBeInTheDocument();
```

### Avoid `getByTestId` Overuse

```tsx
// BAD — brittle, tied to implementation
screen.getByTestId('submit-btn');

// GOOD — semantic query
screen.getByRole('button', { name: /submit/i });
```

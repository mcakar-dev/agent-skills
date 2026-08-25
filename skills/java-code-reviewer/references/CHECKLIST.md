# Code Review Checklist

Detailed review rules organized by priority. Reference this during Phase 2 analysis.

---

## P1: Security (CRITICAL)

| Check | Detection | Architectural Implication |
|-------|-----------|---------------------------|
| SQL Injection | String concatenation in queries | Opens database to malicious queries |
| XSS | Unescaped user input in responses | Enables script injection attacks |
| Sensitive Data | Logging passwords, tokens, PII | Data breach risk, compliance violation |
| Thread Safety | Shared mutable state without sync | Race conditions, data corruption |
| Insecure Dependencies | Known CVEs in libraries | System compromise vector |

### SQL Injection detection

```java
// BAD
String query = "SELECT * FROM users WHERE id = " + userId;

// GOOD
@Query("SELECT u FROM User u WHERE u.id = :id")
User findById(@Param("id") Long id);
```

---

## P2: Architecture & SOLID (CRITICAL/MAJOR)

### Single Responsibility Principle (SRP)

| Violation | Check |
|-----------|-------|
| God class | Class > 500 lines |
| Method too long | Method > 20 lines |
| Method too complex | Cyclomatic complexity > 10 |
| Mixed concerns | Controller doing business logic |

### Open/Closed Principle (OCP)

| Violation | Check |
|-----------|-------|
| Switch on type | `switch(type)` for behavior |
| Hard-coded conditions | `if (type == "A")` chains |

### Liskov Substitution Principle (LSP)

| Violation | Check |
|-----------|-------|
| Throwing in override | `throw new UnsupportedOperationException()` |
| Strengthening preconditions | Subclass rejecting valid parent inputs |

### Interface Segregation Principle (ISP)

| Violation | Check |
|-----------|-------|
| Fat interface | Interface with 10+ methods |
| Unused implementations | Empty method bodies in implementers |

### Dependency Inversion Principle (DIP)

| Violation | Check | Severity |
|-----------|-------|----------|
| Concrete dependencies | `new ConcreteClass()` in service | MAJOR |
| Field injection | `@Autowired` on fields | CRITICAL |
| Missing abstraction | Depending on implementation, not interface | MAJOR |

### Composition over Inheritance

| Violation | Check | Severity |
|-----------|-------|----------|
| Deep inheritance | Subclass chain > 1 level, or `extends` used to reuse/vary behavior rather than model an is-a relationship | MAJOR |
| Fragile base class | Subclass depends on base class internals | MAJOR |

See [references/PATTERNS.md](references/PATTERNS.md) for the full Deep Inheritance / Composition example.

### Feature Envy & Primitive Obsession

| Violation | Check | Severity |
|-----------|-------|----------|
| Feature envy | Method operates mostly on another class's data instead of its own | MAJOR |
| Primitive obsession | 3+ unrelated primitive parameters representing a single domain concept | MINOR |

See [references/PATTERNS.md](references/PATTERNS.md) for the full Feature Envy / Primitive Obsession examples.

### KISS & YAGNI (Over-Engineering)

| Violation | Check | Severity |
|-----------|-------|----------|
| Speculative generality | Interface with exactly one implementation and no documented extension plan | MAJOR |
| Unused variability | Configuration flags/parameters not exercised by any current requirement | MINOR |
| Unnecessary abstraction | Extra wrapper/factory layer for a single code path | MINOR |

---

## P3: Performance (MAJOR)

| Issue | Detection | Fix |
|-------|-----------|-----|
| N+1 Query | Loop with individual fetches | Use `@EntityGraph` or `JOIN FETCH` |
| Unnecessary Object Creation | `new` inside loops | Move outside or use pool |
| Inefficient Stream | Multiple stream operations | Combine operations |
| Missing Index | Query on unindexed column | Add database index |
| Big O Violation | Nested loops on large data | Use HashMap, optimize algorithm |

### N+1 Query example

```java
// BAD - N+1 queries
List<Order> orders = orderRepository.findAll();
orders.forEach(o -> o.getItems().size()); // Triggers N queries

// GOOD - Single query
@Query("SELECT o FROM Order o JOIN FETCH o.items")
List<Order> findAllWithItems();
```

---

## P4: Clean Code (MINOR/MAJOR)

### Naming

| Rule | Bad | Good |
|------|-----|------|
| Meaningful names | `d`, `temp`, `data` | `elapsedDays`, `userCache` |
| Verb for methods | `user()` | `getUser()`, `createUser()` |
| Boolean prefix | `status` | `isActive`, `hasPermission` |

### DRY Violations

| Detection | Fix |
|-----------|-----|
| Duplicate code blocks | Extract to private method |
| Similar methods | Parameterize differences |
| Copy-paste logic | Create utility class |

### Magic Literals

```java
// BAD
if (status == 1) { ... }
if (role.equals("ADMIN")) { ... }

// GOOD
private static final int STATUS_ACTIVE = 1;
private static final String ROLE_ADMIN = "ADMIN";
```

### Encapsulation

```java
// BAD - leaks mutable internal state
public List<Item> getItems() {
    return items;
}

// GOOD - immutable view or defensive copy
public List<Item> getItems() {
    return List.copyOf(items);
}
```

Also flag Law of Demeter violations (`a.getB().getC().getD()` call chains) — see [references/PATTERNS.md](references/PATTERNS.md).

---

## P5: Spring Boot Specific (CRITICAL/MAJOR)

### Dependency Injection

```java
// BAD - Field injection
@Autowired
private UserService userService;

// GOOD - Constructor injection
private final UserService userService;

public UserController(UserService userService) {
    this.userService = userService;
}

// BETTER - Lombok
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
}
```

### Exception Handling

Flag generic `catch (Exception e)` and empty catch blocks; require a specific exception type plus SLF4J error logging. See [references/PATTERNS.md](references/PATTERNS.md) "Swallowing Exceptions" for the full example and architectural implication.

### Static Imports

```java
// BAD
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

// GOOD - In production code
Assertions.assertEquals(expected, actual);
Mockito.when(mock.method()).thenReturn(value);
```

---

## P6: Testing (MAJOR/MINOR)

### Naming Convention

Use `given_when_then` format:

```java
// BAD
@Test
void testSaveUser() { ... }

// GOOD
@Test
void givenValidUser_whenSave_thenReturnsId() { ... }
```

### Immutability in Tests

```java
// BAD - Mutable object reuse
User user = new User();
user.setName("test");
service.save(user);
verify(repository).save(user); // Reference mutation bug

// GOOD - ArgumentCaptor
ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
verify(repository).save(captor.capture());
assertThat(captor.getValue().getName()).isEqualTo("test");
```

### Output Reference Sharing (Self-Comparison Pitfall)

```java
// BAD - stub return value and assertion expectation are the same reference
ResponseDto expectedResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();
Mockito.doReturn(expectedResponse).when(mapper).toDto(Mockito.any());
ResponseDto result = service.process("1001");
assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse); // passes even if result is mutated

// GOOD - independent instances for stub return value and assertion expectation
ResponseDto mockResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();
ResponseDto expectedResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();
Mockito.doReturn(mockResponse).when(mapper).toDto(Mockito.any());
```

### Stub Argument Matching

```java
// BAD - exact reference matching in stub, silently returns null if argument is mutated first
Mockito.doReturn(externalDto).when(mapper).toExternal(requestDto);

// GOOD - permissive matcher in stub, verify actual argument separately with ArgumentCaptor
Mockito.doReturn(externalDto).when(mapper).toExternal(Mockito.any(RequestDto.class));
```

### Full Object Graph Assertions

Flag single/partial field assertions on multi-field DTOs; require `usingRecursiveComparison()` against an expected template object instead.

### Verification Style

Flag `Mockito.verify(mock, Mockito.times(1))` as redundant — `Mockito.verify(mock)` already defaults to one invocation. Negative-flow tests (validation failures, short-circuits) must assert `Mockito.verify(mock, Mockito.never())` or `Mockito.verifyNoInteractions(mock)` on the dependencies that must not be touched.

### Test Fixture Isolation

Flag mutable fixtures declared as class fields or built in `@BeforeEach`; require static factory methods (e.g., `TestObjectFactory`) that return a fresh instance per test, with magic literals centralized as `public static final` constants.

### Coverage Rules

- Aim for 100% on NEW lines
- If line is unreachable, explain why
- Create refactor plan for unreachable code

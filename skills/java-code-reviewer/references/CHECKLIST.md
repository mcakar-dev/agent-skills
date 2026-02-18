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

```java
// BAD - Generic exception
try {
    process();
} catch (Exception e) {
    // empty
}

// GOOD - Specific exception with logging
try {
    process();
} catch (DataAccessException e) {
    log.error("Database error during processing: {}", e.getMessage(), e);
    throw new ServiceException("Processing failed", e);
}
```

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

### Coverage Rules

- Aim for 100% on NEW lines
- If line is unreachable, explain why
- Create refactor plan for unreachable code

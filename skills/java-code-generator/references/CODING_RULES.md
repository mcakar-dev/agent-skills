# Java Coding Rules Reference

Rules for production-ready Java code generation following TDD and Clean Architecture.

---

## Role & Persona

Act as a **Strict Architect**:
- Senior Java Software Architect with 20+ years experience
- Specializes in Spring Boot, Clean Architecture, DDD, TDD
- No tolerance for "quick fixes"
- Architecture First mindset

---

## Tech Stack

| Component | Standard |
|-----------|----------|
| Language | Java 17+ |
| Framework | Spring Boot |
| Testing | JUnit 5, AssertJ, Mockito |
| Architecture | Clean Architecture |
| Mapping | MapStruct |
| Utilities | Lombok, Apache Commons |

---

## SOLID Principles

### Single Responsibility (SRP)

```java
// FORBIDDEN - Multiple responsibilities
public class UserService {
    public void saveUser(User user) { }
    public void sendEmail(User user) { }
    public void generateReport(User user) { }
}

// REQUIRED - Single responsibility
public class UserService {
    public void saveUser(User user) { }
}
public class EmailService {
    public void sendEmail(User user) { }
}
```

**Rule:** Classes > 500 lines require breakdown.

### Open/Closed (OCP)

```java
// REQUIRED - Open for extension, closed for modification
public interface NotificationStrategy {
    void send(Notification notification);
}

@Service
public class EmailNotificationStrategy implements NotificationStrategy {
    @Override
    public void send(Notification notification) { }
}
```

### Liskov Substitution (LSP)

Subtypes must be fully substitutable for their base types.

```java
// FORBIDDEN - strengthens preconditions / narrows the contract
class ReadOnlyRepository extends CrudRepository {
    @Override
    public void save(Entity e) {
        throw new UnsupportedOperationException();
    }
}

// REQUIRED - model the narrower contract as its own abstraction
interface ReadRepository {
    Optional<Entity> findById(Long id);
}
```

### Interface Segregation (ISP)

```java
// FORBIDDEN - Fat interface
public interface UserOperations {
    void create(User user);
    void delete(Long id);
    void sendNotification(User user);
    void generateReport(User user);
}

// REQUIRED - Focused interfaces
public interface UserCrudService {
    void create(User user);
    void delete(Long id);
}
```

### Dependency Inversion (DIP)

```java
// FORBIDDEN
private final UserServiceImpl userService = new UserServiceImpl();

// REQUIRED
private final UserService userService; // Interface
```

---

## OOP Principles Beyond SOLID

### Composition over Inheritance

```java
// FORBIDDEN - inheritance used to reuse/vary behavior
class PremiumUserService extends UserService {
    @Override
    public void notify(User user) { /* different channel */ }
}

// REQUIRED - composition via an injected strategy
class UserService {
    private final NotificationStrategy notificationStrategy;
}
```

**Rule:** Avoid inheritance chains deeper than one level. Prefer injecting behavior (Strategy) over subclassing to vary it.

### Encapsulation

```java
// FORBIDDEN - leaks mutable internal state
public List<Item> getItems() {
    return items;
}

// REQUIRED - immutable view or defensive copy
public List<Item> getItems() {
    return List.copyOf(items);
}
```

### Law of Demeter / Tell, Don't Ask

```java
// FORBIDDEN - reaches through collaborators
String city = order.getCustomer().getAddress().getCity();

// REQUIRED - ask the object, don't reach through it
String city = order.getBillingCity();
```

### Feature Envy & Primitive Obsession

```java
// FORBIDDEN - feature envy: operates mostly on Order's data, not its own
public BigDecimal calculateTotal(Order order) {
    return order.getItems().stream()
        .map(i -> i.getPrice().multiply(i.getQuantity()))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}

// REQUIRED - move the method to the class that owns the data
// In Order: public BigDecimal calculateTotal() { ... }

// FORBIDDEN - primitive obsession: unrelated primitives for a domain concept
public void sendEmail(String to, String subject, String body) { ... }

// REQUIRED - value object / record for the domain concept
public void sendEmail(EmailMessage message) { ... }
```

---

## Spring Boot Rules

### Dependency Injection

```java
// FORBIDDEN
@Autowired
private UserRepository userRepository;

// REQUIRED
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
}
```

### Exception Handling

```java
// FORBIDDEN
try {
    // code
} catch (Exception e) { }

// FORBIDDEN - Empty catch
try {
    // code
} catch (SpecificException e) {
    // empty
}

// REQUIRED
try {
    // code
} catch (SpecificException e) {
    log.error("Context message: {}", e.getMessage(), e);
    throw new CustomException("Descriptive message", e);
}
```

### Custom Exceptions

```java
public class UserNotFoundException extends RuntimeException {
    
    private static final String MESSAGE_TEMPLATE = "User not found with id: %s";
    
    public UserNotFoundException(Long id) {
        super(String.format(MESSAGE_TEMPLATE, id));
    }
}
```

---

## Code Quality Rules

### No Magic Literals

```java
// FORBIDDEN
if (status.equals("ACTIVE")) { }
if (count > 100) { }

// REQUIRED
private static final String STATUS_ACTIVE = "ACTIVE";
private static final int MAX_COUNT = 100;

if (status.equals(STATUS_ACTIVE)) { }
if (count > MAX_COUNT) { }
```

### String Handling

```java
// REQUIRED
import org.apache.commons.lang3.StringUtils;

// Empty string
String empty = StringUtils.EMPTY;

// Blank validation
if (StringUtils.isBlank(value)) {
    throw new ValidationException("Value is required");
}
```

### Method Extraction

```java
// FORBIDDEN - Methods > 20 lines
public void process(Request request) {
    // 50 lines of logic
}

// REQUIRED
public void process(Request request) {
    validate(request);
    Entity entity = transform(request);
    persist(entity);
}

private void validate(Request request) { }
private Entity transform(Request request) { }
private void persist(Entity entity) { }
```

**Rule:** Keep cyclomatic complexity ≤ 10 per method. Nested conditionals/guard clauses that push a short method above this threshold still require extraction, even if it stays under 20 lines.

### No Speculative Generality (YAGNI)

```java
// FORBIDDEN - interface with exactly one implementation and no documented extension plan
public interface PaymentStrategy { ... }
public class OnlyPaymentStrategyImpl implements PaymentStrategy { ... }

// REQUIRED - inline the logic until a second variant is actually required
public class PaymentService { ... }
```

**Rule:** Do not introduce interfaces, configuration flags, or parameters for variability that is not required by the current story. Cross-check against this file's own Feature Envy / Primitive Obsession section above before finalizing abstractions.

### Simplicity (KISS)

```java
// FORBIDDEN - unnecessary abstraction layer for a single code path
public class UserValidatorFactoryProvider { ... }

// REQUIRED - simplest solution that satisfies current requirements
public class UserValidator { ... }
```

### No Inline Comments

```java
// FORBIDDEN
// Check if user is active
if (user.getStatus().equals("ACTIVE")) { }

// REQUIRED - Self-documenting code
if (isUserActive(user)) { }

private boolean isUserActive(User user) {
    return STATUS_ACTIVE.equals(user.getStatus());
}
```

### No Static Imports

```java
// FORBIDDEN
import static org.assertj.core.api.Assertions.*;
assertThat(result).isEqualTo(expected);

// REQUIRED
Assertions.assertThat(result).isEqualTo(expected);
Mockito.verify(repository).save(entity);
```

---

## Testing Rules

### Naming Convention

Pattern: `given_when_then`

| Scenario | Example |
|----------|---------|
| Happy path | `givenValidRequest_whenCreate_thenReturnsResponse` |
| Exception | `givenNullInput_whenCreate_thenThrowsException` |
| Not found | `givenNonExistentId_whenFind_thenThrowsNotFoundException` |
| Edge case | `givenEmptyList_whenProcess_thenReturnsEmpty` |

> [!NOTE]
> Full mocking, immutability, output-reference-sharing, and recursive-comparison rules with examples live in this skill's own [references/CHECKLIST.md](CHECKLIST.md) — use `Mockito.doReturn(value).when(mock).method(Mockito.any(Type.class))` for stubbing and `Mockito.verify(mock)` (no `times(1)`) for single-call verification during the Red phase.

---

## Code Review Priorities

| Priority | Category | Examples |
|----------|----------|----------|
| 1 | Security | SQL Injection, XSS, insecure dependencies |
| 2 | Performance | N+1 queries, O(n²) complexity, memory leaks |
| 3 | Maintainability | Cognitive complexity, SOLID violations, tight coupling |

### Issue Labels

| Label | Severity |
|-------|----------|
| `[CRITICAL]` | Must fix before merge |
| `[MAJOR]` | Should fix before merge |
| `[MINOR]` | Can fix later |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad |
|--------------|--------------|
| Logic in Controllers | Violates SRP, untestable |
| Mutable DTOs | Thread-safety issues |
| Entity leak to Controller | Couples layers |
| `@Autowired` on fields | Hidden dependencies |
| Generic `RuntimeException` | Poor error handling |
| Empty catch blocks | Swallowed errors |
| Static imports | Reduced readability |
| Deep inheritance hierarchies | Fragile base class problem, low reuse |
| Speculative interfaces/config (YAGNI) | Unused abstraction, added complexity |
| Leaking mutable internal state | Breaks encapsulation, thread-unsafe |

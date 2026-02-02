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

### Mocking

```java
// REQUIRED - Use doReturn() to avoid real method invocation
Mockito.doReturn(value).when(mock).method();

// Verify with times
Mockito.verify(mock, Mockito.times(1)).method();
```

### Immutability Pattern

```java
// FORBIDDEN - Reference mutation
User user = new User();
user.setName("test");
service.save(user);
Mockito.verify(repository).save(user); // WRONG

// REQUIRED - ArgumentCaptor
ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
Mockito.verify(repository).save(captor.capture());
Assertions.assertThat(captor.getValue().getName()).isEqualTo("test");

// REQUIRED - ArgumentMatchers
Mockito.verify(repository).save(Mockito.argThat(u -> 
    "test".equals(u.getName())
));
```

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

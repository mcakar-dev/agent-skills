# Blog Post Review Checklist

Detailed review rules organized by priority. Reference this during Phase 2 and Phase 3 analysis.

---

## P1: Security in Code Snippets (CRITICAL)

| Check | Detection | Reader Impact |
|-------|-----------|---------------|
| SQL Injection | String concatenation in queries | Teaches vulnerable patterns to readers |
| XSS | Unescaped user input in responses | Readers copy insecure code |
| Hardcoded Secrets | Passwords, API keys in code | Promotes secret leakage |
| Insecure Deserialization | Untrusted input deserialization | Remote code execution risk |

### SQL Injection example

```java
// BAD — Teaching readers a vulnerability
String query = "SELECT * FROM users WHERE id = " + userId;

// GOOD — Safe parameterized query
@Query("SELECT u FROM User u WHERE u.id = :id")
User findById(@Param("id") Long id);
```

---

## P2: OOP Principles (CRITICAL/MAJOR)

### Encapsulation

| Violation | Detection |
|-----------|-----------|
| Public fields | `public String name;` instead of private + getter |
| Exposed internals | Returning mutable collections directly |
| No validation | Setters without business rule enforcement |

### Inheritance

| Violation | Detection |
|-----------|-----------|
| Deep hierarchies | More than 2 levels of inheritance |
| Inheritance for reuse | Extending a class only for utility methods |
| Fragile base class | Subclass depends on parent implementation details |

### Polymorphism & Abstraction

| Violation | Detection |
|-----------|-----------|
| `instanceof` chains | `if (obj instanceof TypeA)` decision trees |
| Anemic domain model | Entity classes with only getters/setters, no behavior |
| Missing abstraction | Concrete class dependencies in constructors |

---

## P3: SOLID Principles (CRITICAL/MAJOR)

### Single Responsibility Principle (SRP)

| Violation | Detection |
|-----------|-----------|
| God class | Class handling multiple concerns |
| Long methods | Method doing more than one logical task |
| Mixed layers | Controller containing business logic |

### Open/Closed Principle (OCP)

| Violation | Detection |
|-----------|-----------|
| Switch on type | `switch(type)` for behavioral branching |
| Hard-coded conditions | `if/else` chains for extensible behavior |

### Liskov Substitution Principle (LSP)

| Violation | Detection |
|-----------|-----------|
| Throwing in override | `throw new UnsupportedOperationException()` |
| Narrowing contracts | Subclass rejecting valid parent inputs |

### Interface Segregation Principle (ISP)

| Violation | Detection |
|-----------|-----------|
| Fat interface | Interface with too many unrelated methods |
| Empty implementations | `// not needed` in method bodies |

### Dependency Inversion Principle (DIP)

| Violation | Detection | Severity |
|-----------|-----------|----------|
| Concrete dependencies | `new ConcreteService()` in business logic | MAJOR |
| Field injection | `@Autowired` on fields | CRITICAL |
| Missing interface | Depending on implementation, not abstraction | MAJOR |

---

## P4: Clean Code (MAJOR/MINOR)

### Naming

| Rule | Bad | Good |
|------|-----|------|
| Meaningful names | `d`, `temp`, `data` | `elapsedDays`, `userCache` |
| Verb for methods | `user()` | `getUser()`, `createUser()` |
| Boolean prefix | `status` | `isActive`, `hasPermission` |
| Avoid abbreviations | `usrMgr` | `userManager` |

### DRY Violations

| Detection | Fix |
|-----------|-----|
| Duplicate code blocks across snippets | Extract to shared method |
| Copy-paste with minor variations | Parameterize differences |
| Same logic in "bad" and "good" examples | Ensure "good" eliminates duplication |

### Magic Literals

```java
// BAD — Teaching readers to use magic numbers
if (status == 1) { ... }
if (role.equals("ADMIN")) { ... }

// GOOD — Named constants
private static final int STATUS_ACTIVE = 1;
private static final String ROLE_ADMIN = "ADMIN";
```

### Function Size

| Rule | Threshold |
|------|-----------|
| Method too long | More than 20 lines in a snippet context |
| Too many parameters | More than 3 parameters |
| Deep nesting | More than 2 levels of nesting |

---

## P5: Content Accuracy (MAJOR)

### Text-Code Consistency

| Check | Action |
|-------|--------|
| Text describes behavior X | Verify code demonstrates behavior X |
| Text claims pattern Y solves problem | Verify code snippet actually implements pattern Y |
| Text says "output will be Z" | Verify code would produce output Z |

### API Verification

| Check | Action |
|-------|--------|
| Method name referenced | Verify method exists in the stated API/framework |
| Annotation usage | Verify annotation exists and is used correctly |
| Configuration property | Verify property name and format are valid |

### Common AI Hallucinations

| Type | Example |
|------|---------|
| Non-existent annotations | `@AutoValidate`, `@SmartCache` |
| Wrong method signatures | `repository.findByAll()` instead of `repository.findAll()` |
| Mixed framework APIs | Using Spring and Jakarta EE APIs incorrectly |
| Deprecated patterns | `WebSecurityConfigurerAdapter` in Spring Boot 3 |

---

## P6: Spring Boot Specific (CRITICAL/MAJOR)

### Version Compatibility

| Spring Boot 2 (Legacy) | Spring Boot 3+ (Current) |
|------------------------|--------------------------|
| `javax.persistence.*` | `jakarta.persistence.*` |
| `WebSecurityConfigurerAdapter` | `SecurityFilterChain` bean |
| `@SpringBootApplication` + `extends` | Component-based configuration |

### Dependency Injection

```java
// BAD — Field injection
@Autowired
private UserService userService;

// GOOD — Constructor injection with Lombok
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
}
```

### Exception Handling

```java
// BAD — Generic exception, empty catch
try {
    process();
} catch (Exception e) { }

// GOOD — Specific exception with logging
try {
    process();
} catch (DataAccessException e) {
    log.error("Database error: {}", e.getMessage(), e);
    throw new ServiceException("Processing failed", e);
}
```

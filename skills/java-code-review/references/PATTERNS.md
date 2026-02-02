# Common Anti-Patterns and Fixes

Reference for detecting and fixing common Java/Spring anti-patterns.

---

## Architecture Anti-Patterns

### Logic in Controller

**Detection:**
```java
@PostMapping("/users")
public ResponseEntity<User> createUser(@RequestBody UserDto dto) {
    // BAD: Business logic in controller
    if (userRepository.existsByEmail(dto.getEmail())) {
        throw new DuplicateEmailException();
    }
    User user = new User();
    user.setEmail(dto.getEmail());
    user.setPassword(passwordEncoder.encode(dto.getPassword()));
    return ResponseEntity.ok(userRepository.save(user));
}
```

**Architectural Implication:** Violates SRP and makes logic untestable without full web context.

**Fix:**
```java
@PostMapping("/users")
public ResponseEntity<User> createUser(@RequestBody UserDto dto) {
    return ResponseEntity.ok(userService.createUser(dto));
}
```

---

### Mutable DTOs

**Detection:**
```java
@Data
public class UserDto {
    private String email;
    private String password;
}
```

**Architectural Implication:** DTOs crossing layer boundaries can be mutated, causing side effects.

**Fix:**
```java
@Value
@Builder
public class UserDto {
    String email;
    String password;
}
```

---

### Circular Dependencies

**Detection:**
```java
@Service
public class OrderService {
    private final UserService userService;
    // ...
}

@Service
public class UserService {
    private final OrderService orderService; // Circular!
}
```

**Architectural Implication:** Prevents proper bean initialization, indicates poor domain separation.

**Fix:** Extract shared logic to a third service or use events for decoupling.

---

## SOLID Violations

### God Class

**Detection:** Class with 500+ lines or 20+ methods.

**Fix:** Split by responsibility:
- `UserService` → `UserCreationService`, `UserQueryService`, `UserValidationService`

---

### Feature Envy

**Detection:** Method uses more data from another class than its own.

```java
// BAD
public BigDecimal calculateTotal(Order order) {
    return order.getItems().stream()
        .map(i -> i.getPrice().multiply(i.getQuantity()))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}
```

**Fix:** Move method to the class that owns the data.

```java
// In Order class
public BigDecimal calculateTotal() {
    return items.stream()
        .map(Item::getSubtotal)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}
```

---

### Primitive Obsession

**Detection:** Using primitives for domain concepts.

```java
// BAD
public void sendEmail(String email, String subject, String body) { ... }
```

**Fix:** Create value objects.

```java
public void sendEmail(Email email, EmailContent content) { ... }

@Value
public class Email {
    String address;
    
    public Email(String address) {
        if (!isValid(address)) throw new InvalidEmailException();
        this.address = address;
    }
}
```

---

## Performance Anti-Patterns

### N+1 Query in Loop

**Detection:**
```java
List<Order> orders = orderRepository.findAll();
for (Order order : orders) {
    List<Item> items = order.getItems(); // Lazy load per order!
}
```

**Fix:**
```java
@EntityGraph(attributePaths = {"items"})
List<Order> findAllWithItems();
```

---

### Stream Collected Then Streamed

**Detection:**
```java
list.stream()
    .filter(predicate)
    .collect(Collectors.toList())
    .stream() // Unnecessary materialization!
    .map(mapper)
    .collect(Collectors.toList());
```

**Fix:**
```java
list.stream()
    .filter(predicate)
    .map(mapper)
    .collect(Collectors.toList());
```

---

### String Concatenation in Loop

**Detection:**
```java
String result = "";
for (String s : list) {
    result += s; // Creates new String each iteration
}
```

**Fix:**
```java
StringBuilder result = new StringBuilder();
for (String s : list) {
    result.append(s);
}
```

---

## Spring Boot Anti-Patterns

### Repository in Controller

**Detection:** Direct repository access from controller layer.

**Architectural Implication:** Bypasses service layer, no transaction boundary, no business logic encapsulation.

**Fix:** Always inject services, not repositories, into controllers.

---

### Transaction on Wrong Layer

**Detection:** `@Transactional` on controller or repository methods.

**Fix:** Place `@Transactional` on service methods only.

---

### Missing @Transactional(readOnly = true)

**Detection:** Query-only service methods without read-only flag.

**Fix:**
```java
@Transactional(readOnly = true)
public List<User> findAllActive() {
    return userRepository.findByActiveTrue();
}
```

---

## Exception Anti-Patterns

### Swallowing Exceptions

**Detection:**
```java
try {
    riskyOperation();
} catch (Exception e) {
    // Nothing here
}
```

**Architectural Implication:** Silent failures hide bugs, corrupt data state.

**Fix:**
```java
try {
    riskyOperation();
} catch (SpecificException e) {
    log.error("Operation failed: {}", e.getMessage(), e);
    throw new ServiceException("Operation failed", e);
}
```

---

### Catching Throwable

**Detection:** `catch (Throwable t)` or `catch (Error e)`

**Architectural Implication:** Catches JVM errors that should crash the application.

**Fix:** Catch specific exceptions only. Never catch `Error` or `Throwable`.

---

### Exception as Flow Control

**Detection:**
```java
try {
    return Optional.of(repository.findById(id).get());
} catch (NoSuchElementException e) {
    return Optional.empty();
}
```

**Fix:**
```java
return repository.findById(id);
```

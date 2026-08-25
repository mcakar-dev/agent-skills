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

## OOP Violations

### Deep Inheritance / Composition over Inheritance

**Detection:**
```java
class PremiumUserService extends UserService {
    @Override
    public void notify(User user) { /* different channel */ }
}
```

**Architectural Implication:** Couples the subclass to the base class's internals (fragile base class problem) and prevents varying behavior at runtime.

**Fix:** Inject the varying behavior instead of subclassing it.

```java
class UserService {
    private final NotificationStrategy notificationStrategy;
}
```

---

### Law of Demeter Violation (Feature Envy variant)

**Detection:**
```java
String city = order.getCustomer().getAddress().getCity();
```

**Architectural Implication:** Couples the caller to the entire object graph of `Order`; any change to `Customer` or `Address` ripples outward.

**Fix:** Tell, don't ask — expose the data the caller needs directly.

```java
String city = order.getBillingCity();
```

---

### Encapsulation Leak

**Detection:**
```java
public List<Item> getItems() {
    return items;
}
```

**Architectural Implication:** Callers can mutate internal state directly, bypassing invariants and creating thread-safety issues.

**Fix:**
```java
public List<Item> getItems() {
    return List.copyOf(items);
}
```

---

## Over-Engineering (YAGNI / KISS)

### Speculative Generality

**Detection:** An interface with exactly one implementation and no documented plan for a second one.

```java
public interface PaymentStrategy { ... }
public class OnlyPaymentStrategyImpl implements PaymentStrategy { ... }
```

**Architectural Implication:** Adds an abstraction layer that provides no current value and increases cognitive load.

**Fix:** Inline the logic into a single class until a second variant is actually required.

---

### Unnecessary Abstraction

**Detection:** Wrapper-of-wrapper or factory-of-factory for a single code path.

```java
public class UserValidatorFactoryProvider { ... }
```

**Fix:** Collapse to the simplest solution that satisfies current requirements.

```java
public class UserValidator { ... }
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

---

## Testing Anti-Patterns

### Output Reference Sharing (Self-Comparison Pitfall)

**Detection:** The variable stubbed as a mock's return value is the same reference passed to the assertion's expected value.

```java
ResponseDto expectedResponse = ResponseDto.builder().id("1001").build();
Mockito.doReturn(expectedResponse).when(mapper).toDto(Mockito.any());
ResponseDto result = service.process("1001");
Assertions.assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse);
```

**Architectural Implication:** If the SUT mutates the object in place, both variables mutate together and the assertion compares the object with itself, silently passing even though behavior is broken (mutation survivor).

**Fix:** Build two independent instances — one for the stub's return value, one for the assertion's expected value.

---

### Exact Reference Matching in Stubs

**Detection:** A concrete mutable object (rather than `Mockito.any(Type.class)`) is passed as the argument matcher in `when()`/`doReturn().when()`.

```java
Mockito.doReturn(externalDto).when(mapper).toExternal(requestDto);
```

**Architectural Implication:** If `requestDto` is mutated before the call, the stub silently fails to match and returns `null`, surfacing as a confusing downstream `NullPointerException` instead of failing at the real cause. It also couples stub behavior to input validation, which belongs in verification, not stubbing.

**Fix:**
```java
Mockito.doReturn(externalDto).when(mapper).toExternal(Mockito.any(RequestDto.class));
// verify the actual argument separately
ArgumentCaptor<RequestDto> captor = ArgumentCaptor.forClass(RequestDto.class);
Mockito.verify(mapper).toExternal(captor.capture());
Assertions.assertThat(captor.getValue()).usingRecursiveComparison().isEqualTo(requestDto);
```

---

### Partial Field Assertions

**Detection:** Asserting one or two scalar fields on a captured/mapped object with 3+ fields.

```java
Assertions.assertThat(captor.getValue().getEmail()).isEqualTo("user@example.com");
```

**Architectural Implication:** Dropped or unmapped fields (e.g., a removed `firstName` mapping) go undetected because they are never asserted.

**Fix:**
```java
Assertions.assertThat(captor.getValue()).usingRecursiveComparison().isEqualTo(expectedRequest);
```

---

### Redundant `times(1)` / Missing Negative-Flow Verification

**Detection:** `Mockito.verify(mock, Mockito.times(1))` used instead of the default `Mockito.verify(mock)`; or a negative-flow test (validation failure, short-circuit) with no `never()`/`verifyNoInteractions()` assertion.

**Fix:**
```java
Mockito.verify(mock).call(captor.capture());
Mockito.verify(otherMock, Mockito.never()).call(Mockito.any());
Mockito.verifyNoInteractions(unrelatedMock);
```

---

### Shared Mutable Test Fixtures

**Detection:** Mutable fixture fields populated in `@BeforeEach` or as class-level instance variables.

```java
class OrderServiceTest {
    private OrderRequest request;

    @BeforeEach
    void setUp() {
        request = OrderRequest.builder().id("123").build();
    }
}
```

**Architectural Implication:** Mutations from one test can leak into another, making test outcomes order-dependent and non-deterministic.

**Fix:** Generate fresh instances per test via a static factory (e.g., `TestObjectFactory.createOrderRequest()`), with magic literals centralized as `public static final` constants.

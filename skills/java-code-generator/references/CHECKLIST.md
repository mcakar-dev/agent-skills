# Java Code Generation Checklist

## Testing Patterns

### Test class setup

```java
@ExtendWith(MockitoExtension.class)
class MyServiceImplTest {
    
    private static final Long DEFAULT_ID = 1L;
    private static final String DEFAULT_NAME = "test";
    
    @Mock
    private MyRepository repository;
    
    @Mock
    private MyMapper mapper;
    
    @InjectMocks
    private MyServiceImpl service;
}
```

### Test naming: `given_when_then`

| Scenario | Example |
|----------|---------|
| Happy path | `givenValidRequest_whenCreate_thenReturnsResponse` |
| Exception | `givenNullInput_whenCreate_thenThrowsException` |
| Not found | `givenNonExistentId_whenFind_thenThrowsNotFoundException` |
| Edge case | `givenEmptyList_whenProcess_thenReturnsEmpty` |
| Optional empty | `givenNonExistentId_whenFindById_thenReturnsEmpty` |

### Mocking, Immutability & Assertions

| Rule | Pattern |
|------|---------|
| Stubbing | `Mockito.doReturn(value).when(mock).method(Mockito.any(Type.class))` — never a concrete mutable instance |
| Verify single call | `Mockito.verify(mock).method()` — defaults to 1 call; do not append `Mockito.times(1)` |
| Verify negative flow | `Mockito.verify(mock, Mockito.never()).method()` / `Mockito.verifyNoInteractions(mock)` |
| Capture | `ArgumentCaptor.forClass(Type.class)` |
| Object assertions | `Assertions.assertThat(actual).usingRecursiveComparison().isEqualTo(expected)` (not partial field checks) |
| Fixtures | `TestObjectFactory` static factory per test — never mutable `@BeforeEach` fields |

### Immutability (CRITICAL)

> [!CAUTION]
> Never reuse mutable objects between Action and Assertion phases.

```java
// BAD - Reference mutation
User user = new User();
user.setName("test");
service.save(user);
Mockito.verify(repository).save(user); // WRONG

// GOOD - ArgumentCaptor
ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
Mockito.verify(repository).save(captor.capture());
Assertions.assertThat(captor.getValue().getName()).isEqualTo("test");
```

### Output Reference Sharing (CRITICAL)

> [!CAUTION]
> Never let a stubbed return value and its assertion expectation share the same heap reference — if the SUT mutates it in place, both variables mutate together and the assertion passes even though behavior is broken.

```java
// BAD - mockResponse IS expectedResponse (same reference)
UserResponse expectedResponse = new UserResponse(USER_ID, USER_NAME, USER_EMAIL);
Mockito.doReturn(expectedResponse).when(userMapper).toResponse(entity);
UserResponse result = userService.createUser(request);
Assertions.assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse);

// GOOD - independent instances
UserResponse mockResponse = new UserResponse(USER_ID, USER_NAME, USER_EMAIL);
UserResponse expectedResponse = new UserResponse(USER_ID, USER_NAME, USER_EMAIL);
Mockito.doReturn(mockResponse).when(userMapper).toResponse(entity);
UserResponse result = userService.createUser(request);
Assertions.assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse);
```

The same rule applies to stub arguments: pass `Mockito.any(Type.class)` instead of a concrete request object, then verify the actual argument separately with `ArgumentCaptor`. Matching on a concrete reference causes a silent `null` return (masked as a downstream `NullPointerException`) if the SUT mutates the argument before the call.

### Full Object Graph Assertions

Prefer `usingRecursiveComparison()` over asserting one or two scalar fields on DTOs with 3+ fields; partial assertions let dropped/unmapped fields survive mutation testing.

### Test Fixture Isolation

Generate fresh fixtures per test via a static factory (e.g., `TestObjectFactory`), never mutable class fields or `@BeforeEach` state, and centralize magic literals there as `public static final` constants.

> [!NOTE]
> This section is self-contained so `java-code-generator` works standalone. If the **java-unit-test-writer** skill is also installed, it can additionally be invoked for broader delta-coverage test generation on existing/staged code.

---

## MapStruct Patterns

### Basic mapper interface

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    User toEntity(CreateUserRequest request);
    UserResponse toResponse(User entity);
    List<UserResponse> toResponseList(List<User> entities);
}
```

### Mapper with ignores

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    User toEntity(CreateUserRequest request);
    
    UserResponse toResponse(User entity);
}
```

### Update existing entity

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    @Mapping(target = "id", ignore = true)
    void updateEntity(@MappingTarget User entity, UpdateUserRequest request);
}
```

### Mapper with custom mapping

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    @Mapping(target = "fullName", expression = "java(entity.getFirstName() + \" \" + entity.getLastName())")
    UserResponse toResponse(User entity);
}
```

---

## Optional Handling

### Repository Optional

```java
// FORBIDDEN - Direct get()
User user = repository.findById(id).get();

// REQUIRED - orElseThrow
User user = repository.findById(id)
    .orElseThrow(() -> new UserNotFoundException(id));
```

### Service Optional

```java
public UserResponse findById(Long id) {
    return repository.findById(id)
        .map(mapper::toResponse)
        .orElseThrow(() -> new UserNotFoundException(id));
}
```

### Optional in tests

```java
// Mock Optional.empty()
Mockito.doReturn(Optional.empty()).when(repository).findById(Mockito.anyLong());

// Mock Optional.of()
Mockito.doReturn(Optional.of(entity)).when(repository).findById(id);
```

---

## Validation Annotations

### Common annotations

```java
public record CreateUserRequest(
    @NotBlank(message = "Name is required")
    String name,
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    String email,
    
    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must be at most 120")
    Integer age,
    
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    String password,
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number")
    String phoneNumber
) {}
```

### Validation in controller

```java
@PostMapping
public ResponseEntity<UserResponse> createUser(
    @Valid @RequestBody CreateUserRequest request
) {
    UserResponse response = userService.createUser(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(response);
}
```

---

## ResponseEntity Patterns

### HTTP Status codes

| Action | Status | Pattern |
|--------|--------|---------|
| Create | 201 | `ResponseEntity.status(HttpStatus.CREATED).body(response)` |
| Read | 200 | `ResponseEntity.ok(response)` |
| Update | 200 | `ResponseEntity.ok(response)` |
| Delete | 204 | `ResponseEntity.noContent().build()` |

### Full controller example

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> findById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id));
    }
    
    @PostMapping
    public ResponseEntity<UserResponse> create(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.create(request));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> update(
        @PathVariable Long id,
        @Valid @RequestBody UpdateUserRequest request
    ) {
        return ResponseEntity.ok(userService.update(id, request));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## Clean Architecture Rules

### Layer dependencies

```
Controller → Service (Interface) → Repository
     ↓            ↓                    ↓
   DTOs       Entities            Entities
```

| Rule | Allowed |
|------|---------|
| Controller → Service | ✅ Interface only |
| Service → Repository | ✅ |
| Controller → Entity | ❌ FORBIDDEN |
| Service → DTO | ✅ For mapping |

### Package structure

```
com.company.module/
├── controller/
│   └── UserController.java
├── service/
│   ├── UserService.java (Interface)
│   └── impl/
│       └── UserServiceImpl.java
├── repository/
│   └── UserRepository.java
├── dto/
│   ├── request/
│   │   └── CreateUserRequest.java
│   └── response/
│       └── UserResponse.java
├── entity/
│   └── User.java
├── mapper/
│   └── UserMapper.java
└── exception/
    └── UserNotFoundException.java
```

---

## Spring Boot Rules

### Dependency Injection

```java
// FORBIDDEN
@Autowired
private UserService userService;

// REQUIRED
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
}
```

### Exception handling

```java
// FORBIDDEN
try {
    // code
} catch (Exception e) { }

// REQUIRED
try {
    // code
} catch (SpecificException e) {
    log.error("Context: {}", e.getMessage(), e);
    throw new CustomException("message", e);
}
```

### Custom exceptions

```java
public class UserNotFoundException extends RuntimeException {
    private static final String MESSAGE_TEMPLATE = "User not found with id: %s";
    
    public UserNotFoundException(Long id) {
        super(String.format(MESSAGE_TEMPLATE, id));
    }
}
```

---

## SOLID Quick Reference

| Principle | Check |
|-----------|-------|
| **S**RP | One reason to change? Class < 500 lines? |
| **O**CP | Uses interfaces? Strategy pattern for variants? |
| **L**SP | Subtypes fully substitutable? |
| **I**SP | Interface focused? No unused methods? |
| **D**IP | Depends on abstractions? No `new Service()`? |

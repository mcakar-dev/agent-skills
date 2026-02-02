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

### Mocking rules

| Rule | Pattern |
|------|---------|
| Stubbing | `Mockito.doReturn(value).when(mock).method()` |
| Verify | `Mockito.verify(mock, Mockito.times(1)).method()` |
| Never | `Mockito.verify(mock, Mockito.never()).method()` |
| Capture | `ArgumentCaptor.forClass(Type.class)` |
| Any matcher | `Mockito.any(Type.class)` |

### Immutability pattern (CRITICAL)

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

// GOOD - ArgumentMatchers
Mockito.verify(repository).save(Mockito.argThat(u -> 
    "test".equals(u.getName())
));
```

### Assertion patterns

```java
// Equality
Assertions.assertThat(actual).isEqualTo(expected);

// Not null
Assertions.assertThat(result).isNotNull();

// Collections
Assertions.assertThat(list).hasSize(3).contains(item);
Assertions.assertThat(list).isEmpty();

// Exception
Assertions.assertThatThrownBy(() -> service.method(null))
    .isInstanceOf(CustomException.class)
    .hasMessageContaining("expected message");

// Optional
Assertions.assertThat(optional).isPresent();
Assertions.assertThat(optional).isEmpty();
Assertions.assertThat(optional).hasValue(expected);
```

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

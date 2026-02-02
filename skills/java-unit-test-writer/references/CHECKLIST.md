# Test Writing Checklist

Detailed patterns for unit test generation. Reference during Phase 3 and Phase 5.

---

## Immutability Rules (CRITICAL)

> [!CAUTION]
> The most common cause of flaky tests is mutable object reuse between Action and Assertion phases.

### The Problem

```java
// BAD - The actual bug
User user = new User();
user.setName("original");

// ACTION
service.save(user);  // This might modify 'user' internally!

// ASSERTION - Using same reference
Mockito.verify(repository).save(user);  // Compares against modified object
```

### Solution 1: ArgumentCaptor

```java
@Test
void givenValidUser_whenSave_thenPassesCorrectData() {
    // ARRANGE
    String expectedName = "test";
    User user = User.builder().name(expectedName).build();
    
    // ACT
    service.save(user);
    
    // ASSERT - Capture the actual argument
    ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
    Mockito.verify(repository).save(captor.capture());
    
    User captured = captor.getValue();
    Assertions.assertThat(captured.getName()).isEqualTo(expectedName);
}
```

### Solution 2: ArgumentMatchers

```java
@Test
void givenValidUser_whenSave_thenPassesCorrectData() {
    // ARRANGE
    User user = User.builder().name("test").build();
    
    // ACT
    service.save(user);
    
    // ASSERT - Match by properties, not reference
    Mockito.verify(repository).save(Mockito.argThat(u -> 
        "test".equals(u.getName())
    ));
}
```

### Solution 3: Separate Objects

```java
@Test
void givenValidUser_whenSave_thenPassesCorrectData() {
    // ARRANGE - Object for action
    User inputUser = User.builder().name("test").build();
    
    // ARRANGE - Expected values (primitives are immutable)
    String expectedName = "test";
    
    // ACT
    service.save(inputUser);
    
    // ASSERT - Verify using primitives
    ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
    Mockito.verify(repository).save(captor.capture());
    Assertions.assertThat(captor.getValue().getName()).isEqualTo(expectedName);
}
```

---

## Mocking Patterns

### Standard Setup

```java
@ExtendWith(MockitoExtension.class)
class MyServiceTest {
    
    @Mock
    private MyRepository repository;
    
    @Mock
    private ExternalService externalService;
    
    @InjectMocks
    private MyServiceImpl service;
}
```

### Strict Stubbing

MockitoExtension enforces strict stubs by default. Every stub must be used.

```java
// This will FAIL if the stubbed method is never called
Mockito.doReturn(Optional.of(entity)).when(repository).findById(1L);
```

### Verification

| Pattern | Usage |
|---------|-------|
| `Mockito.verify(mock)` | Verify called once |
| `Mockito.verify(mock, Mockito.times(2))` | Verify called N times |
| `Mockito.verify(mock, Mockito.never())` | Verify never called |
| `Mockito.verifyNoMoreInteractions(mock)` | No unexpected calls |

---

## Edge Case Matrix

### Required test cases per method

| Case Type | Description | Example |
|-----------|-------------|---------|
| Happy Path | Valid input → expected output | `givenValidUser_whenSave_thenReturnsId` |
| Exception | Invalid input → specific exception | `givenNullUser_whenSave_thenThrowsIllegalArgument` |
| Null Input | Null parameter handling | `givenNullId_whenFindById_thenThrowsException` |
| Empty Collection | Empty list/set behavior | `givenEmptyList_whenProcess_thenReturnsEmpty` |
| Boundary | Edge values (0, max, empty string) | `givenZeroQuantity_whenCalculate_thenReturnsZero` |
| Not Found | Entity doesn't exist | `givenNonExistentId_whenFind_thenThrowsNotFound` |

---

## Coverage Patterns by Type

### DTOs & Entities

```java
@Test
void givenBuilder_whenBuild_thenAllFieldsPopulated() {
    MyDto dto = MyDto.builder()
        .id(1L)
        .name("test")
        .status(Status.ACTIVE)
        .build();
    
    Assertions.assertThat(dto.getId()).isEqualTo(1L);
    Assertions.assertThat(dto.getName()).isEqualTo("test");
    Assertions.assertThat(dto.getStatus()).isEqualTo(Status.ACTIVE);
}
```

### Services

```java
@Test
void givenValidRequest_whenCreate_thenSavesAndReturnsResponse() {
    // ARRANGE
    CreateRequest request = CreateRequest.builder().name("test").build();
    Entity savedEntity = Entity.builder().id(1L).name("test").build();
    
    ArgumentCaptor<Entity> captor = ArgumentCaptor.forClass(Entity.class);
    Mockito.doReturn(savedEntity)
        .when(repository).save(captor.capture());
    
    // ACT
    CreateResponse response = service.create(request);
    
    // ASSERT
    Assertions.assertThat(response.getId()).isEqualTo(1L);
    
    Mockito.verify(repository).save(captor.capture());
    Assertions.assertThat(captor.getValue().getName()).isEqualTo("test");
}
```

### Exception Handling

```java
@Test
void givenNonExistentId_whenFindById_thenThrowsNotFoundException() {
    // ARRANGE
    Long id = 999L;
    Mockito.doReturn(Optional.empty()).when(repository).findById(id);
    
    // ACT & ASSERT
    Assertions.assertThatThrownBy(() -> service.findById(id))
        .isInstanceOf(NotFoundException.class)
        .hasMessageContaining("not found");
}
```

---

## ReflectionTestUtils

Use `ReflectionTestUtils` from Spring Test to access private fields or methods when necessary.

> [!WARNING]
> Use sparingly. If you need ReflectionTestUtils frequently, consider refactoring the code for better testability.

### Setting Private Fields

```java
@ExtendWith(MockitoExtension.class)
class MyServiceTest {

    @InjectMocks
    private MyServiceImpl service;

    @Test
    void givenConfiguredTimeout_whenProcess_thenRespectsTimeout() {
        // ARRANGE - Set @Value injected field
        ReflectionTestUtils.setField(service, "timeoutMs", 5000L);
        
        // ACT
        Result result = service.process();
        
        // ASSERT
        Assertions.assertThat(result.getTimeout()).isEqualTo(5000L);
    }
}
```

### Common Use Cases

| Scenario | Example |
|----------|---------|
| `@Value` properties | `ReflectionTestUtils.setField(service, "apiUrl", "http://test")` |
| Private dependencies | `ReflectionTestUtils.setField(service, "helper", mockHelper)` |
| Constants override | `ReflectionTestUtils.setField(service, "MAX_RETRIES", 3)` |

### Invoking Private Methods

```java
@Test
void givenValidInput_whenValidatePrivateMethod_thenReturnsTrue() {
    // ARRANGE
    String input = "valid";
    
    // ACT - Invoke private method
    Boolean result = ReflectionTestUtils.invokeMethod(service, "validateInput", input);
    
    // ASSERT
    Assertions.assertThat(result).isTrue();
}
```

### Required Import

```java
import org.springframework.test.util.ReflectionTestUtils;
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| `@Autowired` in tests | Creates Spring context dependency | Use `@InjectMocks` |
| Static imports | Reduces readability | Use `Mockito.doReturn()`, `Assertions.assertThat()` |
| `when().thenReturn()` | May call real method on spies | Use `Mockito.doReturn().when()` |
| Magic strings | Hard to maintain | Extract to constants |
| Mutable object reuse | Flaky tests | Use ArgumentCaptor |
| Multiple assertions per test | Unclear failure reason | One logical assertion per test |
| Testing implementation | Brittle tests | Test behavior, not internals |

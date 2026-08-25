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

## Anti-Pattern: Output Reference Sharing (Self-Comparison Pitfall)

> [!CAUTION]
> Reusing the exact same instance for both a mock's stubbed return value and the assertion's expected value is a distinct bug from Action/Assertion mutation, and just as dangerous.

### The Problem

```java
// BAD - mockResponse and expectedResponse are the same heap reference
ResponseDto expectedResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();

Mockito.doReturn(expectedResponse).when(mapper).toDto(Mockito.any());

ResponseDto result = service.process("1001");

Assertions.assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse);
```

If the SUT mutates the returned object in place before returning it (e.g. `result.setStatus("CORRUPTED")`), both `result` and `expectedResponse` mutate together because they point to the same object. The assertion compares the mutated object with itself and **passes** even though the behavior is broken (mutation survivor / false positive).

### The Solution

```java
// GOOD - two independent heap instances
ResponseDto mockResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();
ResponseDto expectedResponse = ResponseDto.builder().id("1001").status("ACTIVE").build();

Mockito.doReturn(mockResponse).when(mapper).toDto(Mockito.any());

ResponseDto result = service.process("1001");

Assertions.assertThat(result).usingRecursiveComparison().isEqualTo(expectedResponse);
```

---

## Anti-Pattern: Exact Reference Matching in Stubs

> [!CAUTION]
> Passing a concrete mutable object into `when()`/`doReturn().when()` couples stub behavior to input validation, and causes the stub to silently not match (returning `null`) if the SUT mutates the argument before the call.

### The Problem

```java
// BAD - stub only matches this exact reference/state
RequestDto requestDto = RequestDto.builder().code("ABC").build();
ExternalDto externalDto = ExternalDto.builder().code("ABC").build();

Mockito.doReturn(externalDto).when(mapper).toExternal(requestDto);
Mockito.doReturn(clientResponse).when(client).call(externalDto);
```

If `requestDto` is mutated prior to the call, the stub does not match, Mockito returns `null`, and the test fails downstream with a confusing `NullPointerException` instead of at the real point of failure.

### The Solution: `any()` in Stubs + `ArgumentCaptor` in Verification

```java
// GOOD - permissive stubbing, explicit argument capturing
Mockito.doReturn(externalDto).when(mapper).toExternal(Mockito.any(RequestDto.class));
Mockito.doReturn(clientResponse).when(client).call(Mockito.any(ExternalDto.class));

service.process(requestDto);

ArgumentCaptor<ExternalDto> captor = ArgumentCaptor.forClass(ExternalDto.class);
Mockito.verify(client).call(captor.capture());

Assertions.assertThat(captor.getValue()).usingRecursiveComparison().isEqualTo(externalDto);
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
| `Mockito.verify(mock)` | Verify called exactly once (default mode; do NOT add `Mockito.times(1)`, it is redundant boilerplate) |
| `Mockito.verify(mock, Mockito.times(2))` | Verify called N times (only specify mode when N != 1) |
| `Mockito.verify(mock, Mockito.never())` | Verify a specific method never called (negative-flow / validation-failure tests) |
| `Mockito.verifyNoInteractions(mock)` | Verify no calls whatsoever were made to the dependency |
| `Mockito.verifyNoMoreInteractions(mock)` | No unexpected calls beyond those already verified |

Always add `never()` or `verifyNoInteractions()` assertions when testing negative branches (validation failures, short-circuit evaluations) to prove unintended side effects did not happen.

---

## Full Object Graph Assertions

Use `usingRecursiveComparison()` when asserting on DTOs or captured arguments with 3+ fields. Asserting only one or two scalar fields lets dropped/unmapped fields survive mutation testing.

```java
// BAD - only 1 out of 6 fields verified
ArgumentCaptor<UserRegistrationRequest> captor = ArgumentCaptor.forClass(UserRegistrationRequest.class);
Mockito.verify(userClient).register(captor.capture());
Assertions.assertThat(captor.getValue().getEmail()).isEqualTo("user@example.com");

// GOOD - full field graph comparison against an expected template object
Assertions.assertThat(captor.getValue())
    .usingRecursiveComparison()
    .isEqualTo(expectedRegistrationRequest);
```

---

## Test Fixture Isolation

Do not define mutable fixtures as class-level fields populated in `@BeforeEach`; mutations from one test can leak into others and make execution order-dependent.

```java
// BAD - shared mutable instance across all tests
class OrderServiceTest {
    private OrderRequest request;

    @BeforeEach
    void setUp() {
        request = OrderRequest.builder().id("123").build();
    }
}

// GOOD - factory-generated isolated instance per test
@Test
void givenValidOrder_whenSubmit_thenSuccess() {
    OrderRequest request = TestObjectFactory.createOrderRequest();
    // ...
}
```

Centralize magic literals used across fixtures as `public static final` constants in the factory class (e.g., `TestObjectFactory.STATUS_PENDING_PAYMENT`) instead of inlining raw strings/numbers in each test.

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

> [!TIP]
> Use cyclomatic complexity as a sizing signal: a method with N independent branches needs at least N dedicated test cases to reach 100% delta coverage (see **java-code-reviewer** P2 SRP checklist for the complexity threshold).

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
| Magic strings | Hard to maintain | Extract to constants / `TestObjectFactory` |
| Mutable object reuse (Action/Assertion) | Flaky tests | Use ArgumentCaptor |
| Mock return value == assertion expectation | Self-comparison false positive | Build two distinct instances |
| Concrete instance in stub matcher | Silent `null` return, masked `NullPointerException` | Use `Mockito.any(Type.class)` + `ArgumentCaptor` for verification |
| Partial field assertions | Dropped fields survive mutation testing | Use `usingRecursiveComparison()` |
| `Mockito.verify(mock, Mockito.times(1))` | Redundant boilerplate | `Mockito.verify(mock)` (default is 1 call) |
| Missing negative-flow verification | Unintended side effects go unnoticed | `Mockito.verify(mock, Mockito.never())` / `verifyNoInteractions(mock)` |
| Shared mutable `@BeforeEach` fixture | Order-dependent, leaking state | Static factory method per test |
| Multiple assertions per test | Unclear failure reason | One logical assertion per test |
| Testing implementation | Brittle tests | Test behavior, not internals |

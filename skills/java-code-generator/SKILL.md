---
name: java-code-generator
description: Generates production-ready Java code following TDD and Clean Architecture principles. Use when the user requests feature implementation, code generation, or mentions TDD workflow for Spring Boot projects.
---

# Java Code Generation

## When to use this skill

Activate when the user wants to:
- Implement a new feature following TDD methodology
- Generate Java code from a Technical Design Document
- Create REST API endpoints with Service/Repository layers
- Scaffold Clean Architecture components (Controller, Service, Repository, DTOs)

## Workflow

Copy this checklist and track progress:
```
Code Generation Progress:
- [ ] Phase 0: Input & Context
- [ ] Phase 1: Blueprint & Plan
- [ ] Phase 2: TDD Cycle (Red → Green → Refactor)
- [ ] Phase 3: Integration & Wiring
- [ ] Phase 4: Verification Loop
- [ ] Phase 5: Self-Review
- [ ] Phase 6: Handoff
```

---

## Phase 0: Input & Context

> **`<workspace_root>`**: VS Code workspace root folder if available; otherwise the active git repository root (`git rev-parse --show-toplevel`).

### Gather requirements

1. **Ask for Issue Key:**
   > "Which Jira Issue Key are we implementing?"

2. **Check for Technical Design Document:**
   ```bash
   find <workspace_root>/ai -name "doc_*_ENG.md" 2>/dev/null | head -5
   ```

3. **Decision tree:**
   - **IF Issue Key provided:**
     - **IF document exists** at `<workspace_root>/ai/<ISSUE_KEY>/document/doc_<ISSUE_KEY>_ENG.md`: Analyze requirements from document.
     - **IF no document:** Analyze user prompt for requirements.
   - **IF no Issue Key:** Analyze user prompt for requirements.

> [!CAUTION]
> **IF requirements are UNCLEAR → STOP. Ask clarifying questions. Do NOT assume or guess. Do NOT proceed until all ambiguities are resolved.**

### Analyze existing codebase

```bash
# Find existing patterns
find <workspace_root>/src -name "*Controller.java" | head -3
find <workspace_root>/src -name "*Service.java" | head -3
find <workspace_root>/src -name "*Repository.java" | head -3
```

Analyze to understand:
- Package structure conventions
- Naming patterns
- Existing validation approach (Jakarta vs Javax)
- Exception handling patterns
- DTO/Entity patterns
- Mapper approach (MapStruct, manual, ModelMapper)

> [!IMPORTANT]
> * **Adapt to existing project patterns.** Do not introduce new conventions unless explicitly requested.
> * **Do not violate clean code principles.**
> * **Do not violate SOLID principles.**
> * **Do not violate TDD principles.**
> * **Do not violate DRY principles.**
> * **Do not violate KISS principles.**
> * **Do not violate YAGNI principles.**

---

## Phase 1: Blueprint & Plan

### Architectural analysis

Identify required components:

| Layer | Component | Purpose |
|-------|-----------|---------|
| Controller | `*Controller.java` | REST endpoints, request validation |
| Service | `*Service.java` (Interface) | Business logic abstraction |
| Service | `*ServiceImpl.java` | Business logic implementation |
| Repository | `*Repository.java` | Data access layer |
| DTO | `*Request.java`, `*Response.java` | API contracts (Records) |
| Entity | `*Entity.java` | Database model |
| Mapper | `*Mapper.java` | Entity ↔ DTO conversion |
| Exception | `*NotFoundException.java` | Custom domain exceptions |

### Layer isolation check

> [!CAUTION]
> **Entities MUST NOT leak to Controller layer.** DTOs are mandatory for API boundaries.

### Propose file structure

Before proceeding, output:
```
I plan to create:
1. `UserRequest.java` (Record with validation)
2. `UserResponse.java` (Record)
3. `UserService.java` (Interface)
4. `UserServiceImpl.java`
5. `UserRepository.java`
6. `UserMapper.java`
7. `UserController.java`

Proceed?
```

**Wait for user confirmation before Phase 2.**

---

## Phase 2: TDD Cycle

> [!IMPORTANT]
> **Do NOT generate implementation until tests are defined.**

### Step A: Skeleton Creation

Create contracts without implementation:

**DTOs (Use Java Records):**
```java
public record CreateUserRequest(
    @NotBlank String name,
    @Email String email
) {}

public record UserResponse(
    Long id,
    String name,
    String email
) {}
```

**Service Interface:**
```java
public interface UserService {
    UserResponse createUser(CreateUserRequest request);
}
```

**Controller (501 Placeholder):**
```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        throw new UnsupportedOperationException("Not implemented");
    }
}
```

**MapStruct Mapper:**
```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    User toEntity(CreateUserRequest request);
    UserResponse toResponse(User entity);
}
```

### Step B: Red Phase (Write Failing Tests)

See [references/CHECKLIST.md](references/CHECKLIST.md) for testing patterns.

**Test structure:**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {
    
    private static final Long USER_ID = 1L;
    private static final String USER_NAME = "John Doe";
    private static final String USER_EMAIL = "john@example.com";
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private UserMapper userMapper;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    void givenValidRequest_whenCreateUser_thenReturnsResponse() {
        // Arrange
        CreateUserRequest request = new CreateUserRequest(USER_NAME, USER_EMAIL);
        User entity = User.builder().id(USER_ID).name(USER_NAME).email(USER_EMAIL).build();
        UserResponse expectedResponse = new UserResponse(USER_ID, USER_NAME, USER_EMAIL);
        
        Mockito.doReturn(entity).when(userMapper).toEntity(request);
        Mockito.doReturn(entity).when(userRepository).save(Mockito.any(User.class));
        Mockito.doReturn(expectedResponse).when(userMapper).toResponse(entity);
        
        // Act
        UserResponse result = userService.createUser(request);
        
        // Assert
        Assertions.assertThat(result).isNotNull();
        Assertions.assertThat(result.id()).isEqualTo(USER_ID);
        
        Mockito.verify(userRepository, Mockito.times(1)).save(Mockito.any(User.class));
    }
}
```

**Run tests - they MUST fail:**
```bash
mvn test -Dtest=*Test
```

### Step C: Green Phase (Implementation)

Write minimal code to pass tests:

**Entity with JPA annotations:**
```java
@Entity
@Table(name = "users")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
}
```

**Service Implementation:**
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    @Override
    public UserResponse createUser(CreateUserRequest request) {
        User entity = userMapper.toEntity(request);
        User saved = userRepository.save(entity);
        return userMapper.toResponse(saved);
    }
}
```

**Custom Exception:**
```java
public class UserNotFoundException extends RuntimeException {
    
    private static final String MESSAGE_TEMPLATE = "User not found with id: %s";
    
    public UserNotFoundException(Long id) {
        super(String.format(MESSAGE_TEMPLATE, id));
    }
}
```

### Step D: Refactor

Apply code review protocols. See [references/CODING_RULES.md](references/CODING_RULES.md).

| Check | Action |
|-------|--------|
| Magic strings | Extract to `private static final` constants |
| Method > 20 lines | Extract private methods |
| Duplicate logic | Extract to utility class |
| Missing logging | Add SLF4J error logging |
| Empty strings | Use `StringUtils.EMPTY` |
| Blank checks | Use `StringUtils.isBlank()` |

---

## Phase 3: Integration & Wiring

### Repository layer

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

**Performance check:**
- Custom queries MUST use proper indexes
- Avoid N+1 query patterns

### Controller wiring

Connect Controller to Service:
```java
@PostMapping
public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
    UserResponse response = userService.createUser(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(response);
}
```

**HTTP Status codes:**

| Action | Status |
|--------|--------|
| Create | 201 Created |
| Read | 200 OK |
| Update | 200 OK |
| Delete | 204 No Content |
| Not Found | 404 Not Found |
| Validation Error | 400 Bad Request |

---

## Phase 4: Verification Loop

**MAX_RETRIES = 3**

### Step 1: Run tests

```bash
mvn clean verify -pl <module>
```

### Step 2: Check build

```bash
mvn compile -pl <module>
```

**Decision tree:**

| Condition | Action |
|-----------|--------|
| Build fails | Fix compilation errors |
| Tests fail | Debug and fix implementation |
| All pass | Proceed to Phase 5 |
| Retries > 3 | HALT. Report blocking issue to user. |

### Step 3: Coverage check (if available)

```bash
mvn verify -pl <module>
# Check target/site/jacoco/index.html
```

---

## Phase 5: Self-Review

Apply `Rules for Agent` to all generated code. See [references/CODING_RULES.md](references/CODING_RULES.md).

### Checklist

| Rule | Check |
|------|-------|
| Constructor Injection | No `@Autowired` on fields |
| Static imports | None in production code |
| Exception handling | No generic `Exception` catch |
| Empty catch blocks | None allowed |
| Magic literals | Extracted to constants |
| DRY | No duplicate logic |
| Lombok | Using `@RequiredArgsConstructor` |
| Empty strings | Using `StringUtils.EMPTY` |
| Blank checks | Using `StringUtils.isBlank()` |
| Mapper wiring | MapStruct with `componentModel = "spring"` |

### SOLID verification

| Principle | Check |
|-----------|-------|
| SRP | Classes < 500 lines, single responsibility |
| OCP | Using interfaces for extensibility |
| LSP | Subtypes fully substitutable |
| ISP | Interfaces are focused |
| DIP | Depending on abstractions |

---

## Phase 6: Handoff

Output summary:

```
✅ Feature Implementation Complete

Issue Key: [ISSUE_KEY]

Components Created:
- [List files]

TDD Cycle:
- Tests written: [count]
- Tests passing: [count]
- Coverage: [X]% on new lines

Build Status: ✅ Passing

Ready for manual review.
```

---

## Critical constraints

> [!CAUTION]
> **Never make HTTP requests to endpoints for testing.** Only use unit tests unless user grants explicit permission.

| Constraint | Rule |
|------------|------|
| Build | Must NEVER fail |
| Endpoint calls | FORBIDDEN unless user permits |
| Unclear requirements | STOP and ask questions |
| Entity leak | Entities MUST NOT reach Controller |
| Generic exceptions | Use custom exceptions only |
| Static imports | FORBIDDEN in production code |

---

## Tone & Style

- **Strict Architect.** No quick fixes. Production-ready only.
- **Architecture First.** Evaluate impact before coding.
- **TDD Discipline.** Tests before implementation.
- **Clarify First.** Ask questions when requirements are unclear.
- Follow `Rules for Agent` (Strict Architect Persona).

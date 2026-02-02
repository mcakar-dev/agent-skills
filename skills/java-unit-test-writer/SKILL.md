---
name: java-unit-test-writer
description: Generates unit tests for Java code following TDD practices with 100% delta coverage. Use when the user asks for tests, mentions coverage, works with test files, or requests test generation for staged changes.
---

# Java Unit Test Writing

## When to use this skill

Activate when the user wants to:
- Generate unit tests for modified code
- Achieve 100% coverage on new/changed lines
- Create tests following `given_when_then` naming
- Write tests with proper mocking and immutability

## Workflow

Copy this checklist and track progress:
```
Unit Test Progress:
- [ ] Phase 0: Check Input
- [ ] Phase 1: Scope Analysis
- [ ] Phase 2: Pre-Flight Check
- [ ] Phase 3: Test Generation
- [ ] Phase 4: Validation Loop
- [ ] Phase 5: Self-Review
- [ ] Phase 6: Output
```

---

## Phase 0: Check Input

1. Check if the user provided specific file(s) or class(es) to test.
2. **IF specific input provided:** Skip Phase 1, proceed to Phase 2.
3. **IF no input:** Proceed to Phase 1.

---

## Phase 1: Scope Analysis

### Fetch changes

```bash
git status
git diff --staged --name-only
```

**Decision tree:**
- **IF no changes:** STOP. Ask: `"No staged/unstaged changes found. Please specify the class or method to test."`
- **IF changes found:** Proceed.

### Retrieve diff

```bash
git diff --staged
```

### Analyze impact

For each modified file:
1. Identify modified methods
2. List dependencies requiring mocks (Services, Repositories)
3. Note return types and exception paths

### Exclusion filters

Ignore these patterns:
- `target/`, `build/`, `.gradle/`
- `*Test.java`, `*IT.java` (existing tests)
- `*.generated.java`, `*_.java` (MapStruct)
- Configuration classes, DTOs with only getters/setters

---

## Phase 2: Pre-Flight Check

### Run existing tests

```bash
# Maven
mvn test -pl <module> -Dtest=*Test

# Gradle
./gradlew test --tests "*Test"
```

**Decision tree:**
- **IF tests pass:** Proceed to Phase 3.
- **IF tests fail due to new changes:** FIX REGRESSIONS FIRST.
- **Constraint:** Do not refactor existing tests unless legitimately broken.

---

## Phase 3: Test Generation

For every modified class, apply the appropriate strategy.

### A. DTOs & Entities

**Strategy:** Verify `@Builder`, getters, setters, `equals/hashCode`.

```java
@Test
void givenBuilder_whenBuildEntity_thenAllFieldsSet() {
    MyEntity entity = MyEntity.builder()
        .id(1L)
        .name("test")
        .build();
    
    Assertions.assertThat(entity.getId()).isEqualTo(1L);
    Assertions.assertThat(entity.getName()).isEqualTo("test");
}
```

### B. Services & Components

**Setup:**
```java
@ExtendWith(MockitoExtension.class)
class MyServiceTest {
    @Mock
    private MyRepository repository;
    
    @InjectMocks
    private MyServiceImpl service;
}
```

**Test cases required:**

| Case | Description |
|------|-------------|
| Happy Path | Valid input, expected output |
| Exception Handling | Verify exception types and messages |
| Null Inputs | If not validated by annotations |
| Edge Cases | Boundary values, empty collections |

### C. Mocking Rules

See [references/CHECKLIST.md](references/CHECKLIST.md) for detailed patterns.

| Rule | Implementation |
|------|----------------|
| Strict stubs | `@ExtendWith(MockitoExtension.class)` |
| Stubbing | `Mockito.doReturn().when()` (avoids real method call) |
| Verify calls | `Mockito.verify(mock, Mockito.times(1))` |
| No static imports | Use `Mockito.doReturn()`, `Assertions.assertThat()` |

### D. Immutability (CRITICAL)

> [!CAUTION]
> **Never reuse mutable objects between Action and Assertion phases.**

```java
// BAD - Reference mutation bug
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

---

## Phase 4: Validation Loop

**MAX_RETRIES = 10**

Repeat this cycle:

### Step 1: Run tests with coverage

```bash
# Maven
mvn clean verify -pl <module>

# Gradle
./gradlew test jacocoTestReport
```

### Step 2: Check delta coverage

```bash
# Generate diff
git diff origin/master > target/site/jacoco/diff.patch

# Run diff-cover
diff-cover target/site/jacoco/jacoco.xml \
    --compare-branch origin/master \
    --diff-file target/site/jacoco/diff.patch
```

**Decision tree:**

| Condition | Action |
|-----------|--------|
| Coverage == 100% | Proceed to Phase 5 |
| Coverage < 100% | Read missing lines, generate targeted tests |
| diff-cover unavailable | Use JaCoCo HTML report manually |
| Retries > 10 | HALT. Report: `"Unable to achieve 100% delta coverage. Manual intervention required for: [uncovered lines]"` |

### Step 3: Analyze uncovered lines

For each missing line:
1. Identify the branch or path not covered
2. Create specific test case for that path
3. Re-run validation

---

## Phase 5: Self-Review

Apply code review protocols to generated tests.

### Checklist

| Check | Fix |
|-------|-----|
| Magic strings/numbers | Extract to `private static final` constants |
| `@Autowired` usage | Replace with `@InjectMocks` |
| Static imports | Remove, use class names |
| `StringUtils.EMPTY` | Use for empty string literals |
| Mutable object reuse | Apply ArgumentCaptor pattern |

### Review against global rules

Follow `Rules for Agent` (Strict Architect Persona):
- DRY: No duplicate test setup
- Naming: `given_when_then` format
- Assertions: Use AssertJ fluent API

---

## Phase 6: Output

### Success output

```
✅ Test Generation Complete

Coverage: 100% on new/modified lines
Tests Generated: [count]
Files:
  - [TestClass1.java]
  - [TestClass2.java]

diff-cover Summary:
[paste summary]
```

### Failure output

```
⚠️ Test Generation Incomplete

Coverage: [X]%
Uncovered Lines:
  - [File.java:L45] - [reason]
  - [File.java:L78] - [reason]

Manual intervention required.
```

---

## Quick reference

### Commands

| Action | Maven | Gradle |
|--------|-------|--------|
| Run tests | `mvn test` | `./gradlew test` |
| Coverage report | `mvn verify` | `./gradlew jacocoTestReport` |
| Specific test | `mvn test -Dtest=MyTest` | `./gradlew test --tests MyTest` |

### Test naming

| Pattern | Example |
|---------|---------|
| Happy path | `givenValidUser_whenSave_thenReturnsId` |
| Exception | `givenNullInput_whenSave_thenThrowsException` |
| Edge case | `givenEmptyList_whenProcess_thenReturnsEmpty` |

### Assertion patterns

```java
// Equality
Assertions.assertThat(actual).isEqualTo(expected);

// Null checks
Assertions.assertThat(result).isNotNull();

// Collections
Assertions.assertThat(list).hasSize(3).contains(item);

// Exceptions
Assertions.assertThatThrownBy(() -> service.method(null))
    .isInstanceOf(IllegalArgumentException.class)
    .hasMessageContaining("must not be null");
```

---

## Tone & Style

- **Strict TDD.** Every public method needs tests.
- **100% delta coverage.** No exceptions without documented justification.
- **Immutability first.** ArgumentCaptor over mutable references.
- Follow `Rules for Agent` (Strict Architect Persona).

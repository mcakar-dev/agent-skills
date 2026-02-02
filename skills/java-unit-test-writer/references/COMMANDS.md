# Test Commands Reference

Quick reference for test execution and coverage analysis.

---

## Maven Commands

### Run tests

```bash
# All tests
mvn test

# Specific module
mvn test -pl <module-name>

# Specific test class
mvn test -Dtest=MyServiceTest

# Specific test method
mvn test -Dtest=MyServiceTest#givenValidUser_whenSave_thenReturnsId

# Skip tests
mvn install -DskipTests
```

### Generate coverage

```bash
# Run tests with JaCoCo
mvn clean verify

# JaCoCo report location
target/site/jacoco/jacoco.xml
target/site/jacoco/index.html
```

---

## Gradle Commands

### Run tests

```bash
# All tests
./gradlew test

# Specific test class
./gradlew test --tests MyServiceTest

# Specific test method
./gradlew test --tests "MyServiceTest.givenValidUser*"

# With info output
./gradlew test --info
```

### Generate coverage

```bash
# Run tests with JaCoCo
./gradlew test jacocoTestReport

# JaCoCo report location
build/reports/jacoco/test/jacocoTestReport.xml
build/reports/jacoco/test/html/index.html
```

---

## diff-cover Commands

### Installation

```bash
pip install diff-cover
```

### Usage

```bash
# Generate diff file
git diff origin/master > diff.patch

# Run diff-cover (Maven)
diff-cover target/site/jacoco/jacoco.xml \
    --compare-branch origin/master \
    --diff-file diff.patch

# Run diff-cover (Gradle)
diff-cover build/reports/jacoco/test/jacocoTestReport.xml \
    --compare-branch origin/master \
    --diff-file diff.patch

# With HTML output
diff-cover jacoco.xml --html-report coverage-diff.html
```

### Output interpretation

```
Diff Coverage
-------------
src/main/java/MyService.java (100%): Missing lines none
src/main/java/MyController.java (75%): Missing lines 45, 78-82

Total: 85% (17/20 lines)
```

---

## JaCoCo Configuration

### Maven (pom.xml)

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>verify</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Gradle (build.gradle)

```groovy
plugins {
    id 'jacoco'
}

jacocoTestReport {
    reports {
        xml.required = true
        html.required = true
    }
}

test {
    finalizedBy jacocoTestReport
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No coverage report | Ensure JaCoCo plugin is configured |
| diff-cover not found | `pip install diff-cover` |
| Missing lines in report | Run `mvn clean verify` (not just `test`) |
| Gradle XML not generated | Add `xml.required = true` to config |

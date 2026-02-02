# Test Class Template

Standard structure for generated test classes.

---

## Basic Template

```java
package com.example.service;

import java.util.Optional;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class MyServiceTest {

    private static final Long VALID_ID = 1L;
    private static final String VALID_NAME = "test";

    @Mock
    private MyRepository repository;

    @InjectMocks
    private MyServiceImpl service;

    @Test
    void givenValidRequest_whenCreate_thenSavesAndReturnsResponse() {
        // ARRANGE
        CreateRequest request = buildValidRequest();
        Entity savedEntity = buildEntity(VALID_ID, VALID_NAME);
        
        ArgumentCaptor<Entity> captor = ArgumentCaptor.forClass(Entity.class);
        Mockito.doReturn(savedEntity)
            .when(repository).save(captor.capture());

        // ACT
        CreateResponse response = service.create(request);

        // ASSERT
        Assertions.assertThat(response).isNotNull();
        Assertions.assertThat(response.getId()).isEqualTo(VALID_ID);

        Mockito.verify(repository).save(captor.capture());
        Assertions.assertThat(captor.getValue().getName()).isEqualTo(VALID_NAME);
    }

    @Test
    void givenNullRequest_whenCreate_thenThrowsException() {
        // ACT & ASSERT
        Assertions.assertThatThrownBy(() -> service.create(null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("must not be null");
    }

    @Test
    void givenExistingId_whenFindById_thenReturnsEntity() {
        // ARRANGE
        Entity entity = buildEntity(VALID_ID, VALID_NAME);
        Mockito.doReturn(Optional.of(entity))
            .when(repository).findById(VALID_ID);

        // ACT
        EntityResponse response = service.findById(VALID_ID);

        // ASSERT
        Assertions.assertThat(response).isNotNull();
        Assertions.assertThat(response.getId()).isEqualTo(VALID_ID);
    }

    @Test
    void givenNonExistentId_whenFindById_thenThrowsNotFoundException() {
        // ARRANGE
        Long nonExistentId = 999L;
        Mockito.doReturn(Optional.empty())
            .when(repository).findById(nonExistentId);

        // ACT & ASSERT
        Assertions.assertThatThrownBy(() -> service.findById(nonExistentId))
            .isInstanceOf(NotFoundException.class)
            .hasMessageContaining("not found");
    }

    private CreateRequest buildValidRequest() {
        return CreateRequest.builder()
            .name(VALID_NAME)
            .build();
    }

    private Entity buildEntity(Long id, String name) {
        return Entity.builder()
            .id(id)
            .name(name)
            .build();
    }
}
```

---

## Naming Convention

| Scenario | Pattern |
|----------|---------|
| Happy path | `givenValidInput_whenAction_thenExpectedResult` |
| Exception | `givenInvalidInput_whenAction_thenThrowsException` |
| Edge case | `givenEdgeCondition_whenAction_thenHandledCorrectly` |
| Not found | `givenNonExistent_whenAction_thenThrowsNotFound` |

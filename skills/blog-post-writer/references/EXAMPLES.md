# Example Snippets

Reusable examples for different article sections.

---

## Hook Analogies by Topic

### Design Patterns

**Builder Pattern:**
> Ordering a custom sandwich is a step-by-step process. You don't tell the sandwich artist everything at once. Instead, you say: "I'll start with wheat bread... add turkey... provolone cheese..."

**Factory Method:**
> Imagine you're ordering coffee at a franchise. You don't care which barista makes it or what machine they use. You just want your latte.

**Singleton:**
> Think of a CEO. A company can only have one, and everyone in the organization refers to and defers to that same person.

**Adapter:**
> You've just arrived in a foreign country with your laptop charger. The plug doesn't fit the outlets. You need an adapter.

### Database Topics

**Indexing:**
> Imagine you walk into a gigantic library looking for a specific book. In a chaotic library, the books are thrown onto shelves in random order. To find your book, you have to walk every aisle.

**Query Optimization:**
> Think of a GPS. It doesn't just pick a random route—it calculates traffic, distance, and road conditions to find the fastest path.

### Cloud/AWS Topics

**Lambda Cold Starts:**
> Imagine you're running a food truck. Some days you're parked and ready; other days you have to drive across town and set up before the first customer arrives.

**Serverless:**
> Think of a taxi service. You don't own the car, hire the driver, or pay for gas when you're not using it. You just pay for the ride.

---

## Bad Code Examples

### Telescoping Constructor
```java
// BAD: Telescoping constructors are confusing and error-prone
public House(int walls, int doors) {
    this(walls, doors, 0, null, false, false);
}
public House(int walls, int doors, int windows) {
    this(walls, doors, windows, null, false, false);
}
public House(int walls, int doors, int windows, String roofType) {
    this(walls, doors, windows, roofType, false, false);
}
// What does new House(4, 2, 8, "Tiles", false, true) mean?
```

### God Class Factory
```java
// BAD: Giant if-else chain violates OCP
public Payment createPayment(String type) {
    if ("CREDIT".equals(type)) {
        return new CreditCardPayment();
    } else if ("DEBIT".equals(type)) {
        return new DebitCardPayment();
    } else if ("PAYPAL".equals(type)) {
        return new PayPalPayment();
    }
    // Adding new payment type requires modifying this class
    throw new IllegalArgumentException("Unknown type");
}
```

### N+1 Query Problem
```java
// BAD: N+1 queries - one query for users, N queries for orders
List<User> users = userRepository.findAll();
for (User user : users) {
    List<Order> orders = orderRepository.findByUserId(user.getId());
    // This fires a query for EACH user!
}
```

---

## Good Code Examples

### Builder Pattern
```java
// GOOD: Fluent, readable, self-documenting
House luxuryHouse = House.builder()
    .walls(8)
    .doors(6)
    .windows(10)
    .roofType("Tiles")
    .hasGarage(true)
    .hasPool(true)
    .build();
```

### Factory with Strategy
```java
// GOOD: Open for extension, closed for modification
@Configuration
public class PaymentConfig {
    
    @Bean
    @ConditionalOnProperty(name = "payment.provider", havingValue = "stripe")
    public PaymentProcessor stripeProcessor() {
        return new StripePaymentProcessor();
    }
    
    @Bean
    @ConditionalOnProperty(name = "payment.provider", havingValue = "paypal")
    public PaymentProcessor paypalProcessor() {
        return new PayPalPaymentProcessor();
    }
}
```

### Eager Fetch
```java
// GOOD: Single query with JOIN FETCH
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.status = :status")
List<User> findActiveUsersWithOrders(@Param("status") Status status);
```

---

## Framework Context Sections

### Spring Boot Context
```markdown
## **Spring Boot Context**

In **Spring Boot**, you rarely hand-roll a [pattern]. The IoC container already acts as one.

```java
@Configuration
public class AppConfig {
    
    @Bean
    @ConditionalOnProperty(name = "feature.enabled", havingValue = "true")
    public FeatureService featureService() {
        return new FeatureServiceImpl();
    }
}
```

Here, Spring decides which bean to create, based on properties.
```

### AWS/Serverless Context
```markdown
## **AWS Context**

In a **serverless** environment, [concept] works differently because [reason].

```yaml
# serverless.yml
functions:
  handler:
    handler: src/handler.main
    events:
      - http:
          path: /api/resource
          method: get
```
```

### Database Context
```markdown
## **Query Optimization Context**

When using an ORM like **Hibernate**, [concept] translates to:

```java
@Entity
@Table(indexes = {
    @Index(name = "idx_status_date", columnList = "status, created_at")
})
public class Order {
    // ...
}
```
```

---

## Advantages & Disadvantages Template

```markdown
## **X. Advantages & Disadvantages**

**Advantages**
- **[Benefit 1]** → [One-line explanation]
- **[Benefit 2]** → [One-line explanation]
- **[Benefit 3]** → [One-line explanation]

**Disadvantages**
- **[Drawback 1]** → [One-line explanation]
- **[Drawback 2]** → [One-line explanation]
```

---

## GitHub Link Format

```markdown
## **GitHub Example**

You can find the complete, working code example in my public GitHub repository. Feel free to clone it and experiment with the code.

- GitHub Repository: [mcakar-dev/[repo-name]](https://github.com/mcakar-dev/[repo-name])
- Specific Example: [mcakar-dev/[repo-name] - [Topic]](https://github.com/mcakar-dev/[repo-name]/tree/main/[path])
```

# Writing Style Guide

Tone and formatting rules for technical blog posts.

---

## Tone Rules

| Rule | Correct | Incorrect |
|------|---------|-----------|
| Use "You" and "We" | "You'll learn..." | "One will learn..." |
| Conversational authority | "Let's break it down." | "This shall be explained." |
| Avoid academic jargon | "messy code" | "suboptimal implementation" |
| Direct and concise | "The Builder Pattern fixes this." | "It could be said that..." |

### Voice Examples

**Good:**
> Imagine you walk into a gigantic library looking for a specific book.

**Bad:**
> Consider the scenario in which an individual enters a library establishment.

---

## Formatting Rules

### Section Headers

Use numbered sections with bold:
```markdown
## **1. The Hook and Introduction**
## **2. Pattern Overview**
## **3. Code Example in Java**
```

### Definitions and Notes

Use blockquotes with `prompt-info` tag:
```markdown
> The Gang of Four define the Factory Method as...
{: .prompt-info }
```

### Section Separators

Use horizontal rules between major sections:
```markdown
---
```

### Key Terms

| Type | Format | Example |
|------|--------|---------|
| Pattern names | **Bold** | **Builder Pattern** |
| Key concepts | *Italic* | *telescoping constructor* |
| Code elements | `backticks` | `@Builder` |
| First mention of term | **Bold** + *definition* | **Cardinality** refers to... |

### Code Blocks

Always specify language:
```markdown
```java
public class Example {}
```
```

Use modern language versions:
- Java 21+
- Python 3.12+
- TypeScript 5+

---

## Section Requirements

### Required Sections (All Posts)

1. YAML Frontmatter
2. AI Disclaimer
3. Hook with Analogy
4. Core Content
5. Advantages & Disadvantages
6. When to Use / Avoid
7. Conclusion with Key Takeaways
8. Pro Tip
9. Next Up teaser
10. GitHub Example
11. References

### Optional Sections (By Topic)

| Topic Type | Optional Sections |
|------------|------------------|
| Design Pattern | UML Diagram, GoF Definition |
| Database | Query Examples, Explain Plan |
| AWS/Cloud | Architecture Diagram, Cost Notes |
| Framework | Version-specific Notes |

---

## YAML Frontmatter Format

```yaml
---
title: "Mastering [Topic]: [Catchy Subtitle]"
description: "[One sentence benefit, < 160 chars]"
image: "./../assets/img/posts/[YYYY-MM-DD]-[slug].png"
date: [YYYY-MM-DD] 00:00:00 +0300
categories: [[Main], [Sub]]
tags: [ tag1, tag2, tag3 ]
---
```

### Category Guidelines

| Main Category | Sub Categories |
|---------------|----------------|
| Design Patterns | Creational Patterns, Structural Patterns, Behavioral Patterns |
| Database Engineering | Performance Tuning, Query Optimization, Data Modeling |
| Cloud Computing | AWS, Serverless, DevOps |
| Software Architecture | Clean Architecture, Microservices, DDD |

---

## Disclaimer Block

Always include after frontmatter:

```markdown
> This article had its first draft written by AI, then got the "human touch" to make sure everything's clear, correct, and worth your time.
{: .prompt-info }

---
```

---

## Conclusion Format

```markdown
## **X. Conclusion**

[Summary paragraph]

**Key Takeaways:**
- *[Takeaway 1]*
- *[Takeaway 2]*
- *[Takeaway 3]*

---

***Pro Tip***: [Italicized actionable advice]

---

**Next Up:** [Teaser for related topic with brief hook]

---
```

---
name: blog-post-writer
description: Generates production-ready technical blog posts following Jekyll format. Use when the user asks for a blog post, article, technical writing, or mentions topics like design patterns, database optimization, AWS, or software engineering concepts.
---

# Technical Blog Post Writer

## Role & Persona

Senior Technical Writer with extensive Senior Software Developer experience. Goal: produce high-quality, production-ready software engineering articles.

**Crucial:** Act as a "Style Clone" of the existing blog posts in the knowledge references.

---

## When to use this skill

Activate when the user wants to:
- Write a technical blog post or article
- Create content for a Jekyll/GitHub Pages blog
- Generate design pattern explanations
- Write about software engineering concepts (databases, AWS, frameworks)
- Create educational content with code examples

---

## Workflow

Copy this checklist and track progress:
```
Blog Post Creation Progress:
- [ ] Step 1: Receive topic from user
- [ ] Step 2: Research and understand the topic
- [ ] Step 3: Map topic to article structure
- [ ] Step 4: Generate cover image
- [ ] Step 5: Write full markdown article
- [ ] Step 6: Save to _posts directory
```

---

## Step 1: Receive Topic

Get these details from the user:
1. **Topic** - What concept to explain?
2. **Category** - Design Pattern, Database, Cloud, Framework, etc.
3. **Target Framework** (optional) - Spring Boot, React, AWS, etc.

---

## Step 2: The "Style Clone" Protocol

Before generating any content, replicate the article "DNA" exactly:

### Structure DNA

| Section | Purpose |
|---------|---------|
| **YAML Frontmatter** | Jekyll/Liquid format with title, description, image, date, categories, tags |
| **Disclaimer** | AI authorship blockquote with `{: .prompt-info }` |
| **Hook** | Real-world analogy (Fast Food, Library, Logistics) before ANY code |
| **Pain** | Show "Bad Code" (Antipattern) FIRST |
| **Fix** | Show Solution (Pattern/Best Practice) SECOND |
| **Context** | Framework-specific section (Spring Boot, AWS, Database) |
| **Advantages & Disadvantages** | Pros/cons lists |
| **When to Use/Avoid** | Decision guidelines |
| **Conclusion** | Key takeaways list |
| **Pro Tip** | Italicized actionable tip |
| **Next Up** | Teaser for related topic |
| **GitHub Example** | Link with `mcakar-dev` username |
| **References** | Books and URLs |

### Tone DNA

| Rule | Apply |
|------|-------|
| Conversational but authoritative | "Let's break it down." |
| Use "You" and "We" | "You'll learn..." |
| Avoid academic jargon | "messy" not "suboptimal" |

### Formatting DNA

| Element | Format |
|---------|--------|
| Section headers | `## **1. Section Name**` |
| Definitions | `> Blockquote` with `{: .prompt-info }` |
| Section separators | `---` horizontal rules |
| Key terms | `*italic*` for first mention |
| Important concepts | `**bold**` |

See [STYLE_GUIDE.md](references/STYLE_GUIDE.md) for detailed formatting rules.
See [EXAMPLES.md](references/EXAMPLES.md) for example snippets.

---

## Step 3: Generate Cover Image

Use the `generate_image` tool with this template:

```
A minimalist tech blog cover image with dark navy background (#1a2634) 
and subtle hexagonal grid pattern. On the left side, a flat icon 
representing [TOPIC_CONCEPT] with teal/cyan (#4dd0e1) accent glow. 
On the right side, "[TOPIC_TITLE]" text in uppercase light gray. 
Small diamond logo in bottom-right corner. Professional, modern, clean.
```

**Save the image to:** `[workspace]/assets/img/posts/[YYYY-MM-DD]-[slug].png`

See [IMAGE_STYLE.md](references/IMAGE_STYLE.md) for detailed specifications.

---

## Step 4: Write Article

### YAML Frontmatter Template

```yaml
---
title: "Mastering [Topic]: [Subtitle]"
description: "[One sentence describing the practical benefit]"
image: "./../assets/img/posts/[YYYY-MM-DD]-[slug].png"
date: [YYYY-MM-DD] 00:00:00 +0300
categories: [[Main Category], [Sub Category]]
tags: [ comma, separated, lowercase, tags ]
---
```

### Disclaimer Block (Required)

```markdown
> This article had its first draft written by AI, then got the "human touch" to make sure everything's clear, correct, and worth your time.
{: .prompt-info }

---
```

### Article Flow

1. **Hook** - Real-world analogy (NO CODE YET)
2. **Overview** - Pattern/concept definition
3. **UML/Diagram** - If design pattern
4. **Bad Code** - Show the antipattern
5. **Good Code** - Step-by-step solution
6. **Framework Context** - Spring Boot / AWS / Database adaptation
7. **Advantages & Disadvantages** - Pros/cons
8. **When to Use/Avoid** - Decision rules
9. **Conclusion** - Key takeaways + Pro Tip + Next Up
10. **GitHub Example** - Link to mcakar-dev repo
11. **References** - Books and URLs

See [TEMPLATE.md](references/TEMPLATE.md) for full article skeleton.

---

## Step 5: Adaptability Rules

The template adapts to any topic:

| Topic Type | Framework Context Section | Icon Concept |
|------------|--------------------------|--------------|
| Design Pattern | "Spring Boot Context" | Pattern-related abstract icon |
| Database | "Query Optimization Context" | Database/index tree |
| AWS/Cloud | "AWS Context" or "Serverless Context" | Cloud/Lambda symbol |
| Frontend | "React Context" or "Next.js Context" | Framework logo |

Always end with GitHub link pattern:
```markdown
## **GitHub Example**

- GitHub Repository: [mcakar-dev/[repo-name]](https://github.com/mcakar-dev/[repo-name])
```

---

## Step 6: Save Article

Save the completed article to:
```
[workspace]/_posts/[YYYY-MM-DD]-[slug].md
```

Filename format: `YYYY-MM-DD-mastering-[topic]-[subtitle].md`

---

## Code Quality Rules

All code examples MUST follow:
- **OOP principles** - Encapsulation, Inheritance, Polymorphism, Abstraction
- **SOLID principles** - Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion
- **Clean Code practices** - Meaningful names, small functions, no magic numbers
- **Modern language versions** - Java 21+, Python 3.12+, TypeScript 5+

---

## Quick Reference Checklist

- [ ] YAML frontmatter with all fields
- [ ] AI disclaimer blockquote
- [ ] Cover image generated and saved
- [ ] Hook with real-world analogy (no code)
- [ ] Pattern overview with GoF definition (if design pattern)
- [ ] UML diagram (if design pattern)
- [ ] Bad Code → Good Code flow
- [ ] Framework-specific usage section
- [ ] Advantages & Disadvantages
- [ ] When to Use / Avoid guidance
- [ ] Conclusion with Key Takeaways
- [ ] Pro Tip in italics
- [ ] Next Up teaser
- [ ] GitHub Example link (mcakar-dev)
- [ ] References section

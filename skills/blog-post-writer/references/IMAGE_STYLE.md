# Cover Image Style Guide

Specifications for generating blog post cover images using the `generate_image` tool.

---

## Color Palette

| Element | Color | Hex Code |
|---------|-------|----------|
| Background | Dark Navy | `#1a2634` |
| Primary Accent | Teal/Cyan | `#4dd0e1` |
| Secondary Accent | Cyan Glow | `#00bcd4` |
| Title Text | Light Gray | `#e0e0e0` |
| Subtitle Text | Medium Gray | `#9e9e9e` |
| Grid Pattern | Dark Blue-Gray | `#2a3a4a` |

---

## Layout Specifications

```
+------------------------------------------------------------------+
|                                                                  |
|   +------------+                     TOPIC TITLE                 |
|   |            |                     (Uppercase)                 |
|   |   ICON     |                                                 |
|   |  (Teal)    |                                                 |
|   |            |                                                 |
|   +------------+                                                 |
|                                                   ◇ (logo)       |
+------------------------------------------------------------------+
```

| Section | Placement | Size |
|---------|-----------|------|
| Icon/Visual | Left side, ~30% width | Large, prominent |
| Title Text | Right side, ~60% width | Uppercase, centered vertically |
| Grid Pattern | Full background | Subtle, hexagonal |
| Diamond Logo | Bottom-right corner | Small, decorative |

---

## Topic-Specific Icons

| Topic Type | Icon Concept |
|------------|--------------|
| Design Pattern | Related abstract icon (hand building, factory, adapter plug) |
| Database | Database cylinder, query result, index tree |
| AWS/Cloud | Cloud icon, Lambda symbol, serverless architecture |
| Framework | Framework logo or related concept |
| Security | Lock, shield, key |
| Performance | Speedometer, lightning bolt, graph |

---

## Image Generation Prompt Template

Use this template with the `generate_image` tool:

```
A minimalist tech blog cover image with dark navy background (#1a2634) 
and subtle hexagonal grid pattern. On the left side, a flat icon 
representing [TOPIC_CONCEPT] with teal/cyan (#4dd0e1) accent glow. 
On the right side, "[TOPIC_TITLE]" text in uppercase light gray. 
Small diamond logo in bottom-right corner. Professional, modern, clean.
```

### Example Prompts

**Design Pattern (Builder):**
```
A minimalist tech blog cover image with dark navy background (#1a2634) 
and subtle hexagonal grid pattern. On the left side, a flat icon of 
a hand placing building blocks with teal/cyan (#4dd0e1) accent glow. 
On the right side, "BUILDER PATTERN" text in uppercase light gray. 
Small diamond logo in bottom-right corner. Professional, modern, clean.
```

**Database Indexing:**
```
A minimalist tech blog cover image with dark navy background (#1a2634) 
and subtle hexagonal grid pattern. On the left side, a flat icon of 
a database with B-tree structure and teal/cyan (#4dd0e1) accent glow. 
On the right side, "DATABASE INDEXING" text in uppercase light gray. 
Small diamond logo in bottom-right corner. Professional, modern, clean.
```

**AWS Lambda:**
```
A minimalist tech blog cover image with dark navy background (#1a2634) 
and subtle hexagonal grid pattern. On the left side, a flat icon of 
serverless architecture with Lambda symbol and teal/cyan (#4dd0e1) 
accent glow. On the right side, "AWS LAMBDA" text in uppercase light gray. 
Small diamond logo in bottom-right corner. Professional, modern, clean.
```

---

## Output Specifications

| Property | Value |
|----------|-------|
| Save Location | `/assets/img/posts/[YYYY-MM-DD]-[slug].png` |
| File Naming | Match post filename, replace `.md` with `.png` |
| Style | Modern, minimalist, professional |

# Conventional Commits Specification 1.0.0

Reference from: https://www.conventionalcommits.org/en/v1.0.0/

## Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

---

## Specification Rules

1. Commits MUST be prefixed with a type (`feat`, `fix`, etc.), followed by optional scope, optional `!`, and required terminal colon and space.

2. The type `feat` MUST be used when a commit adds a new feature.

3. The type `fix` MUST be used when a commit represents a bug fix.

4. A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis: `fix(parser):`

5. A description MUST immediately follow the colon and space after the type/scope prefix.

6. A longer commit body MAY be provided after the short description. The body MUST begin one blank line after the description.

7. A commit body is free-form and MAY consist of any number of newline separated paragraphs.

8. One or more footers MAY be provided one blank line after the body. Each footer MUST consist of a word token, followed by either `:<space>` or `<space>#` separator, followed by a string value.

9. A footer's token MUST use `-` in place of whitespace characters (e.g., `Acked-by`). Exception: `BREAKING CHANGE` MAY be used as a token.

10. A footer's value MAY contain spaces and newlines.

11. Breaking changes MUST be indicated in the type/scope prefix of a commit, or as an entry in the footer.

12. If included as a footer, a breaking change MUST consist of the uppercase text `BREAKING CHANGE`, followed by a colon, space, and description.

13. If included in the type/scope prefix, breaking changes MUST be indicated by a `!` immediately before the `:`. If `!` is used, `BREAKING CHANGE:` MAY be omitted from the footer.

14. Types other than `feat` and `fix` MAY be used (e.g., `docs`, `style`, `refactor`, `perf`, `test`).

15. The units of information that make up Conventional Commits MUST NOT be treated as case sensitive, with the exception of `BREAKING CHANGE` which MUST be uppercase.

16. `BREAKING-CHANGE` MUST be synonymous with `BREAKING CHANGE` when used as a token in a footer.

---

## Type Definitions

| Type | Description | SemVer |
|------|-------------|--------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | - |
| `style` | Code style (formatting, whitespace) | - |
| `refactor` | Code change without fix/feat | - |
| `perf` | Performance improvement | - |
| `test` | Adding/correcting tests | - |
| `build` | Build system, dependencies | - |
| `ci` | CI configuration | - |
| `chore` | Maintenance tasks | - |
| `revert` | Reverting previous commit | - |

---

## Examples

### Feature with scope
```
feat(lang): add Polish language
```

### Bug fix
```
fix: prevent racing of requests

Introduce a request id and a reference to latest request.
Dismiss incoming responses other than from latest request.

Refs: #123
```

### Breaking change with !
```
feat(api)!: send an email to the customer when a product is shipped
```

### Breaking change with footer
```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Documentation
```
docs: correct spelling of CHANGELOG
```

### Revert
```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

---

## SemVer Correlation

| Commit Type | Version Bump |
|-------------|--------------|
| `fix` | PATCH (x.x.1) |
| `feat` | MINOR (x.1.0) |
| `BREAKING CHANGE` or `!` | MAJOR (1.0.0) |

# Agent Skills

A collection of reusable AI agent skills for agentic IDEs.

## Supported IDEs

| IDE | Status | Skills Location |
|-----|--------|-----------------|
| Antigravity | ✅ Supported | `~/.gemini/antigravity/skills/` |
| Cursor | ✅ Supported | `~/.cursor/skills/` |
| Windsurf | ✅ Supported | `~/.codeium/windsurf/skills/` |

## Installation

### Prerequisites

- Git
- Bash shell

### Quick Install

```bash
# Clone the repository
git clone https://github.com/mcakar-dev/agent-skills.git
cd agent-skills

# Make the install script executable
chmod +x scripts/install-skills.sh

# Install all skills to Antigravity IDE
./scripts/install-skills.sh --ide antigravity

# Or install to Cursor
./scripts/install-skills.sh --ide cursor

# Or install to Windsurf
./scripts/install-skills.sh --ide windsurf
```

### Install Specific Skills

```bash
# Install only specific skills
./scripts/install-skills.sh --ide antigravity --skills java-code-review,commit-message-generator
```

### Available Options

```bash
./scripts/install-skills.sh --help
```

| Flag | Description |
|------|-------------|
| `--ide <name>` | Target IDE (antigravity, cursor, windsurf) |
| `--skills <names>` | Comma-separated skill names to install (optional) |
| `--list` | List available skills |
| `--dry-run` | Preview changes without installing |
| `--help` | Show help message |

## Available Skills

| Skill | Description |
|-------|-------------|
| `blog-post-writer` | Generates technical blog posts following Jekyll format |
| `commit-message-generator` | Generates conventional commit messages |
| `document-generator` | Generates Technical Design Documents |
| `java-code-generator` | Generates Java code with TDD and Clean Architecture |
| `java-code-review` | Reviews Java code for Clean Code and SOLID violations |
| `java-unit-test-writer` | Generates unit tests with 100% delta coverage |
| `skill-creator` | Creates new Agent Skills following open specification |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills.

## License

[MIT](LICENSE)

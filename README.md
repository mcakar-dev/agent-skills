# Agent Skills

A collection of reusable AI agent skills for agentic IDEs. Each skill defines a structured workflow — complete with phases, checklists, and examples — that guides the agent to produce production-ready output consistently.

## Available Skills

| Skill | Description |
|-------|-------------|
| `bash-script-generator` | Generates production-ready Bash scripts following TDD, Clean Code, SOLID, DRY, KISS, and YAGNI principles |
| `bash-script-reviewer` | Reviews shell scripts for Clean Code, SOLID, DRY, KISS, and YAGNI violations |
| `blog-post-writer` | Generates production-ready technical blog posts following Jekyll format |
| `commit-message-generator` | Generates conventional commit messages by analyzing staged git changes |
| `document-generator` | Generates Technical Design Documents (TDD) in English and Turkish |
| `eng-to-tr-translator` | Translates English text to Turkish while preserving technical terms |
| `java-code-generator` | Generates Java code following TDD and Clean Architecture principles |
| `java-code-reviewer` | Reviews Java code for Clean Code, OOP, SOLID, and Design Pattern violations |
| `java-unit-test-writer` | Generates unit tests with 100% delta coverage following TDD practices |
| `skill-creator` | Creates new Agent Skills following the open specification |
| `story-splitter` | Splits requirements into INVEST-compliant user stories using vertical slicing |

## Supported IDEs

| IDE | Skills Path |
|-----|-------------|
| **Antigravity** | `~/.gemini/antigravity/skills/` |
| **Gemini CLI** | `~/.gemini/skills/` |
| **Cursor** | `~/.cursor/skills/` |
| **Windsurf** | `~/.codeium/windsurf/skills/` |
| **VS Code / Copilot** | `~/.copilot/skills/` |
| **Claude Code** | `~/.claude/skills/` |
| **Codex CLI** | `~/.codex/skills/` |
| **Generic (agents)** | `~/.agents/skills/` |

## Installation

### Prerequisites

- Git
- Bash shell

### Quick Start

```bash
# Clone the repository
git clone https://github.com/mcakar-dev/agent-skills.git
cd agent-skills

# Make the installer executable
chmod +x scripts/install-skills.sh

# Launch the interactive wizard (no flags needed)
./scripts/install-skills.sh

# Or use flags directly
./scripts/install-skills.sh --ide antigravity

# Install to ALL supported IDEs at once
./scripts/install-skills.sh --full-install
```

### Installer Reference

| Command | Description |
|---------|-------------|
| *(no args)* | Launch interactive wizard — guided step-by-step setup |
| `--interactive` | Explicitly launch the interactive wizard |
| `--ide <name>` | Install skills to a specific IDE (incremental — skips existing) |
| `--remove --ide <name>` | Remove all installed skills from a specific IDE |
| `--full-install` | Install skills to all supported IDEs |
| `--skills <names>` | Comma-separated list of skills to install (default: all) |
| `--force` | Overwrite existing skills instead of skipping |
| `--link` | Create symbolic links instead of copying (ideal for development) |
| `--dry-run` | Preview changes without modifying the filesystem |
| `--list` | List all available skills |
| `--help` | Show full usage information |

### Examples

```bash
# Interactive wizard — walks you through everything
./scripts/install-skills.sh

# Install missing skills to Cursor
./scripts/install-skills.sh --ide cursor

# Force reinstall all skills to Windsurf
./scripts/install-skills.sh --ide windsurf --force

# Install specific skills to VS Code
./scripts/install-skills.sh --ide vscode --skills java-code-reviewer,commit-message-generator

# Install to all IDEs with symlinks (picks up changes immediately)
./scripts/install-skills.sh --full-install --link

# Preview a full installation
./scripts/install-skills.sh --full-install --dry-run

# Remove all skills from Claude
./scripts/install-skills.sh --remove --ide claude
```

## Skill Structure

Every skill is a directory inside `skills/` containing a `SKILL.md` file:

```
skills/your-skill-name/
├── SKILL.md          # Required: YAML frontmatter + workflow instructions
├── references/       # Optional: detailed docs and checklists
└── assets/           # Optional: templates and examples
```

`SKILL.md` frontmatter:

```yaml
---
name: your-skill-name
description: What it does. Use when [activation triggers].
---
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills.

## License

[MIT](LICENSE)

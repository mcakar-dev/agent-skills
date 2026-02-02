#!/bin/bash
# Scaffold a new skill directory structure
#
# Usage:
#   ./scaffold.sh <skill-name>
#
# Example:
#   ./scaffold.sh reviewing-code

set -e

SKILL_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")/../$SKILL_NAME"

# Validate skill name
validate_name() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Error: Skill name is required" >&2
        echo "Usage: $0 <skill-name>" >&2
        exit 1
    fi
    
    # Check length
    if [ ${#name} -gt 64 ]; then
        echo "Error: Name must be 64 characters or less" >&2
        exit 1
    fi
    
    # Check pattern: lowercase, numbers, hyphens only
    if ! echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        echo "Error: Name must be lowercase letters, numbers, and hyphens only" >&2
        echo "       Cannot start/end with hyphen or have consecutive hyphens" >&2
        exit 1
    fi
    
    # Check reserved words
    if echo "$name" | grep -qiE '(anthropic|claude)'; then
        echo "Error: Name cannot contain reserved words (anthropic, claude)" >&2
        exit 1
    fi
}

# Create directory structure
create_structure() {
    local name="$1"
    local target_dir="$SKILL_DIR"
    
    if [ -d "$target_dir" ]; then
        echo "Error: Directory '$target_dir' already exists" >&2
        exit 1
    fi
    
    echo "Creating skill: $name"
    echo "Location: $target_dir"
    echo ""
    
    # Create directories
    mkdir -p "$target_dir"/{references,scripts,assets}
    
    # Copy template
    if [ -f "$SCRIPT_DIR/../assets/skill-template.md" ]; then
        cp "$SCRIPT_DIR/../assets/skill-template.md" "$target_dir/SKILL.md"
        # Replace placeholder name
        sed -i '' "s/{{skill-name}}/$name/g" "$target_dir/SKILL.md" 2>/dev/null || \
        sed -i "s/{{skill-name}}/$name/g" "$target_dir/SKILL.md"
    else
        # Create minimal SKILL.md
        cat > "$target_dir/SKILL.md" << EOF
---
name: $name
description: {{Describe what this skill does}}. Use when {{specific triggers}}.
---

# ${name//-/ }

## When to use this skill

Activate when the user wants to:
- {{Trigger 1}}
- {{Trigger 2}}

## Workflow

\`\`\`
Task Progress:
- [ ] Step 1: {{First step}}
- [ ] Step 2: {{Second step}}
- [ ] Step 3: {{Verification}}
\`\`\`

## Quick reference

| Command | Description |
|---------|-------------|
| \`{{cmd}}\` | {{description}} |
EOF
    fi
    
    # Create placeholder files
    echo "# Reference" > "$target_dir/references/REFERENCE.md"
    echo "# Examples" > "$target_dir/references/EXAMPLES.md"
    
    echo "Created structure:"
    find "$target_dir" -type f | sed 's|'"$target_dir"'|  .|'
    echo ""
    echo "Next steps:"
    echo "  1. Edit $target_dir/SKILL.md"
    echo "  2. Add references if needed"
    echo "  3. Add scripts if needed"
}

# Main
validate_name "$SKILL_NAME"
create_structure "$SKILL_NAME"

echo ""
echo "✓ Skill '$SKILL_NAME' scaffolded successfully!"

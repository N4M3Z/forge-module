#!/usr/bin/env bash
# forge-module template tests.
# Run: bash tests/test.sh
set -uo pipefail

MODULE_ROOT="$(command cd "$(dirname "$0")/.." && pwd)"
PASS=0 FAIL=0

# --- Helpers ---

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  FAIL  %s\n' "$label"
    printf '    expected: %s\n' "$(echo "$expected" | head -5)"
    printf '    actual:   %s\n' "$(echo "$actual" | head -5)"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local label="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  FAIL  %s\n' "$label"
    printf '    expected to contain: %s\n' "$needle"
    printf '    actual: %s\n' "$(echo "$haystack" | head -5)"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_exists() {
  local label="$1" path="$2"
  if [ -f "$path" ]; then
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  FAIL  %s\n' "$label"
    printf '    file not found: %s\n' "$path"
    FAIL=$((FAIL + 1))
  fi
}

assert_dir_exists() {
  local label="$1" path="$2"
  if [ -d "$path" ]; then
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  FAIL  %s\n' "$label"
    printf '    directory not found: %s\n' "$path"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== forge-module tests ==="

# ============================================================
# Agent structure
# ============================================================
printf '\n--- Agent structure ---\n'

assert_file_exists "agents/ExampleAgent.md exists" "$MODULE_ROOT/agents/ExampleAgent.md"

# Agent has name: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^name:/{print; exit}' "$MODULE_ROOT/agents/ExampleAgent.md")
assert_contains "ExampleAgent.md has name: frontmatter" "name:" "$result"

# Agent has description: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^description:/{print; exit}' "$MODULE_ROOT/agents/ExampleAgent.md")
assert_contains "ExampleAgent.md has description: frontmatter" "description:" "$result"

# Agent has version: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^version:/{print; exit}' "$MODULE_ROOT/agents/ExampleAgent.md")
assert_contains "ExampleAgent.md has version: frontmatter" "version:" "$result"

# Agent body has required sections
agent_body=$(cat "$MODULE_ROOT/agents/ExampleAgent.md")
assert_contains "ExampleAgent has ## Role" "## Role" "$agent_body"
assert_contains "ExampleAgent has ## Expertise" "## Expertise" "$agent_body"
assert_contains "ExampleAgent has ## Instructions" "## Instructions" "$agent_body"
assert_contains "ExampleAgent has ## Output Format" "## Output Format" "$agent_body"
assert_contains "ExampleAgent has ## Constraints" "## Constraints" "$agent_body"

# Agent has honesty clause
assert_contains "ExampleAgent has honesty clause" "don't manufacture" "$agent_body"

# Agent has team communication clause
assert_contains "ExampleAgent has SendMessage clause" "SendMessage" "$agent_body"

# ============================================================
# Skill structure
# ============================================================
printf '\n--- Skill structure ---\n'

assert_file_exists "SKILL.md exists" "$MODULE_ROOT/skills/ExampleConventions/SKILL.md"
assert_file_exists "SKILL.yaml exists" "$MODULE_ROOT/skills/ExampleConventions/SKILL.yaml"

# SKILL.md has name: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^name:/{print; exit}' "$MODULE_ROOT/skills/ExampleConventions/SKILL.md")
assert_contains "SKILL.md has name: frontmatter" "name:" "$result"

# SKILL.md has description: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^description:/{print; exit}' "$MODULE_ROOT/skills/ExampleConventions/SKILL.md")
assert_contains "SKILL.md has description: frontmatter" "description:" "$result"

# SKILL.yaml has provider routing
skill_yaml=$(cat "$MODULE_ROOT/skills/ExampleConventions/SKILL.yaml")
assert_contains "SKILL.yaml has providers" "providers:" "$skill_yaml"
assert_contains "SKILL.yaml has claude provider" "claude:" "$skill_yaml"
assert_contains "SKILL.yaml has gemini provider" "gemini:" "$skill_yaml"
assert_contains "SKILL.yaml has codex provider" "codex:" "$skill_yaml"

# ============================================================
# Configuration files
# ============================================================
printf '\n--- Configuration ---\n'

# module.yaml
assert_file_exists "module.yaml exists" "$MODULE_ROOT/module.yaml"
mod_yaml=$(cat "$MODULE_ROOT/module.yaml")
assert_contains "module.yaml has name" "name:" "$mod_yaml"
assert_contains "module.yaml has version" "version:" "$mod_yaml"
assert_contains "module.yaml has description" "description:" "$mod_yaml"

# defaults.yaml
assert_file_exists "defaults.yaml exists" "$MODULE_ROOT/defaults.yaml"
defaults=$(cat "$MODULE_ROOT/defaults.yaml")
assert_contains "defaults.yaml has agents section" "agents:" "$defaults"
assert_contains "defaults.yaml has ExampleAgent" "ExampleAgent:" "$defaults"
assert_contains "defaults.yaml has skills section" "skills:" "$defaults"
assert_contains "defaults.yaml has providers section" "providers:" "$defaults"
assert_contains "defaults.yaml has claude provider" "claude:" "$defaults"
assert_contains "defaults.yaml has gemini provider" "gemini:" "$defaults"
assert_contains "defaults.yaml has codex provider" "codex:" "$defaults"

# hooks.json is valid JSON
if [ -f "$MODULE_ROOT/hooks/hooks.json" ]; then
  if python3 -c "import json; json.load(open('$MODULE_ROOT/hooks/hooks.json'))" 2>/dev/null; then
    printf '  PASS  hooks.json is valid JSON\n'
    PASS=$((PASS + 1))
  else
    printf '  FAIL  hooks.json invalid\n'
    FAIL=$((FAIL + 1))
  fi
else
  printf '  FAIL  hooks.json missing\n'
  FAIL=$((FAIL + 1))
fi

# plugin.json is valid JSON
if [ -f "$MODULE_ROOT/.claude-plugin/plugin.json" ]; then
  if python3 -c "import json; json.load(open('$MODULE_ROOT/.claude-plugin/plugin.json'))" 2>/dev/null; then
    printf '  PASS  plugin.json is valid JSON\n'
    PASS=$((PASS + 1))
  else
    printf '  FAIL  plugin.json invalid\n'
    FAIL=$((FAIL + 1))
  fi
else
  printf '  FAIL  plugin.json missing\n'
  FAIL=$((FAIL + 1))
fi

# ============================================================
# Naming consistency
# ============================================================
printf '\n--- Naming consistency ---\n'

# module.yaml name matches plugin.json name
mod_name=$(awk '/^name:/{print $2; exit}' "$MODULE_ROOT/module.yaml")
plugin_name=$(python3 -c "import json; print(json.load(open('$MODULE_ROOT/.claude-plugin/plugin.json'))['name'])" 2>/dev/null)
assert_eq "module.yaml name matches plugin.json name" "$mod_name" "$plugin_name"

# module.yaml version matches plugin.json version
mod_version=$(awk '/^version:/{print $2; exit}' "$MODULE_ROOT/module.yaml")
plugin_version=$(python3 -c "import json; print(json.load(open('$MODULE_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
assert_eq "module.yaml version matches plugin.json version" "$mod_version" "$plugin_version"

# ============================================================
# Provider directory scaffolding
# ============================================================
printf '\n--- Provider directories ---\n'

assert_dir_exists ".claude/agents/ exists" "$MODULE_ROOT/.claude/agents"
assert_dir_exists ".claude/skills/ exists" "$MODULE_ROOT/.claude/skills"
assert_dir_exists ".gemini/agents/ exists" "$MODULE_ROOT/.gemini/agents"
assert_dir_exists ".gemini/skills/ exists" "$MODULE_ROOT/.gemini/skills"
assert_dir_exists ".codex/agents/ exists" "$MODULE_ROOT/.codex/agents"
assert_dir_exists ".codex/skills/ exists" "$MODULE_ROOT/.codex/skills"
assert_dir_exists ".opencode/skills/ exists" "$MODULE_ROOT/.opencode/skills"

assert_file_exists ".claude/agents/.gitkeep" "$MODULE_ROOT/.claude/agents/.gitkeep"
assert_file_exists ".claude/skills/.gitkeep" "$MODULE_ROOT/.claude/skills/.gitkeep"
assert_file_exists ".codex/agents/.gitkeep" "$MODULE_ROOT/.codex/agents/.gitkeep"

# ============================================================
# Provider instruction files
# ============================================================
printf '\n--- Provider docs ---\n'

assert_file_exists "CLAUDE.md exists" "$MODULE_ROOT/CLAUDE.md"
assert_file_exists "GEMINI.md exists" "$MODULE_ROOT/GEMINI.md"
assert_file_exists "AGENTS.md exists" "$MODULE_ROOT/AGENTS.md"
assert_file_exists ".github/copilot-instructions.md exists" "$MODULE_ROOT/.github/copilot-instructions.md"
assert_file_exists "LICENSE exists" "$MODULE_ROOT/LICENSE"

# ============================================================
# No obsolete files
# ============================================================
printf '\n--- No obsolete files ---\n'

if [ ! -f "$MODULE_ROOT/hooks/session-start.sh" ]; then
  printf '  PASS  session-start.sh removed (obsolete)\n'
  PASS=$((PASS + 1))
else
  printf '  FAIL  session-start.sh should be removed\n'
  FAIL=$((FAIL + 1))
fi

if [ ! -f "$MODULE_ROOT/hooks/skill-load.sh" ]; then
  printf '  PASS  skill-load.sh removed (obsolete)\n'
  PASS=$((PASS + 1))
else
  printf '  FAIL  skill-load.sh should be removed\n'
  FAIL=$((FAIL + 1))
fi

# ============================================================
# Summary
# ============================================================
printf '\n=== Results ===\n'
printf '  %d passed, %d failed\n\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

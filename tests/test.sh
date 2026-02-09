#!/usr/bin/env bash
# forge-module template tests.
# Run: bash tests/test.sh
set -uo pipefail

MODULE_ROOT="$(builtin cd "$(dirname "$0")/.." && pwd)"
PASS=0 FAIL=0

# --- Helpers ---

_tmpdirs=()
setup() {
  _tmpdir=$(mktemp -d)
  _tmpdirs+=("$_tmpdir")
}
cleanup_all() {
  command rm -f "$MODULE_ROOT/config.yaml"
  for d in "${_tmpdirs[@]}"; do
    [ -d "$d" ] && command rm -rf "$d"
  done
}
trap cleanup_all EXIT

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

assert_not_contains() {
  local label="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    printf '  FAIL  %s\n' "$label"
    printf '    should not contain: %s\n' "$needle"
    FAIL=$((FAIL + 1))
  else
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  fi
}

assert_empty() {
  local label="$1" actual="$2"
  if [ -z "$actual" ]; then
    printf '  PASS  %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  FAIL  %s\n' "$label"
    printf '    expected empty, got: %s\n' "$(echo "$actual" | head -3)"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== forge-module tests ==="

# ============================================================
# Structure tests
# ============================================================
printf '\n--- Structure ---\n'

[ -f "$MODULE_ROOT/skills/ExampleConventions/SKILL.md" ] \
  && { printf '  PASS  SKILL.md exists\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  SKILL.md missing\n'; FAIL=$((FAIL + 1)); }

# SKILL.md has name: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^name:/{print; exit}' "$MODULE_ROOT/skills/ExampleConventions/SKILL.md")
[ -n "$result" ] \
  && { printf '  PASS  SKILL.md has name: frontmatter\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  SKILL.md missing name: frontmatter\n'; FAIL=$((FAIL + 1)); }

# SKILL.md has description: in frontmatter
result=$(awk '/^---$/{if(n++)exit;next} n && /^description:/{print; exit}' "$MODULE_ROOT/skills/ExampleConventions/SKILL.md")
[ -n "$result" ] \
  && { printf '  PASS  SKILL.md has description: frontmatter\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  SKILL.md missing description: frontmatter\n'; FAIL=$((FAIL + 1)); }

# SKILL.md has two !` lines (dual-mode DCI)
bang_count=$(grep -c '^!\`' "$MODULE_ROOT/skills/ExampleConventions/SKILL.md" || true)
assert_eq "SKILL.md has two !command blocks" "2" "$bang_count"

# module.yaml has required fields
[ -f "$MODULE_ROOT/module.yaml" ] \
  && { printf '  PASS  module.yaml exists\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  module.yaml missing\n'; FAIL=$((FAIL + 1)); }

mod_yaml=$(cat "$MODULE_ROOT/module.yaml")
assert_contains "module.yaml has name" "name:" "$mod_yaml"
assert_contains "module.yaml has version" "version:" "$mod_yaml"
assert_contains "module.yaml has events" "events:" "$mod_yaml"
assert_contains "module.yaml has metadata" "metadata:" "$mod_yaml"

# hooks.json is valid JSON
[ -f "$MODULE_ROOT/hooks/hooks.json" ] && python3 -c "import json; json.load(open('$MODULE_ROOT/hooks/hooks.json'))" 2>/dev/null \
  && { printf '  PASS  hooks.json is valid JSON\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  hooks.json invalid or missing\n'; FAIL=$((FAIL + 1)); }

# plugin.json is valid JSON
[ -f "$MODULE_ROOT/.claude-plugin/plugin.json" ] && python3 -c "import json; json.load(open('$MODULE_ROOT/.claude-plugin/plugin.json'))" 2>/dev/null \
  && { printf '  PASS  plugin.json is valid JSON\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  plugin.json invalid or missing\n'; FAIL=$((FAIL + 1)); }

# session-start.sh exists
[ -f "$MODULE_ROOT/hooks/session-start.sh" ] \
  && { printf '  PASS  session-start.sh exists\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  session-start.sh missing\n'; FAIL=$((FAIL + 1)); }

# skill-load.sh exists and is executable
[ -x "$MODULE_ROOT/hooks/skill-load.sh" ] \
  && { printf '  PASS  skill-load.sh exists and is executable\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  skill-load.sh missing or not executable\n'; FAIL=$((FAIL + 1)); }

# ============================================================
# session-start.sh tests
# ============================================================
printf '\n--- session-start.sh ---\n'

# awk fallback (no forge-load in standalone template)
setup
result=$(FORGE_ROOT="$_tmpdir" bash "$MODULE_ROOT/hooks/session-start.sh" 2>/dev/null) || true
assert_contains "session-start (awk fallback): has name:" "name:" "$result"
assert_contains "session-start (awk fallback): has ExampleConventions" "ExampleConventions" "$result"

# Exits 0
exit_code=0
bash "$MODULE_ROOT/hooks/session-start.sh" >/dev/null 2>&1 || exit_code=$?
assert_eq "session-start.sh exits 0" "0" "$exit_code"

# ============================================================
# User.md tests
# ============================================================
printf '\n--- User.md ---\n'

# No User.md by default
SKILL_DIR="$MODULE_ROOT/skills/ExampleConventions"
[ ! -f "$SKILL_DIR/User.md" ] \
  && { printf '  PASS  User.md does not exist by default\n'; PASS=$((PASS + 1)); } \
  || { printf '  FAIL  User.md should not exist by default\n'; FAIL=$((FAIL + 1)); }

# Create temp User.md and verify cat works
setup
USER_MD="$_tmpdir/User.md"
printf '## My Overrides\n\n- Custom rule\n' > "$USER_MD"
result=$(F="$USER_MD"; [ -f "$F" ] && cat "$F")
assert_contains "User.md cat: content emitted" "Custom rule" "$result"

# ============================================================
# DCI expansion tests
# ============================================================
printf '\n--- DCI expansion ---\n'

# DCI line 1: standalone path (module root = plugin root)
exit_code=0
"$MODULE_ROOT/hooks/skill-load.sh" >/dev/null 2>&1 || exit_code=$?
assert_eq "DCI standalone: skill-load.sh exits 0" "0" "$exit_code"

# skill-load.sh with no User.md produces no user content
result=$("$MODULE_ROOT/hooks/skill-load.sh" 2>/dev/null) || true
assert_not_contains "skill-load.sh: no User.md → no user content" "My Overrides" "$result"

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
# Summary
# ============================================================
printf '\n=== Results ===\n'
printf '  %d passed, %d failed\n\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

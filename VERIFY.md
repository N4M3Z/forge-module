# forge-module -- Verification

> **For AI agents**: Complete this checklist after installation. Every check must pass before declaring the module installed.

## Quick check

```bash
make verify
```

## Agent deployment

### Workspace (default)

```bash
ls .claude/agents/ExampleAgent.md
ls .gemini/agents/ExampleAgent.md
ls .codex/agents/ExampleAgent.toml
```

### User (SCOPE=user)

```bash
ls ~/.claude/agents/ExampleAgent.md
ls ~/.gemini/agents/ExampleAgent.md
ls ~/.codex/agents/ExampleAgent.toml
```

Expected: agent file present in the targeted directory.

## Skill deployment

```bash
ls .claude/skills/ExampleConventions/SKILL.md
ls .codex/skills/ExampleConventions/SKILL.md
ls .opencode/skills/example-conventions/SKILL.md
```

## Agent frontmatter (Gemini)

```bash
grep "^model:" .gemini/agents/ExampleAgent.md
# Expected: model: gemini-2.0-flash (or other whitelisted Gemini model)
```

## Module validation

```bash
make test
# Runs validate-module against the module structure
```

## Shell tests

```bash
bash tests/test.sh
# All tests PASS
```

## Expected results

- ExampleAgent deployed to all provider directories
- ExampleConventions skill present in all skill directories
- Agent names match filenames (PascalCase)
- `make test` passes module validation
- `bash tests/test.sh` passes all structure checks

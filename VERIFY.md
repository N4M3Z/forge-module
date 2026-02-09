# forge-module — Verification

> **For AI agents**: Complete this checklist after installation. Every check must pass before declaring the module installed.

## Quick check

```bash
bash tests/test.sh
```

## Manual checks

### SKILL.md structure
```bash
head -5 skills/ExampleConventions/SKILL.md
# Should show frontmatter with name: and description:
```

### SessionStart hook
```bash
bash hooks/session-start.sh
# Should emit metadata (name: ExampleConventions)
```

## Expected test results

- Tests covering structure, session-start.sh, User.md, DCI expansion
- All tests PASS

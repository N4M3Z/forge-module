# forge-module

A template for creating forge modules — plugins that teach AI coding assistants your project's conventions. Works with Claude Code, OpenCode, Cursor, and Copilot.

Clone this repo, rename the example skill, add your conventions, and you have a working module.

## Getting Started

1. Clone this template:
   ```bash
   git clone https://github.com/N4M3Z/forge-module.git forge-my-module
   cd forge-my-module
   rm -rf .git && git init
   ```

2. Rename these (find and replace across all files):

   | Find | Replace with | Example |
   |------|-------------|---------|
   | `forge-module` | Your module name | `forge-python-style` |
   | `ExampleConventions` | Your skill name (PascalCase) | `PythonStyle` |
   | `Example project conventions` | Your description | `Python style and linting conventions` |
   | `Example module` | Short description | `Python style module` |

   Files to update: `module.yaml`, `plugin.json`, `SKILL.md`, `session-start.sh`, `skill-load.sh`, `tests/test.sh`, `README.md`, `INSTALL.md`, `VERIFY.md`

   Don't forget to rename the directory: `skills/ExampleConventions/` → `skills/PythonStyle/`

3. Edit `skills/YourSkillName/SKILL.md` with your actual conventions.

4. Run tests:
   ```bash
   bash tests/test.sh
   ```

## Quick Start

```bash
# As a Claude Code plugin (standalone)
claude plugin install forge-my-module

# Or as part of forge-core (submodule)
git submodule add https://github.com/YOU/forge-my-module.git Modules/forge-my-module
```

Once active, Claude Code discovers the skill automatically when relevant to your work.

## Layout

```
forge-module/
├── module.yaml              # Module metadata (name, version, events)
├── skills/
│   └── ExampleConventions/
│       └── SKILL.md         # Conventions (the actual content AI reads)
├── hooks/
│   ├── hooks.json           # Claude Code hook registration (standalone mode)
│   ├── session-start.sh     # Emits metadata for non-Claude-Code providers
│   └── skill-load.sh        # Injects external steering content + User.md
├── tests/
│   └── test.sh              # Module tests
├── .githooks/
│   └── pre-commit           # Shellcheck lint (if available)
├── .claude-plugin/
│   └── plugin.json          # Plugin discovery (standalone mode)
├── .gitignore
├── CONTRIBUTING.md
├── INSTALL.md
├── VERIFY.md
└── README.md
```

## User Extensions

Two ways to customize (additive — both can be active):

### 1. External steering

Point the module at directories outside the repo. Create `config.yaml` (gitignored):

```yaml
steering:
  - /path/to/your/conventions/directory/
```

The AI sees a directory listing and reads specific files on demand. Requires the `forge-steering` module.

### 2. Inline overrides (User.md)

Create `skills/ExampleConventions/User.md` (gitignored) with your personal rules:

```markdown
## My Overrides

- Always use type hints in function signatures
- Prefer f-strings over .format()
```

## How It Works

The core content lives in `SKILL.md` — a markdown file with YAML frontmatter and inline conventions. Different AI providers load it differently:

| Provider | How it discovers the skill | How it loads content |
|----------|---------------------------|---------------------|
| **Claude Code** | Reads SKILL.md frontmatter at session start | Loads full skill on demand when relevant |
| **OpenCode** | SessionStart hook emits metadata | forge-load library transforms and emits content |
| **Cursor / Copilot** | Baked into static config via adapters | Content included at session start |

Claude Code preprocesses shell commands in SKILL.md (written as `` !`command` ``) — these inject external steering content and user overrides when the skill is invoked.

**Note for Claude Code users**: The SessionStart hook exists for non-Claude-Code providers. Claude Code's skill discovery handles loading directly, so you can disable it with `events: []` in `config.yaml`.

### Dual-mode DCI

SKILL.md contains two `!`command`` lines — one for standalone mode, one for forge-core:

```
!`"${CLAUDE_PLUGIN_ROOT}/hooks/skill-load.sh" 2>/dev/null`
!`"${CLAUDE_PLUGIN_ROOT}/Modules/forge-module/hooks/skill-load.sh" 2>/dev/null`
```

When installed standalone, `CLAUDE_PLUGIN_ROOT` is the module root — the first line succeeds. Under forge-core, it's the project root — the second line succeeds. The other fails silently.

## Configuration

**module.yaml** — checked into git:

```yaml
name: forge-module
version: 0.1.0
description: Example module. USE WHEN you need project conventions guidance.
events:
  - SessionStart
metadata:
  name: [name, title]
  description: description
steering: []
```

**config.yaml** — gitignored, user creates to configure:

```yaml
# Disable SessionStart hook (Claude Code doesn't need it)
events: []

# External steering paths
steering:
  - /path/to/your/conventions/directory/
```

## Dependencies

| Module | Required | Purpose |
|--------|----------|---------|
| **forge-load** | Optional | Content loading for non-Claude-Code providers |
| **forge-steering** | Optional | External steering via `bin/steer` tool |

Both degrade gracefully when absent.

## Testing

```bash
bash tests/test.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for code style and linting requirements.

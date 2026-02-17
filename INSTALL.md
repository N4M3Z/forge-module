# forge-module — Installation

> **For AI agents**: This guide covers installation of forge-module. Follow the steps for your deployment mode.

## As part of forge-core

Add as a submodule:

```bash
git submodule add https://github.com/YOUR_NAME/forge-module.git Modules/forge-module
```

Then register the skill in forge-core's `.claude-plugin/plugin.json`:

```json
"skills": ["./Modules/forge-module/skills"]
```

And add the module to `forge.yaml` under the appropriate event.

## Standalone (Claude Code plugin)

```bash
claude plugin install forge-module
```

Or install from a local path during development:

```bash
claude plugin install /path/to/forge-module
```

## User Extensions

### External steering

Create `config.yaml` (gitignored) with paths to external convention directories:

```yaml
steering:
  - /path/to/your/steering/directory/
```

Requires the `forge-steering` module.

### Inline overrides

Create `skills/ExampleConventions/User.md` (gitignored) with your personal rules.

### Disable SessionStart hook

Claude Code loads skills natively — the SessionStart hook is for other providers. To disable it:

```yaml
# config.yaml
events: []
```

## Recommended Security Tools

See [root installation guide](../../INSTALL.md#recommended-security-tools) for full setup. This module benefits from:

- **shellcheck** — `brew install shellcheck` (shell script linting)
- **[safety-net](https://github.com/kenryu42/claude-code-safety-net)** — destructive command protection

# forge-module -- Installation

> **For AI agents**: This guide covers installation of forge-module. Follow the steps for your deployment mode.

## As part of forge-core (submodule)

Add as a submodule:

```bash
git submodule add https://github.com/YOUR_NAME/forge-module.git Modules/forge-module
```

Deploy agents and skills:

```bash
make -C Modules/forge-module install FORGE_LIB=path/to/forge-lib
```

forge-lib is provided by the parent project via `FORGE_LIB` env var -- the module's own `lib/` submodule is not used when running inside forge-core.

## Standalone (Claude Code plugin)

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-module.git
```

Or if already cloned:

```bash
git submodule update --init
```

This checks out [forge-lib](https://github.com/N4M3Z/forge-lib) into `lib/`, providing shared utilities for agent deployment.

### 2. Deploy agents and skills

```bash
make install
```

By default, this installs to the local project directory for use in the current workspace (`SCOPE=workspace`):

- Agents: `.claude/agents/`, `.gemini/agents/`, `.codex/agents/`
- Skills: `.claude/skills/`, `.gemini/skills/`, `.codex/skills/`, `.opencode/skills/`

To install globally for your user (available in all projects):

```bash
make install SCOPE=user
```

Use `SCOPE=all` to target both workspace and user home directories.

The Makefile automatically initializes the `lib/` submodule on first run if `Cargo.toml` is not found.

### 3. Running Agents in Codex

Installed agents are available as sub-agents but must be invoked explicitly:

- Standalone specialist: `Task: ExampleAgent -- [request]`
- Skills: `/ExampleConventions`

### 4. Running Agents in Gemini CLI

Enable sub-agents in `~/.gemini/settings.json`:

```json
{
    "experimental": {
        "enableAgents": true
    }
}
```

Then:
1. Run `/agents refresh` to scan installed agents.
2. Run `/agents list` to verify.
3. Invoke via `/agents run ExampleAgent [query]` or use skill commands.

### 5. Verification

```bash
make verify
```

See [VERIFY.md](VERIFY.md) for the post-installation checklist.

## Configuration

### defaults.yaml

Ships with the agent roster and provider config:

```yaml
agents:
    ExampleAgent:
        model: fast
        tools: Read, Grep, Glob

providers:
    claude:
        fast: claude-sonnet-4-6
    gemini:
        fast: gemini-2.0-flash
```

### Module config override

Create `config.yaml` (gitignored) to override:

```yaml
agents:
    ExampleAgent:
        model: strong
```

## Updating

```bash
git pull --recurse-submodules    # update module + forge-lib
make clean                      # remove old agents
make install                    # reinstall everything
```

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| forge-lib | Yes (standalone) | Shared agent deployment utilities |
| shellcheck | Recommended | `brew install shellcheck` -- shell script linting |
| [safety-net](https://github.com/kenryu42/claude-code-safety-net) | Recommended | Destructive command protection |

# AGENTS.md -- forge-module

> Template for creating forge modules -- plugins that teach AI coding assistants
> your project's conventions. One example agent, one example skill, multi-provider
> deployment via forge-lib.

## Build / Install / Verify

No compiler or bundler. "Build" means deploying agent markdown and skill files
to provider directories (`.claude/.gemini/.codex` for workspace, `~/` equivalents
for user installs).

```bash
make install            # install agent + skill
make install-agents     # install agents using SCOPE (workspace|user|all)
make install-skills     # install skills using SCOPE across Claude/Gemini/Codex/OpenCode
make clean              # remove previously installed agents
make verify             # run verification checks
make test               # run module validation (validate-module)
make lint               # shellcheck all scripts
```

Standalone agent deployment without Make:

```bash
lib/bin/install-agents agents              # install
lib/bin/install-agents agents --dry-run    # preview
lib/bin/install-agents agents --clean      # clean + reinstall
```

## Project Structure

```
agents/              1 agent definition (ExampleAgent.md)
skills/              1 skill dir (ExampleConventions/)
lib/                 git submodule -> forge-lib (Rust binaries)
defaults.yaml        Agent roster + skill config + provider models (committed)
config.yaml          User overrides (gitignored, same structure as defaults)
module.yaml          Module metadata (name, version, description)
.claude-plugin/      plugin.json manifest for Claude Code
```

## Agent Markdown Files (`agents/*.md`)

### Frontmatter (YAML between `---` delimiters)

Required keys: `name` (PascalCase, matches filename), `description`, `version`.

Deployment config (model, tools, scope) lives in `defaults.yaml`, not in agent frontmatter.

```yaml
---
name: ExampleAgent
description: "Example conventions reviewer -- code style, naming, project structure. USE WHEN code review, style check, convention verification."
version: 0.1.0
---
```

### Body structure (in order)

1. Blockquote summary (one sentence, ends with "Shipped with forge-module.")
2. `## Role`, `## Expertise`
3. `## Instructions` -- detailed steps with `###` subsections
4. `## Output Format` -- markdown template in a fenced code block
5. `## Constraints` -- bullet list; must include honesty clause and team
   communication clause

## Skill Files (`skills/*/SKILL.md` + `SKILL.yaml`)

`SKILL.md` contains behavior/instructions. `SKILL.yaml` contains metadata and
provider routing (`claude`, `gemini`, `codex`).

## Naming Conventions

| Context | Convention | Example |
|---------|-----------|---------|
| Agent filenames | `PascalCase.md` | `ExampleAgent.md` |
| `name` | PascalCase, matches filename | `ExampleAgent` |
| Skill directories | PascalCase | `ExampleConventions/` |
| YAML keys | lowercase | `model`, `tools`, `scope` |

## YAML Configuration

- `defaults.yaml` -- canonical roster. Edit when adding/removing agents.
- `config.yaml` -- user overrides (gitignored). Same structure, only changed fields.
- `module.yaml` -- module metadata. Update `version` on releases.
- Model and tool selection lives in `defaults.yaml`, NOT in agent frontmatter.

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no
scope. Types: `feat`, `fix`, `docs`.

## Modification Workflows

**Adding a new agent:** Create `agents/YourAgent.md` with frontmatter and
structured body (Role, Expertise, Instructions, Output Format, Constraints).
Add to `defaults.yaml` roster. Run `lib/bin/install-agents agents --dry-run`.
Commit: `feat: add YourAgent for [domain]`.

**Modifying a skill:** Edit `skills/SkillName/SKILL.md` and `SKILL.yaml`.
Test by invoking the skill. Commit changes.

**Updating models or tools:** Edit `defaults.yaml` (or `config.yaml` override),
then re-deploy with `lib/bin/install-agents agents --clean`.

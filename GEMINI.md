# GEMINI.md - forge-module Context

This directory contains **forge-module**, a template for creating forge modules -- plugins that teach AI coding assistants your project's conventions. Works with Claude Code, Gemini CLI, Codex, and OpenCode.

## Project Overview

- **Purpose:** Provide a working template for building forge modules. Clone, rename, customize.
- **Architecture:**
    - **Agents (`agents/`):** 1 example agent (ExampleAgent) -- conventions reviewer.
    - **Skills (`skills/`):** 1 example skill (ExampleConventions) -- project conventions guidance.
    - **Configuration (`defaults.yaml`):** Agent roster, skill config, and provider-specific model tiers.
    - **Ecosystem:** Part of the "forge" suite -- can be used standalone or as a forge-core submodule.

## Getting Started

### Installation

```bash
make install                # deploy agent + skill for all providers (SCOPE=workspace)
make install SCOPE=user     # deploy to ~/.claude/, ~/.gemini/, ~/.codex/ (global)
make verify                 # check everything deployed
```

### Configuration (Gemini CLI)

Sub-agents must be explicitly enabled in `~/.gemini/settings.json`:
```json
{
    "experimental": { "enableAgents": true }
}
```

### Discovery

- Run `/agents refresh` and `/agents list` to see installed specialists.
- Invoke skills via their slash commands (e.g., `/ExampleConventions`).

## Development Conventions

- **Agent Definitions:** Agents in `agents/*.md` use YAML frontmatter for identity (name, description, version) and Markdown for instructions (Role, Expertise, Constraints). Deployment config (model, tools) lives in `defaults.yaml`.
- **Skill Definitions:** Skills in `skills/*/SKILL.md` + `SKILL.yaml` define behavior and provider routing.
- **Modularity:** Configuration in `defaults.yaml`, overrides in `config.yaml` (gitignored).

## Model Resolution

When deploying agents for Gemini, the installation script:
1. Resolves tiers using Gemini-specific models from `defaults.yaml` providers section.
2. Whitelists models -- only Gemini-compatible models appear in deployed agent frontmatter.
3. Overrides via `config.yaml` take precedence.

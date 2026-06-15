# Asymptote Vector Graphics Skill

This is an OpenCode agent skill for generating technical vector graphics using the Asymptote language.

## Structure

```
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── docs/                 # Knowledge base documentation
```

## Supported Drawing Types



## Installation

### For Users

Clone this repository into your OpenCode skills directory:

```bash
# Global installation (available in all projects)
git clone https://github.com/doombeaker/asymptote-skill.git \
  ~/.config/opencode/skills/asymptote

# Or project-local installation (only for current project)
git clone https://github.com/doombeaker/asymptote-skill.git \
  .opencode/skills/asymptote
```

Then the agent can load it on demand by calling:

```
skill({ name: "asymptote" })
```

### For Contributors

```bash
git clone https://github.com/doombeaker/asymptote-skill.git
cd asymptote-skill
```

## Usage

The skill is loaded automatically by OpenCode when working with Asymptote-related tasks. The main `SKILL.md` provides the entry point, with detailed documentation in the `docs/` directory and reusable code in `templates/`.

## License

LGPL-3.0 (matching Asymptote's license)

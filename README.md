# Asymptote Vector Graphics Skill

This is an OpenCode agent skill for generating technical vector graphics using the Asymptote language.

## Structure

```
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── docs/                 # Knowledge base documentation
│   ├── 01-basics.md
│   ├── 02-geometry.md
│   ├── 03-scientific-graphs.md
│   ├── 04-3d-graphics.md
│   ├── 05-flowcharts.md
│   ├── 06-feynman-diagrams.md
│   ├── 07-animations.md
│   ├── 08-circuits.md
│   └── 09-cad-engineering.md
├── templates/            # Ready-to-use code templates
│   ├── geometry.asy
│   ├── graph.asy
│   ├── 3d.asy
│   ├── flowchart.asy
│   ├── circuit.asy
│   └── animation.asy
└── examples/             # Curated example files
    ├── pythagoras.asy
    ├── electromagnetic.asy
    ├── controlsystem.asy
    ├── cardioid.asy
    ├── feynman.asy
    └── 3d-sphere.asy
```

## Supported Drawing Types

- **2D Geometry**: Triangles, circles, conics, angles, constructions
- **Scientific Graphs**: Function plots, data visualization, 3D surfaces, contours
- **Flowcharts**: Block diagrams, control systems, algorithm visualization
- **Feynman Diagrams**: Particle physics diagrams with all standard line types
- **Circuit Diagrams**: Electrical schematics with custom component functions
- **3D Graphics**: Surfaces, solids, lighting, projections, WebGL/PRC
- **Animations**: Frame-based animation generation
- **Engineering/CAD**: Technical drawings with ISO standard line types

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

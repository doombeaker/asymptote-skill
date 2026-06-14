# Asymptote Vector Graphics Skill

This directory contains an OpenCode agent skill for generating technical vector graphics using the Asymptote language.

## Structure

```
asymptote/
├── SKILL.md              # Main skill definition
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

## Usage

The skill is loaded automatically by OpenCode when working with Asymptote-related tasks. The main `SKILL.md` provides the entry point, with detailed documentation in the `docs/` directory and reusable code in `templates/`.

## Reference Materials

This skill is based on:
- Asymptote official user manual (`asymptote.markdown`)
- Asymptote standard library (`base/`)
- Asymptote official examples (`examples/`)

## License

LGPL-3.0 (matching Asymptote's license)

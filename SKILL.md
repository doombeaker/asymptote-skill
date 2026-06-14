---
name: asymptote
description: Expert Asymptote vector graphics language skill for generating technical drawings, geometric figures, scientific graphs, 3D visualizations, flowcharts, Feynman diagrams, circuit diagrams, and animations with LaTeX-quality typesetting.
license: LGPL-3.0
compatibility: opencode
metadata:
  category: graphics
  language: asymptote
  version: "2.0"
---

# Asymptote Vector Graphics Skill

This skill enables the agent to generate high-quality technical vector graphics using the Asymptote language. Asymptote is a powerful descriptive vector graphics language that provides a mathematical coordinate-based framework for technical drawing, with LaTeX typesetting of labels.

## Capabilities

- **2D Geometric Drawings**: Points, lines, circles, polygons, curves, transformations
- **Scientific Graphs**: 2D/3D function plots, data visualization, contour plots, parametric curves
- **3D Graphics**: Surfaces, solids, lighting, projections, interactive WebGL/PRC
- **Flowcharts**: Block diagrams, control systems, algorithm visualization
- **Feynman Diagrams**: Particle physics diagrams with fermions, photons, gluons
- **Circuit Diagrams**: Electrical/electronic circuit schematics
- **Animations**: Frame-based animations, interactive 3D scenes
- **Engineering/CAD**: Technical drawings with standard line types and symbols

## Skill Structure

This skill is organized into multiple documentation files and templates:

| File | Content |
|------|---------|
| `docs/01-basics.md` | Core language syntax, drawing primitives, paths, pens, transforms |
| `docs/02-geometry.md` | 2D geometric constructions, angles, triangles, circles, intersections |
| `docs/03-scientific-graphs.md` | graph.asy module, axes, ticks, legends, palettes |
| `docs/04-3d-graphics.md` | three.asy module, surfaces, solids, lighting, projections |
| `docs/05-flowcharts.md` | flowchart.asy module, block diagrams, connectors |
| `docs/06-feynman-diagrams.md` | feynman.asy module, particle physics diagrams |
| `docs/07-animations.md` | animate.asy, animation.asy, frame generation |
| `docs/08-circuits.md` | Circuit diagram conventions and construction techniques |
| `docs/09-cad-engineering.md` | CAD.asy, technical drawing standards |
| `templates/*.asy` | Ready-to-use templates for each category |
| `examples/*.asy` | Curated example files |

## How to Use

1. **Identify the drawing type** from the user's request
2. **Load the relevant module(s)** with `import module;`
3. **Set up the picture** with `size()`, `unitsize()`, or viewport settings
4. **Draw objects** using the appropriate commands
5. **Add labels** with LaTeX formatting: `label("$...$", position, align);`
6. **Ship out** with `shipout()` or implicit output

## Key Modules

### Automatically Imported (plain.asy)
- `draw()`, `fill()`, `clip()`, `label()` — basic commands
- `pair`, `path`, `pen`, `transform` — basic types
- Compass directions: `N`, `S`, `E`, `W`, `NE`, `NW`, etc.
- `unitsquare`, `unitcircle` — predefined paths

### Optional Standard Modules
- `geometry` — advanced geometric constructions
- `graph` / `graph3` — scientific plotting
- `three` / `solids` — 3D graphics
- `flowchart` — flowchart diagrams
- `feynman` — Feynman diagrams
- `animate` / `animation` — animations
- `CAD` — engineering drawing standards
- `palette` — color palettes for data visualization
- `contour` / `contour3` — contour plots

## Output Formats

Asymptote supports multiple output formats:
- **PDF** (default): `asy -f pdf file.asy`
- **EPS/PS**: `asy file.asy`
- **SVG**: `asy -f svg file.asy`
- **PNG/JPG** (via ImageMagick): `asy -f png file.asy`
- **WebGL**: for interactive 3D in HTML
- **PRC**: for 3D in PDF

## Important Conventions

1. **Coordinates**: Default in PostScript bp (1/72 inch). Use `unitsize(1cm)` for metric.
2. **Paths**: `--` for straight line, `..` for Bezier spline, `cycle` to close.
3. **Labels**: Double-quoted LaTeX strings: `label("$E=mc^2$", (0,0), N);`
4. **Pens**: Control color, line width, dash pattern: `red+linewidth(1)+dashed`
5. **Transforms**: `shift`, `scale`, `rotate`, `reflect`, `xscale`, `yscale`
6. **Arrowheads**: `Arrow`, `Arrows`, `MidArrow`, with optional `arrowhead=` parameter

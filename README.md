# Asymptote Vector Graphics Skill

This is an OpenCode agent skill for generating high-quality technical vector graphics using the Asymptote language.

## Overview

Asymptote is a powerful descriptive vector graphics language that provides a mathematical coordinate-based framework for technical drawing, with LaTeX-quality typesetting of labels. This skill enables agents to produce professional geometric figures, scientific plots, and flowcharts with clean, maintainable code.

## Supported Drawing Types

- **2D Geometric Drawings**: Points, lines, circles, triangles, polygons, conics, transformations
- **Scientific Graphs**: 2D function plots, data visualization, parametric curves, polar plots, error bars, vector fields
- **Flowcharts**: Block diagrams, algorithm visualization using default Asymptote primitives
- **Picture Composition**: Reusable components, layered drawings, subplots, overlays using `add(picture, picture)`

## Structure

```
├── SKILL.md              # Main skill definition and entry point
├── README.md             # This file
├── docs/                 # Knowledge base documentation
│   ├── 01-basics.md      # Core language syntax, paths, pens, transforms, coding standards
│   ├── 02-geometry.md    # 2D geometric constructions using the geometry module
│   ├── 03-scientific-graphs.md  # Scientific plotting with graph and colormap modules
│   ├── 04-modular-diagram.md    # Modular diagram construction with picture + point()
│   └── 05-skillutils-reference.md # Skillutils function reference with inline code blocks
├── lib/                  # Shared Asymptote libraries (part of the skill)
│   └── skillutils.asy    # Reusable library: label_box_pic, label_rounded_pic, roundbox, pics_bbox, pics_cluster
├── templates/            # Ready-to-use Asymptote templates
│   ├── geometric_*.asy   # 2D geometric drawing templates
│   ├── scientific_*.asy  # Scientific graph templates
│   ├── *_flowchart.asy  # Flowchart templates
│   └── *_diagram.asy    # System architecture templates
└── vendor/               # Reference source files
    ├── asymptote.texi    # Asymptote user manual
    ├── geometry.asy      # Geometry module source
    ├── graph.asy         # Graph module source
    └── colormap.asy      # Colormap module source
```

## Installation

### Prerequisites

Install Asymptote on your system:

```bash
# macOS
brew install asymptote

# Ubuntu/Debian
sudo apt-get install asymptote

# Arch Linux
sudo pacman -S asymptote
```

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

The skill is loaded automatically by OpenCode when working with Asymptote-related tasks. The main `SKILL.md` provides the entry point, with detailed documentation in the `docs/` directory.

### Quick Start

Once the skill is loaded, the agent can generate Asymptote code for various drawing tasks:

```asy
// Example: Draw a simple geometric figure
import geometry;

pair A = (0, 0);
pair B = (4, 0);
pair C = (2, 3);

draw(A--B--C--cycle);
dot("$A$", A, SW);
dot("$B$", B, SE);
dot("$C$", C, N);
```

## Key Design Principles

This skill enforces the following principles for all generated code:

1. **Professional coding standards**: Meaningful variable names, named constants, strategic comments mapping code to visual elements
2. **Default capabilities first**: Prefer Asymptote's built-in primitives over standard libraries (e.g., use default drawing for flowcharts instead of `import flowchart`)
3. **English-only output**: All labels, comments, and variable names are in English (Asymptote has poor CJK support)
4. **Clean aesthetics**: Minimal text in diagram elements (1-3 words per flowchart block), consistent styling, effective whitespace
5. **Picture-based composition**: Encapsulate repeated elements in `picture` functions, compose with `add(dest, src)`, and apply transforms (`shift`, `rotate`) before adding
6. **Shared utilities**: Use `import skillutils;` for common flowchart/diagram building blocks (`label_box_pic`, `pics_bbox`, `pics_cluster`) instead of duplicating inline code

## Output Formats

Asymptote supports multiple output formats:
- **PDF** (default): `asy -f pdf file.asy`
- **EPS/PS**: `asy file.asy`
- **SVG**: `asy -f svg file.asy`
- **PNG/JPG** (via ImageMagick): `asy -f png file.asy`

## License

LGPL-3.0 (matching Asymptote's license)

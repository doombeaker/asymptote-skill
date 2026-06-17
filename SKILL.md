---
name: asymptote
description: Expert Asymptote vector graphics language skill for generating technical drawings, geometric figures, scientific graphs, and flowcharts with LaTeX-quality typesetting.
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
- **Scientific Graphs**: 2D function plots, data visualization, parametric curves, polar plots
- **Flowcharts**: Block diagrams, algorithm visualization using default primitives

## Skill Structure

This skill is organized into documentation files and ready-to-use templates:

| File | Content |
|------|---------|
| `docs/01-basics.md` | Core language syntax, drawing primitives, paths, pens, transforms, coding standards |
| `docs/02-geometry.md` | 2D geometric constructions using the `geometry` module |
| `docs/03-scientific-graphs.md` | Scientific plotting with the `graph` module and `colormap` |
| `docs/04-flowchart.md` | Flowchart construction using default Asymptote primitives |
| `docs/05-picture-guide.md` | Practical `picture` composition guide: reusable components, transforms, subplots, overlays |
| `templates/` | Ready-to-use templates for common drawing types (see list below) |

### Templates

The `templates/` directory contains production-ready Asymptote files that demonstrate best practices:

**2D Geometric Drawings:**
- `geometric_unit_circle.asy` — Unit circle with angle annotation and sector fill
- `geometric_theorem.asy` — Pythagorean theorem visualization with squares and labels
- `geometric_circumcircle.asy` — Triangle circumcircle construction
- `geometric_venn.asy` — Two-set Venn diagram with overlap coloring

**Scientific Graphs:**
- `scientific_function_plot.asy` — Function plot with axes, ticks, and labels
- `scientific_polar_plot.asy` — Polar plot with filled sector and radial lines
- `scientific_complex_function.asy` — Discontinuous function (Gamma) with branch handling

**Flowcharts:**
- `minimal_flowchart.asy` — Simple vertical flowchart (5 nodes or fewer)
- `modular_flowchart.asy` — Modular flowchart with parallel branches and curved arrows
- `system_diagram.asy` — System architecture with clusters and hierarchical layout

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
- `geometry` — advanced geometric constructions (points, lines, circles, triangles, conics)
- `graph` — scientific plotting (functions, data, axes, ticks, error bars)
- `colormap` — matplotlib-compatible color palettes for data visualization

## Output Formats

Asymptote supports multiple output formats:
- **PDF** (default): `asy -f pdf file.asy`
- **EPS/PS**: `asy file.asy`
- **SVG**: `asy -f svg file.asy`
- **PNG/JPG** (via ImageMagick): `asy -f png file.asy`

## Important Conventions

1. **Language**: **ALL output must be in English only.** Asymptote has poor support for CJK (Chinese, Japanese, Korean) characters and Unicode. Use English labels, comments, and variable names exclusively.
2. **Coordinates**: Default in PostScript bp (1/72 inch). Use `unitsize(1cm)` for metric.
3. **Paths**: `--` for straight line, `..` for Bezier spline, `cycle` to close.
4. **Labels**: Double-quoted LaTeX strings: `label("$E=mc^2$", (0,0), N);`
5. **Pens**: Control color, line width, dash pattern: `red+linewidth(1)+dashed`
6. **Transforms**: `shift`, `scale`, `rotate`, `reflect`, `xscale`, `yscale`
7. **Arrowheads**: `Arrow`, `Arrows`, `MidArrow`, with optional `arrowhead=` parameter

## Aesthetic Guidelines

- **Keep diagrams clean and minimal**: Avoid cluttering elements with excessive text.
- **Flowchart blocks should contain only keywords**: Each block should hold a brief keyword or short phrase (1-3 words). If detailed explanation is needed, place it in a separate text area or caption outside the diagram, not inside the blocks.
- **Use whitespace effectively**: Ensure adequate spacing between elements for readability.
- **Consistent styling**: Maintain uniform colors, line widths, and font sizes throughout a single diagram.

## Programming Best Practices

Asymptote is often used by scientists and mathematicians who may not be professional programmers. This skill enforces professional coding standards to ensure generated code is readable, maintainable, and easy to modify.

### 1. Use Meaningful Variable Names

Store geometric data in descriptively named variables. This makes the code self-documenting and much easier to map back to the visual diagram.

**Good:**
```asy
pair origin = (0,0);
pair topVertex = (0,3);
pair leftBase = (-2,0);
pair rightBase = (2,0);

triangle tri = triangle(leftBase, rightBase, topVertex);
path altitude = topVertex--foot(topVertex, leftBase, rightBase);

draw(tri);
draw(altitude, dashed);
```

**Avoid:**
```asy
pair a = (0,0), b = (2,0), c = (1,2);
draw(a--b--c--cycle);
draw(c--(1,0), dashed);
```

### 2. Never Use Reserved Keywords as Variable Names

Asymptote reserves several keywords that **must not** appear as identifiers (variable names, parameter names, function names). Using them causes cryptic syntax errors.

**Full reserved word list:**

| Category | Keywords |
|----------|----------|
| Conditional | `if`, `else` |
| Loop | `while`, `for`, `do`, `break`, `continue` |
| Return | `return` |
| Declaration | `struct`, `typedef`, `using` |
| Object | `new`, `operator`, `this`, `explicit` |
| Import | `import`, `include`, `access`, `from`, `unravel`, `quote` |

> **`from` is the most common accidental violation** — it looks natural as a parameter name (e.g., `pair fromDir`) but `from` is a keyword used in `from module access symbol;`. Always choose an alternative name.

**Safe alternatives:**

| Avoid | Use instead |
|-------|-------------|
| `from` | `src` (source), `origin` (starting point), `startDir` (direction from source) |
| `to` | `tgt` (target), `dest` (destination), `endDir` (direction to target) |
| `new` | `fresh`, `created`, `initial` |
| `access` | `entry`, `retrieval` |
| `include` | `embed`, `insert` |

**Bad — `from` is a keyword:**
```asy
void arrowCurve(picture dest, picture src, pair fromDir,
                picture to, pair toDir) {
    pair a = point(src, fromDir) + gap * fromDir;  // COMPILE ERROR
}
```

**Good — use `srcDir` instead:**
```asy
void arrowCurve(picture dest, picture src, pair srcDir,
                picture tgt, pair tgtDir) {
    pair a = point(src, srcDir) + gap * srcDir;
}
```

### 3. Avoid Magic Numbers — Use Named Constants

Never hard-code the same value multiple times. Define constants at the top of your script so adjustments (e.g., changing a radius or spacing) require only a single edit.

**Good:**
```asy
real nodeSpacing = 2.5;
real boxWidth = 3.0;
real boxHeight = 1.2;
pair startPos = (0,0);
pair processPos = (0, -nodeSpacing);
pair decisionPos = (0, -2*nodeSpacing);
```

**Avoid:**
```asy
block b1 = rectangle("Start", (0,0));
block b2 = rectangle("Process", (0,-2.5));
block b3 = diamond("Valid?", (0,-5.0));
```

### 3. Comment Strategically

Comments should explain *what visual element* a block of code produces, making it easy for someone reading the code to locate the corresponding part of the image.

**Good:**
```asy
// Main triangle vertices
pair vertexA = (0,0);
pair vertexB = (4,0);
pair vertexC = (2,3);

// Draw the triangle and label vertices
draw(vertexA--vertexB--vertexC--cycle);
label("$A$", vertexA, SW);
label("$B$", vertexB, SE);
label("$C$", vertexC, N);

// Altitude from C to base AB
pair footD = foot(vertexC, vertexA, vertexB);
draw(vertexC--footD, dashed);
label("$D$", footD, S);
```

### 4. Group Related Drawing Operations

Organize code into logical sections with blank lines and section comments. Group setup, drawing, labeling, and annotations separately.

```asy
// ==========================================
// CONFIGURATION
// ==========================================
real circleRadius = 2.0;
pen mainPen = black + linewidth(1);
pen highlightPen = red + linewidth(1.5);

// ==========================================
// GEOMETRY DEFINITION
// ==========================================
pair centerO = (0,0);
pair pointA = (circleRadius, 0);
pair pointB = rotate(60) * pointA;
pair pointC = rotate(120) * pointA;

path circumcircle = circle(centerO, circleRadius);
path trianglePath = pointA--pointB--pointC--cycle;

// ==========================================
// DRAWING
// ==========================================
draw(circumcircle, mainPen);
filldraw(trianglePath, lightyellow, highlightPen);

// ==========================================
// LABELS
// ==========================================
label("$O$", centerO, SW);
label("$A$", pointA, E);
label("$B$", pointB, NE);
label("$C$", pointC, NW);
```

### 5. Reusable Components as Functions

For repeated visual elements (circuit symbols, custom arrows, grid nodes), define reusable functions rather than duplicating code.

```asy
// Reusable resistor symbol
path resistorSymbol(pair start, pair end, real width=0.3, int zigzags=5) {
    pair mid = (start + end) / 2;
    pair dir = unit(end - start);
    pair perp = rotate(90) * dir;
    real len = length(end - start);
    real step = len / zigzags;

    guide g = start;
    for (int i = 0; i < zigzags; ++i) {
        real t = i * step;
        g = g--(start + t*dir + width*perp)
             --(start + (t + step/2)*dir - width*perp);
    }
    return g--end;
}
```

### 6. Use Visual Feedback When Available

If the execution environment supports image viewing, use an iterative visual feedback loop to refine the output:

1. **Generate a preview**: Compile with `asy -f png file.asy` (requires ImageMagick) to produce a raster image that can be inspected immediately.
2. **Inspect visually**: Evaluate proportions, alignment, color balance, label placement, and whitespace directly from the rendered image.
3. **Adjust code**: Tweak coordinates, pens, sizes, or transforms based on what you see, then regenerate.
4. **Final export**: Once the visual result is satisfactory, export to the desired final format (usually PDF or SVG).

This loop is especially valuable for complex multi-layer compositions where purely analytical coordinate calculations are not enough to guarantee a clean layout.

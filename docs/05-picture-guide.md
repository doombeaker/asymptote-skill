# Asymptote `picture` Practical Guide

> Quick reference for real-world drawing needs. Built on the **`add(picture, picture)` first** principle, each scenario provides a copy-paste-ready code template.

---

## Core Principles (Read Before Using `picture`)

### 1. Prefer `add(dest, src)` Where `src` Is a `picture`

`add(dest, src)` places `src`'s user coordinates directly into `dest`'s coordinate system, unified by `dest`'s final `user → PS` transform. This automatically maintains a common scale across all sub-pictures without manual size calculations.

`add(dest, src.fit(), pos)` (frame usage) first scales `src` to a fixed size and then places it at `pos`. **Only use this when you need strictly fixed physical-size labels or legends**; it is not recommended for routine sub-picture composition.

### 2. The Final Picture Must Have `size()` Set First

Before adding any sub-picture with `add()`, call `size(final, ...)` on the final output picture. Otherwise `dest` falls back to the PostScript bp coordinate system (1/72 inch), making all added sub-pictures extremely tiny.

### 3. Apply Transforms to a `picture`, Then `add`

Adjust position or angle via `shift(t) * pic`, `rotate(a) * pic`, etc. These return a new `picture`. Then `add(dest, newPic)`. This fully decouples component definition from layout.

### 4. Use `shipout()` with a `picture` Argument, Not a Filename

`shipout(final)` is sufficient. The output filename is controlled by external tooling (Makefile, scripts, or the `-o` flag). Avoid hard-coding filenames in code.

---

## `point()`: Querying Picture Boundary Anchors

When composing sub-pictures into a diagram, you often need to know where a sub-picture's edges are — to draw arrows between nodes, align labels, or position adjacent elements. Instead of manually tracking box dimensions and computing `center ± half_width`, Asymptote provides `point()`.

### Function Signature

```
pair point(picture pic=currentpicture, pair dir, bool user=true);
```

Returns the point on `pic`'s bounding box in the direction `dir` relative to its center. With `user=true` (the default), the returned value is in user coordinates.

### Compass Direction Constants

Asymptote predefines standard compass directions as `pair` constants in the `plain` module:

| Constant | Value | Meaning |
|----------|-------|---------|
| `N` | `(0, 1)` | North (top center) |
| `S` | `(0, -1)` | South (bottom center) |
| `E` | `(1, 0)` | East (right center) |
| `W` | `(-1, 0)` | West (left center) |
| `NE` | `unit(N+E)` | Northeast corner |
| `NW` | `unit(N+W)` | Northwest corner |
| `SE` | `unit(S+E)` | Southeast corner |
| `SW` | `unit(S+W)` | Southwest corner |

Any `pair` can be used as a direction — `point(pic, (1, 2))` returns the boundary point toward (1,2) from center. If your variable shadows a direction constant (e.g., `real E = 2.718`), use `plain.E` to access the original.

### Core Workflow: Create → Shift → Point → Draw

```asy
// 1. CREATE: component function draws at origin, returns a picture
picture makeNode(string text, real bw, real bh, pen fillPen, pen borderPen) {
    picture pic;
    fill(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), fillPen);
    draw(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), borderPen);
    label(pic, text, fontsize(9pt));
    return pic;
}

// 2. SHIFT: position each instance in the parent coordinate system
real bw = 3, bh = 1;
picture nodeA = shift(0,  2) * makeNode("Upper", bw, bh, lightblue, blue);
picture nodeB = shift(0, -1) * makeNode("Lower", bw, bh, lightgreen, green);

// 3. POINT: query boundary anchors — no manual bh/2 needed
pair aSouth = point(nodeA, S);   // bottom edge of nodeA
pair bNorth = point(nodeB, N);   // top edge of nodeB

// 4. DRAW: connect with arrows, then add nodes
picture final;
size(final, 10cm);

draw(final, aSouth -- bNorth, arrow = Arrow(TeXHead));
add(final, nodeA);
add(final, nodeB);

shipout(final);
```

**Why the draw-before-add order?** Drawing arrows first and adding nodes second places arrows behind nodes visually. Since `point()` coordinates are valid regardless of add order, you can also reverse the order if you prefer arrows on top.

### Adding Gaps

`point()` returns the exact edge. For visual breathing room, add a small offset in the appropriate direction:

```asy
real gap = 0.25;
pair start = point(topNode, S) + (0, -gap);   // slightly below south edge
pair end   = point(botNode, N) + (0,  gap);   // slightly above north edge
draw(dest, start -- end, arrow = Arrow(TeXHead));
```

### `point()` vs Manual Calculation

| Approach | Moving a node | Different box sizes | Code clarity |
|----------|--------------|---------------------|-------------|
| `center.y - bh/2 - gap` | Must update every arrow | Must know each node's `bh` | Scattered magic numbers |
| `point(node, S) - (0, gap)` | Just change `shift()` | Automatic | Self-documenting |

### Related Functions

```
pair min(picture pic, user=true);   // bottom-left corner of bounding box
pair max(picture pic, user=true);   // top-right corner of bounding box
pair size(picture pic, user=true);  // (width, height) of bounding box
```

Useful for centering a picture that has been `add()`-ed to a sized parent: `shift(-min(pic, true)) * pic` shifts so the bottom-left corner is at origin.

> **⚠️ Gotcha: `min()`/`max()` on standalone pictures**
>
> `min(pic)` and `max(pic)` return coordinates through the picture's `user → PS` transform. For a standalone sub-picture that has **never been `add()`-ed to a sized parent picture**, this transform is the PostScript bp identity — the returned coordinates are in an unrelated scale, not user coordinates.
>
> Use `point(pic, SW)` for bottom-left and `point(pic, NE)` for top-right instead. These compute boundary anchors from the picture's drawn content and stored transforms, returning correct user-coordinate values even for standalone pictures.
>
> The `skillutils` library provides `pics_bbox(picture[] pics)` which wraps this pattern safely — see `lib/skillutils.asy`.

---

## Scenario 1: Encapsulate Graphics into Reusable Components

### When to Use

You have drawn a complex figure (e.g., gear, circuit symbol, icon) and want multiple copies at different sizes or angles in the same figure, or to reuse it across different drawings.

### Code Template

```asy
// Reusable component definition
picture component(pen fillPen) {
    picture pic;
    fill(pic, unitcircle, fillPen);
    draw(pic, unitcircle, black + 1);
    dot(pic, (0, 0), black);
    return pic;
}

// Instantiate multiple copies
picture redCircle  = component(red);
picture blueCircle = component(blue);
picture greenCircle = component(green);

// Compose into a scene
picture scene;
size(scene, 10cm);
add(scene, shift(3, 0) * redCircle);
add(scene, blueCircle);
add(scene, shift(-3, 0) * greenCircle);

shipout(scene);
```

### Key Points

- A `picture`-returning function is a **component template** that can be instantiated many times.
- Use `shift` for **position transforms** before `add`-ing to the scene. Component internals keep relative coordinates; the caller controls placement.
- Because `scene` has `size(10cm)`, `redCircle` and `blueCircle`'s user coordinates are correctly mapped to the 10 cm scale.

---

## Scenario 2: Multiple Transforms on the Same Component

### When to Use

You need symmetric patterns, rotational arrays, or different poses of the same object.

### Code Template

```asy
picture arrowComponent() {
    picture pic;
    draw(pic, (0, 0) -- (2, 0), arrow = Arrow);
    return pic;
}

picture scene;
size(scene, 10cm);

// Original orientation
add(scene, arrowComponent());

// Rotated 45 degrees
picture arrow45 = rotate(45) * arrowComponent();
add(scene, shift(3, 0) * arrow45);

// Horizontal mirror
picture arrowMirror = reflect((0, 0), (0, 1)) * arrowComponent();
add(scene, shift(-3, 0) * arrowMirror);

shipout(scene);
```

### Available Transforms

| Transform | Description |
|-----------|-------------|
| `scale(s)` | Uniform scale |
| `scale(sx, sy)` | Non-uniform scale |
| `rotate(angle)` | Rotation in degrees |
| `reflect(p1, p2)` | Mirror along line `p1--p2` |
| `shift(x, y)` | Translation |
| `shift(pair)` | Vector translation |
| **Chained** | `scale(2) * rotate(45) * shift(3, 0) * pic` |

### Notes

- Transforms are **right-associative**: `scale(2) * rotate(45) * pic` = first rotate 45°, then scale 2×.
- Transforms **do not mutate** the original `picture`; they return a new one. You can safely transform the same base component in a loop.

---

## Scenario 3: Multiple Subplots Side-by-Side (Different Coordinate Ranges)

### When to Use

Two subplots have different data ranges or coordinate extents and need to be placed side by side.

### Code Template

```asy
// Left plot: 0..1 range
picture leftPlot;
draw(leftPlot, (0, 0) -- (1, 1), red);
for (int i = 0; i <= 5; ++i) {
    dot(leftPlot, (i / 5, i / 5));
}

// Right plot: 0..10 range
picture rightPlot;
draw(rightPlot, (0, 0) -- (10, 5), blue);
for (int i = 0; i <= 5; ++i) {
    dot(rightPlot, (i * 2, i));
}

picture combined;
size(combined, 10cm);
add(combined, shift(-2, 0) * leftPlot);
add(combined, shift(2, 0) * rightPlot);

shipout(combined);
```

### Key Points

- `size(combined, 10cm)` **must run first** to establish the physical output size and the user → PS mapping.
- `leftPlot` (0..1 range) and `rightPlot` (0..10 range) enter `combined`'s coordinate system directly.
- In `combined`, the 0..1 range and the 0..10 range both map through `combined`'s unified scale. The right plot therefore appears wider in the final output — exactly the visual effect expected from "different coordinate ranges."
- Use `shift` to separate the two subplots and prevent overlap.

---

## Scenario 4: Multiple Layers with Unified Scale

### When to Use

Several layers must stack with the exact same scale, e.g., markers on a map.

### Code Template

```asy
// Base map: coordinate grid
picture map;
size(map, 10cm);
draw(map, (0, 0) -- (10, 0) -- (10, 10) -- (0, 10) -- cycle);
for (int i = 0; i <= 10; ++i) {
    draw(map, (i, 0) -- (i, 10), gray(0.5));
    draw(map, (0, i) -- (10, i), gray(0.5));
}

// Marker component — drawn at origin, purely relative coordinates
picture markerComponent(pen p) {
    picture pic;
    fill(pic, scale(0.3) * unitcircle, p);
    return pic;
}

// Position markers via shift
add(map, shift(0, 0)    * markerComponent(black));
add(map, shift(2, 3)    * markerComponent(red));
add(map, shift(5, 7)    * markerComponent(blue));
add(map, shift(8, 2)    * markerComponent(green));

shipout(map);
```

### Key Points

- `markerComponent` **contains no position information** — it only draws the shape. Position is controlled externally by `shift`, fully decoupling component definition from layout.
- `add(map, shift(2, 3) * markerComponent(red))` means: take the contents of `markerComponent(red)` and place them into `map`, but offset to `map`'s user coordinates `(2, 3)`.
- Because `map` is sized at 10 cm and data spans 0..10, 1 user unit ≈ 1 cm. A `scale(0.3) * unitcircle` marker has a diameter of about 0.6 cm.

---

## Scenario 5: Parameterized Batch Generation (Color / Size Arrays)

### When to Use

You need a set of similar shapes differing only in color or size, e.g., color swatches or legends.

### Code Template

```asy
picture coloredSquare(pen p, real scaleFactor = 1) {
    picture pic;
    fill(pic, scale(scaleFactor) * unitsquare, p);
    draw(pic, scale(scaleFactor) * unitsquare, black);
    return pic;
}

pen[] paletteColors = {red, orange, yellow, green, cyan, blue, purple};

picture palette;
size(palette, 10cm);
for (int i = 0; i < paletteColors.length; ++i) {
    picture sq = coloredSquare(paletteColors[i], 1);
    add(palette, shift(i * 1.5, 0) * sq);
}

shipout(palette);
```

### Advanced: 2-D Array

```asy
picture scene;
size(scene, 10cm);

picture coloredSquare(pen p, real scaleFactor = 1) {
    picture pic;
    fill(pic, scale(scaleFactor) * unitsquare, p);
    draw(pic, scale(scaleFactor) * unitsquare, black);
    return pic;
}

for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 3; ++j) {
        pen p = (i + j) % 2 == 0 ? red : blue;
        picture sq = coloredSquare(p, 0.8);
        add(scene, shift(i * 2, -j * 2) * sq);
    }
}
shipout(scene);
```

---

## Scenario 6: Multi-Step Drawing with Final Merge

### When to Use

A figure consists of multiple independent parts, drawn separately and then assembled.

### Code Template

```asy
import graph;

// Part 1: Axes
picture axes;
draw(axes, (-2, 0) -- (2, 0), arrow = Arrow);
draw(axes, (0, -2) -- (0, 2), arrow = Arrow);

// Part 2: Function curve
picture curve;
draw(curve, graph(new real(real x) { return x ^ 2; }, -1.5, 1.5), red);

// Part 3: Labels
picture labels;
label(labels, "$y = x^2$", (1.5, 2), E);

// Merge
picture final;
size(final, 10cm);
add(final, axes);
add(final, curve);
add(final, labels);

shipout(final);
```

### Benefits

- Each part can be debugged independently without affecting the others.
- Any part can be commented out for isolated testing.
- Parts can be reused in different figures.
- All sub-pictures enter `final`'s 10 cm coordinate system via `add(final, ...)`. No inconsistent scales arise from individual fitting.

---

## Scenario 7: Overlay Elements (Compass, Legend, etc.)

### When to Use

Overlay a compass, scale bar, or legend on a large figure (map, statistical plot). With `add(picture, picture)`, everything scales through the final `picture`'s `size()`.

### Code Template

```asy
// Main map
picture map;
size(map, 10cm);
draw(map, (0, 0) -- (10, 0) -- (10, 10) -- (0, 10) -- cycle);
for (int i = 0; i <= 10; ++i) {
    draw(map, (i, 0) -- (i, 10), gray(0.5) + 0.5);
}

// Compass component — drawn at origin, purely relative coordinates
picture compass() {
    picture pic;
    draw(pic, (0, 0) -- (0, 1.5), arrow = Arrow);   // North
    label(pic, "N", (0, 1.8), N);
    draw(pic, (-0.3, 0) -- (0.3, 0));
    return pic;
}

// Merge into final output
picture final;
size(final, 10cm);
add(final, map);
add(final, shift(12, 10) * compass());

shipout(final);
```

### Key Distinction

- `map`'s user range is 0..10. `size(final, 10cm)` makes 1 user unit ≈ 1 cm in `final`.
- The compass's `(0, 0)` to `(0, 1.8)` corresponds to about 1.8 cm in `final` — **consistent relative scale to `final`'s coordinate system**. If you change to `size(final, 20cm)`, the compass scales proportionally to 3.6 cm.
- This overlay method suits "sub-elements share the same scale as the base map." If you need an element to remain at a **strictly fixed physical size** (e.g., the compass must always be exactly 1 cm tall regardless of map size), use the frame approach: `add(dest, src.fit(), pos)`.

---

## Common Mistakes and Fixes

### Mistake 1: Calling `shipout` Without a Picture Argument

```asy
picture scene;
draw(scene, (0, 0) -- (1, 1));
shipout();          // WRONG — outputs empty currentpicture
shipout(scene);     // Correct
```

### Mistake 2: Failing to `size()` the Destination Before `add`

```asy
picture scene;
picture dotPic;
dot(dotPic, (0, 0));
add(scene, dotPic);
shipout(scene);  // WRONG — scene has no size, defaults to PS coordinates,
                 //         output may be only a few pixels

// Correct
size(scene, 5cm);
add(scene, dotPic);
shipout(scene);
```

### Mistake 3: Forgetting to Store the Transformed Picture in a Variable

```asy
// Risky: shift * base does return a new picture, but explicit binding is clearer
picture scene;
size(scene, 10cm);
picture base;
draw(base, unitsquare);
for (int i = 0; i < 3; ++i) {
    add(scene, shift(i, 0) * base);
}

// Clearer: explicit instantiation
for (int i = 0; i < 3; ++i) {
    picture instance = shift(i, 0) * base;
    add(scene, instance);
}
```

> `shift(i, 0) * base` always returns a new `picture`; explicit variable binding improves readability.

### Mistake 4: Overusing `.fit()` and Breaking Coordinate Coherence

```asy
// Not recommended: intermediate frame breaks unified user-transform
add(scene, subPic.fit());

// Recommended: use picture directly to preserve user-coordinate consistency
add(scene, shift(pos) * subPic);
```

---

## Quick Reference Card

| Need | Pattern |
|------|---------|
| Define component | `picture func(params) { picture pic; ...; return pic; }` |
| Reuse component | `picture inst = func(args); add(scene, shift(pos) * inst);` |
| Labeled box (skillutils) | `import skillutils; picture p = label_box_pic(pos, w, h, dy, text, textPen, fill, border);` |
| Transform component | `rotate(45) * scale(2) * pic` |
| Subplots side by side | `add(dest, shift(pos) * src)` |
| Unified coordinates | `add(dest, src)` (no fit) |
| Query boundary anchor | `point(pic, dir)` where `dir` is `N`/`S`/`E`/`W`/`NE`/etc. |
| Query bbox (safe) | `pics_bbox(pics)` from skillutils — returns `{bottomLeft, topRight}` |
| Cluster background | `pics_cluster(pics, padx, pady, fill, border)` from skillutils |
| Control output | `size(pic, 5cm); shipout(pic);` |

---

## Full Example: Comprehensive Application

```asy
// Comprehensive example: scientific figure with axes, data points, and legend

// 1. Axes component
picture axes(real xMin, real xMax, real yMin, real yMax) {
    picture pic;
    draw(pic, (xMin, 0) -- (xMax, 0), arrow = Arrow);
    draw(pic, (0, yMin) -- (0, yMax), arrow = Arrow);
    return pic;
}

// 2. Data point component
picture dataPoints(pair[] points, pen p) {
    picture pic;
    for (pair pt : points) {
        dot(pic, pt, p);
    }
    return pic;
}

// 3. Legend item component
picture legendItem(pen p, string text) {
    picture pic;
    draw(pic, (0, 0) -- (0.5, 0), p + 1);
    label(pic, text, (0.7, 0), E);
    return pic;
}

// Usage
pair[] series1 = {(1, 1), (2, 3), (3, 2), (4, 5)};
pair[] series2 = {(1, 2), (2, 1), (3, 4), (4, 3)};

picture plot;
add(plot, axes(0, 5, 0, 6));
add(plot, dataPoints(series1, red));
add(plot, dataPoints(series2, blue));

picture legend;
add(legend, legendItem(red, "Series A"));
add(legend, shift(0, -0.5) * legendItem(blue, "Series B"));

picture final;
size(final, 8cm);
add(final, plot);
add(final, shift(5, 5) * legend);

shipout(final);
```

This example demonstrates:

- **Component encapsulation** — `axes`, `dataPoints`, and `legendItem` are independent `picture` functions.
- **Layered drawing** — Axes, data, and legend are drawn separately and merged at the end.
- **Unified transform** — All content enters `final`'s 8 cm coordinate system via `add(final, ...)`. No fit-induced scale inconsistency.
- **Layout decoupling** — Legend position is controlled by `shift(5, 5)`; the main plot content need not know about it.

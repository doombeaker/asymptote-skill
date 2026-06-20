# Skillutils Reference & Inline Code Source

This document provides the core `skillutils` functions as **copy-paste-ready code blocks**. Other agents and code generators should inline these functions directly into their output `.asy` files when the user does not have `skillutils.asy` in their import path.

When `lib/skillutils.asy` IS available on the Asymptote search path, prefer `import skillutils;` instead.

---

## label_box_pic

Creates a labeled, filled, bordered box as a `picture`, shifted to `position`. This is the fundamental building block for modular diagram nodes.

```asy
picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string[] lines,
                      pen label_text, pen fillPen, pen borderPen) {
    picture pic;
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    fill(pic, box(bl, tr), fillPen);
    draw(pic, box(bl, tr), borderPen);
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);
    return shift(position) * pic;
}

picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string text,
                      pen label_text, pen fillPen, pen borderPen) {
    return label_box_pic(position, box_width, box_height, lineDy,
                         new string[]{text}, label_text, fillPen, borderPen);
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `position` | `pair` | Shift vector — box center lands at this point in the parent coordinate system |
| `box_width` | `real` | Total width of the box (user units) |
| `box_height` | `real` | Total height of the box (user units) |
| `lineDy` | `real` | Vertical spacing between consecutive text lines |
| `lines` | `string[]` | Array of label strings, drawn top-to-bottom |
| `label_text` | `pen` | Pen for label rendering (e.g. `fontsize(9pt)`, `fontsize(8pt) + rgb(0.5,0.5,0.5)`) |
| `fillPen` | `pen` | Fill pen for the box interior |
| `borderPen` | `pen` | Stroke pen for the box outline |

### Usage

```asy
pen textPen = fontsize(9pt);

// Single-line node
picture pStart = label_box_pic((0, 2), 3.0, 0.9, 0.32, "Start", textPen, startFill, startBorder);

// Multi-line node
picture pProc = label_box_pic((3, 0), 3.0, 0.9, 0.32, new string[]{"Process", "compute"}, textPen, procFill, procBorder);

add(diagram, pStart);
add(diagram, pProc);
pair anchor = point(pStart, S);  // query boundary — no bh/2 math needed
```

---

## roundbox

Creates a rounded rectangle path. Used internally by `label_rounded_pic()`, but also available directly for custom shapes.

```asy
path roundbox(pair bl, pair tr, real r) {
    r = min(r, (tr.x - bl.x) / 2, (tr.y - bl.y) / 2);
    return (bl.x, bl.y + r){down}..{right}(bl.x + r, bl.y) --
           (tr.x - r, bl.y){right}..{up}(tr.x, bl.y + r) --
           (tr.x, tr.y - r){up}..{left}(tr.x - r, tr.y) --
           (bl.x + r, tr.y){left}..{down}(bl.x, tr.y - r) -- cycle;
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `bl` | `pair` | Bottom-left corner of the bounding rectangle |
| `tr` | `pair` | Top-right corner of the bounding rectangle |
| `r` | `real` | Corner radius (clamped to half the smaller dimension) |

### Usage

```asy
path rbox = roundbox((0, 0), (4, 2), 0.3);
filldraw(rbox, lightblue, blue);
```

---

## label_rounded_pic

Creates a labeled, filled, bordered rounded box as a `picture`, shifted to `position`. Same interface as `label_box_pic()` with an additional `radius` parameter.

```asy
picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string[] lines,
                          pen label_text, pen fillPen, pen borderPen) {
    picture pic;
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    path rbox = roundbox(bl, tr, radius);
    fill(pic, rbox, fillPen);
    draw(pic, rbox, borderPen);
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);
    return shift(position) * pic;
}

picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string text,
                          pen label_text, pen fillPen, pen borderPen) {
    return label_rounded_pic(position, box_width, box_height, radius, lineDy,
                             new string[]{text}, label_text, fillPen, borderPen);
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `position` | `pair` | Shift vector — box center lands at this point in the parent coordinate system |
| `box_width` | `real` | Total width of the box (user units) |
| `box_height` | `real` | Total height of the box (user units) |
| `radius` | `real` | Corner radius (clamped to half the smaller dimension) |
| `lineDy` | `real` | Vertical spacing between consecutive text lines |
| `lines` | `string[]` | Array of label strings, drawn top-to-bottom |
| `label_text` | `pen` | Pen for label rendering (e.g. `fontsize(9pt)`) |
| `fillPen` | `pen` | Fill pen for the box interior |
| `borderPen` | `pen` | Stroke pen for the box outline |

### Usage

```asy
pen textPen = fontsize(9pt);

// Single-line rounded card
picture card1 = label_rounded_pic((0, 2), 3.0, 0.9, 0.2, 0.32, "Service A", textPen, svcFill, svcBorder);

// Multi-line rounded card
picture card2 = label_rounded_pic((0, -1), 3.0, 0.9, 0.2, 0.32,
                                  new string[]{"Service B", "v2.1"}, textPen, svcFill, svcBorder);

add(diagram, card1);
add(diagram, card2);
pair anchor = point(card1, S);  // boundary query works the same as label_box_pic
```

---

## pics_bbox

Computes the axis-aligned bounding box enclosing all given pictures. Uses `point(pic, SW)` / `point(pic, NE)` instead of `min()` / `max()` to avoid the PostScript coordinate trap on standalone sub-pictures.

```asy
pair[] pics_bbox(picture[] pics) {
    pair lo = point(pics[0], SW);
    pair hi = point(pics[0], NE);
    for (int i = 1; i < pics.length; ++i) {
        pair lo_i = point(pics[i], SW);
        pair hi_i = point(pics[i], NE);
        lo = (min(lo.x, lo_i.x), min(lo.y, lo_i.y));
        hi = (max(hi.x, hi_i.x), max(hi.y, hi_i.y));
    }
    return new pair[]{lo, hi};
}
```

### Why not `min()` / `max()`?

`min(pic)` / `max(pic)` return coordinates through the picture's `user → PS` transform. For a standalone sub-picture that has never been `add()`-ed to a sized parent picture, this transform is the identity in PostScript bp units (1/72 inch), **not** user units. The resulting coordinates appear wildly offset.

`point(pic, dir)` does not have this problem — it computes boundary anchors from the picture's drawn content + stored transforms, returning correct user-coordinate values even for standalone pictures.

### Usage

```asy
pair[] bb = pics_bbox(new picture[]{pA, pB, pC});
pair bottomLeft = bb[0];   // (min x, min y)
pair topRight  = bb[1];    // (max x, max y)
```

---

## pics_cluster

Draws a fill+border rectangle enclosing all given pictures with padding, returned as a `picture`. Add it **before** the node pictures so it renders behind them.

```asy
picture pics_cluster(picture[] pics, real padx, real pady,
                     pen fillPen, pen borderPen) {
    pair[] bb = pics_bbox(pics);
    pair lo = bb[0] - (padx, pady);
    pair hi = bb[1] + (padx, pady);
    picture bg;
    filldraw(bg, box(lo, hi), fillPen, borderPen);
    return bg;
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `pics` | `picture[]` | Array of pictures to enclose |
| `padx` | `real` | Horizontal padding between nodes' bbox and the box edge |
| `pady` | `real` | Vertical padding between nodes' bbox and the box edge |
| `fillPen` | `pen` | Interior fill pen (`nullpen` for no fill) |
| `borderPen` | `pen` | Outline stroke pen (`nullpen` for no border) |

### Usage

```asy
picture bg = pics_cluster(new picture[]{pRouter, pPod1, pPod2}, 0.4, 0.3, clusterFill, clusterPen);

add(diagram, bg);     // behind
add(diagram, pRouter);  // in front
add(diagram, pPod1);
add(diagram, pPod2);

// Optional: cluster label positioned below the box
label(diagram, "Cluster Name", (point(bg, S).x, point(bg, S).y + 0.5), clusterLabelPen);
```

---

## Full Inline Template

When generating a standalone `.asy` file that uses these utilities, inline all functions at the top of the file:

```asy
// --- skillutils inline ---
picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string[] lines,
                      pen label_text, pen fillPen, pen borderPen) {
    picture pic;
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    fill(pic, box(bl, tr), fillPen);
    draw(pic, box(bl, tr), borderPen);
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);
    return shift(position) * pic;
}
picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string text,
                      pen label_text, pen fillPen, pen borderPen) {
    return label_box_pic(position, box_width, box_height, lineDy,
                         new string[]{text}, label_text, fillPen, borderPen);
}
path roundbox(pair bl, pair tr, real r) {
    r = min(r, (tr.x - bl.x) / 2, (tr.y - bl.y) / 2);
    return (bl.x, bl.y + r){down}..{right}(bl.x + r, bl.y) --
           (tr.x - r, bl.y){right}..{up}(tr.x, bl.y + r) --
           (tr.x, tr.y - r){up}..{left}(tr.x - r, tr.y) --
           (bl.x + r, tr.y){left}..{down}(bl.x, tr.y - r) -- cycle;
}
picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string[] lines,
                          pen label_text, pen fillPen, pen borderPen) {
    picture pic;
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    path rbox = roundbox(bl, tr, radius);
    fill(pic, rbox, fillPen);
    draw(pic, rbox, borderPen);
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);
    return shift(position) * pic;
}
picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string text,
                          pen label_text, pen fillPen, pen borderPen) {
    return label_rounded_pic(position, box_width, box_height, radius, lineDy,
                             new string[]{text}, label_text, fillPen, borderPen);
}
pair[] pics_bbox(picture[] pics) {
    pair lo = point(pics[0], SW);
    pair hi = point(pics[0], NE);
    for (int i = 1; i < pics.length; ++i) {
        pair lo_i = point(pics[i], SW);
        pair hi_i = point(pics[i], NE);
        lo = (min(lo.x, lo_i.x), min(lo.y, lo_i.y));
        hi = (max(hi.x, hi_i.x), max(hi.y, hi_i.y));
    }
    return new pair[]{lo, hi};
}
picture pics_cluster(picture[] pics, real padx, real pady,
                     pen fillPen, pen borderPen) {
    pair[] bb = pics_bbox(pics);
    pair lo = bb[0] - (padx, pady);
    pair hi = bb[1] + (padx, pady);
    picture bg;
    filldraw(bg, box(lo, hi), fillPen, borderPen);
    return bg;
}
// --- end skillutils inline ---
```

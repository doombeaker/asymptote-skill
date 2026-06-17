# Diagrams of Systems, Flows, and Relationships

This document covers how to create **system architecture diagrams**, **data flow diagrams**, **model architecture diagrams**, and **workflow diagrams** using Asymptote's default primitives. These diagrams express relationships between entities — components, stages, layers, or tasks — rather than rigid algorithmic control flow.

The `flowchart` standard module is intentionally **not used** here. Its shapes (Start/End ovals, Decision diamonds) are too restrictive for system diagrams. Default primitives provide full control over layout, grouping, and arrow styling.

The core technique is the **`picture` + `point()` pattern**: each node is a `picture`-returning component function; arrows connect nodes via `point(pic, dir)` boundary anchors. See the [picture guide](05-picture-guide.md) for the full `point()` reference.

---

## 1. Philosophy

A good system diagram answers: **What are the parts, and how do they relate?**

Key principles:

- **Nodes are `picture` components** — encapsulated in a function, returned as a `picture`, positioned with `shift()`
- **Arrows use `point()` anchors** — query a node's boundary (`N`, `S`, `E`, `W`, etc.) instead of manually computing `center ± half_width`
- **Grouping shows hierarchy** — clusters, layers, or logical boundaries
- **Color encodes role** — different colors for different types of entities
- **Minimal text in nodes** — name + one-line description; details go in captions

---

## 2. Configuration Pattern

All diagram parameters should be defined at the top as named constants. This makes the diagram easy to adjust and ensures consistency.

```asy
// Box dimensions — still needed for component function parameters
real bw       = 3.0;    // Box width
real bh       = 0.9;    // Box height
real gap      = 0.2;    // Gap between box edge and arrow tip

// Layout grid
real xMain    = 0;      // Center column x-coordinate
real xLeft    = -4.5;   // Left branch x-coordinate
real xRight   = 4.5;    // Right branch x-coordinate
real yTop     = 10;     // Top of the diagram
real dy       = 1.5;    // Vertical step between nodes
```

**Key difference from raw-coordinate approach:** You define `bw` and `bh` once for the component function, but you **never** write `bh/2` or `bw/2` in arrow code — `point()` handles that automatically.

---

## 3. Core Building Blocks

### 3.1 Node as a `picture`

The fundamental unit. A `picture`-returning function that draws a labeled box centered at the origin. Position is controlled externally by `shift()`.

```asy
// ==========================================
// NODE COMPONENT — returns a picture at origin
// ==========================================
picture label_box_pic(real bw, real bh, string[] lines,
                      pen fillPen, pen borderPen) {
    picture pic;
    pair bl = (-bw/2, -bh/2);
    pair tr = ( bw/2,  bh/2);
    fill(pic, box(bl, tr), fillPen);
    draw(pic, box(bl, tr), borderPen);
    real lineDy = 0.32;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

// Single-line overload
picture label_box_pic(real bw, real bh, string text,
                      pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, new string[]{text}, fillPen, borderPen);
}
```

**Usage — create, shift, then add to parent:**

```asy
real bw = 3.0, bh = 0.9;

picture box1 = shift(0, 2)    * label_box_pic(bw, bh, "Gateway", gatewayFill, gatewayBorder);
picture box2 = shift(0, -1)   * label_box_pic(bw, bh, new string[]{"Pod 1", "Agent + UI"}, workerFill, workerBorder);

picture diagram;
add(diagram, box1);
add(diagram, box2);
```

**Why `picture` instead of `void`?**
- `point(box1, S)` gives the south boundary — no `bh/2` math needed
- Moving a node only requires changing one `shift()` call — all arrows follow automatically
- The same component function produces nodes of any size — `point()` adapts

### 3.2 Connecting Nodes with `point()`

Arrow helpers take `picture` arguments and use `point()` to find boundary anchors. No manual `bh/2 + gap` calculations.

```asy
// ==========================================
// ARROW HELPERS — using point() boundary anchors
// ==========================================

// Vertical arrow: top node's south → bottom node's north
void arrowV(picture dest, picture top, picture bot,
            real gap=0.2, pen p=currentpen) {
    pair a = point(top, S) + (0, -gap);
    pair b = point(bot, N) + (0,  gap);
    draw(dest, a -- b, arrow = Arrow(TeXHead), p);
}

// Horizontal arrow: left node's east → right node's west
void arrowH(picture dest, picture left, picture right,
            real gap=0.2, pen p=currentpen) {
    pair a = point(left, E) + (gap, 0);
    pair b = point(right, W) + (-gap, 0);
    draw(dest, a -- b, arrow = Arrow(TeXHead), p);
}

// Branch: parent forks to left and right children
void arrowBranch(picture dest, picture parent,
                 picture leftChild, picture rightChild,
                 real gap=0.2, pen p=currentpen) {
    pair fork = point(parent, S);
    pair l = point(leftChild,  N) + (0, gap);
    pair r = point(rightChild, N) + (0, gap);
    pair mid = (fork.x, fork.y - 0.6);
    draw(dest, fork -- mid, p);
    draw(dest, mid -- l, arrow = Arrow(TeXHead), p);
    draw(dest, mid -- r, arrow = Arrow(TeXHead), p);
}

// Side node joins main from the left
void arrowJoinLeft(picture dest, picture side, picture main,
                   real gap=0.2, pen p=currentpen) {
    pair a = point(side, S) + (0, -gap);
    pair b = point(main, W) + (-gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), p);
}

// Side node joins main from the right
void arrowJoinRight(picture dest, picture side, picture main,
                    real gap=0.2, pen p=currentpen) {
    pair a = point(side, S) + (0, -gap);
    pair b = point(main, E) + (gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), p);
}

// Curved arrow (for crossing routes or long jumps)
void arrowCurve(picture dest, picture src, pair srcDir,
                picture tgt, pair tgtDir,
                real gap=0.2, pen p=currentpen) {
    pair a = point(src, srcDir) + gap * srcDir;
    pair b = point(tgt, tgtDir) + gap * tgtDir;
    draw(dest, a{right}..{right}b, arrow = Arrow(TeXHead), p);
}
```

**Why `Arrow(TeXHead)`?** It produces clean, small arrowheads that don't overwhelm the diagram. The default `Arrow` can be too large and intrusive.

**When to use straight vs. curved arrows:**

| Scenario | Use | Rationale |
|---------|-----|-----------|
| Simple top-down flow (parent → child directly below) | **Straight** | Clean, reads naturally as "next step" |
| Short horizontal link (sibling nodes at same y-level) | **Straight** or **subtle curve** | Direct relationship, no ambiguity |
| Cross-layer connection (node A at row 2 → node B at row 4, offset horizontally) | **Curve** | Avoids cutting through intermediate rows |
| Two parallel branches merging to a single node below | **Curved** (outward then inward) | Prevents crossing, visually separates incoming flows |
| One node branching to two side nodes | **Straight** with `arrowBranch` | Fork pattern, clean fan-out |
| Long-distance jump or feedback loop | **Curve** (wide arc) | Signals non-local relationship |

### 3.3 Cluster / Group Box

A large rectangle that encloses related components, with a label at the bottom or top.

```asy
// ==========================================
// CLUSTER BOX
// ==========================================
void drawCluster(pair min, pair max, string label,
                 pen fillPen = rgb(0.96, 0.96, 1.0),
                 pen borderPen = rgb(0.3, 0.3, 0.6) + linewidth(1.5)) {
    path p = box(min, max);
    filldraw(p, fillPen, borderPen);
    label(label, ((min.x + max.x)/2, min.y - 0.4), borderPen);
}

// Dashed logical group (no fill)
void drawDashedGroup(pair min, pair max, string label = "") {
    path p = box(min, max);
    draw(p, gray(0.5) + dashed + linewidth(1));
    if (label != "") {
        label("\small " + label, ((min.x + max.x)/2, max.y + 0.3), gray(0.5));
    }
}
```

Cluster boxes are drawn directly on the parent picture (not as sub-pictures) because they serve as background containers.

---

## 4. Color Coding System

Use color to distinguish entity roles at a glance.

| Role | Fill Color | Border Color | Example |
|------|-----------|-------------|---------|
| User / Client | `rgb(0.85,0.92,1.0)` | `rgb(0.2,0.4,0.6)` | Web browser, mobile app |
| Gateway / Proxy | `rgb(1.0,0.95,0.85)` | `rgb(0.5,0.35,0.15)` | Load balancer, API gateway |
| Router / Controller | `rgb(0.85,1.0,0.9)` | `rgb(0.15,0.45,0.3)` | Request router, scheduler |
| Worker / Pod | `rgb(1.0,0.95,0.8)` | `rgb(0.5,0.4,0.15)` | Compute nodes, containers |
| Storage / DB | `rgb(0.95,0.9,0.95)` | `rgb(0.4,0.3,0.5)` | Database, cache, object store |
| Result / Output | `rgb(0.9,1.0,0.95)` | `rgb(0.2,0.5,0.4)` | Response, output file |
| Cluster / Group | `rgb(0.96,0.96,1.0)` | `rgb(0.3,0.3,0.6)` | Bounding box for clusters |

```asy
// ==========================================
// COLOR PALETTE — Define once, use everywhere
// ==========================================
pen userFill     = rgb(0.85, 0.92, 1.0);
pen userBorder   = rgb(0.2, 0.4, 0.6) + linewidth(1.2);
pen gatewayFill  = rgb(1.0, 0.95, 0.85);
pen gatewayBorder= rgb(0.5, 0.35, 0.15) + linewidth(1.2);
pen routerFill   = rgb(0.85, 1.0, 0.9);
pen routerBorder = rgb(0.15, 0.45, 0.3) + linewidth(1.2);
pen workerFill   = rgb(1.0, 0.95, 0.8);
pen workerBorder = rgb(0.5, 0.4, 0.15) + linewidth(1.2);
pen resultFill   = rgb(0.9, 1.0, 0.95);
pen resultBorder = rgb(0.2, 0.5, 0.4) + linewidth(1.2);
```

---

## 5. Layout Patterns

### 5.1 Vertical Timeline (Top to Bottom)

For sequential workflows with parallel branches.

```asy
// ==========================================
// VERTICAL WORKFLOW WITH PARALLEL BRANCHES
// ==========================================
real bw = 3.0, bh = 0.9, gap = 0.2;
real xMain = 0, xLeft = -2.8, xRight = 2.8, yTop = 0, dy = 1.6;

// Colors (abbreviated — use full palette from §4)
pen doneFill = rgb(0.90, 1.00, 0.95), doneBorder = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen prepFill = rgb(1.00, 0.97, 0.90), prepBorder = rgb(0.50, 0.40, 0.20) + linewidth(1.2);
pen cookFill = rgb(1.00, 0.92, 0.85), cookBorder = rgb(0.60, 0.35, 0.15) + linewidth(1.2);
pen arrowPen = rgb(0.30, 0.20, 0.10) + linewidth(0.9);

// --- Create and position nodes ---
picture pStart = shift(xMain,  yTop)          * label_box_pic(bw, bh, "Start", doneFill, doneBorder);
picture pPrep  = shift(xMain,  yTop - dy)     * label_box_pic(bw, bh, new string[]{"Prep", "wash & measure"}, prepFill, prepBorder);
picture pCut   = shift(xLeft,  yTop - 2*dy)   * label_box_pic(bw, bh, "Cut", prepFill, prepBorder);
picture pBeat  = shift(xRight, yTop - 2*dy)   * label_box_pic(bw, bh, "Beat", prepFill, prepBorder);
picture pCook  = shift(xMain,  yTop - 3*dy)   * label_box_pic(bw, bh, "Cook", cookFill, cookBorder);

// --- Assemble ---
picture diagram;
size(diagram, 10cm);

// Arrows (drawn first → behind nodes)
arrowV(diagram, pStart, pPrep, gap, arrowPen);       // Start → Prep
arrowBranch(diagram, pPrep, pCut, pBeat, gap, arrowPen);  // Prep → Cut, Beat
arrowJoinLeft(diagram, pCut, pCook, gap, arrowPen);   // Cut → Cook
arrowJoinRight(diagram, pBeat, pCook, gap, arrowPen); // Beat → Cook

// Add nodes on top of arrows
add(diagram, pStart);
add(diagram, pPrep);
add(diagram, pCut);
add(diagram, pBeat);
add(diagram, pCook);

shipout(shift(-min(diagram, true)) * diagram);
```

### 5.2 Horizontal Pipeline (Left to Right)

For sequential data flow: ingest → process → output.

```asy
// ==========================================
// HORIZONTAL PIPELINE
// ==========================================
real bw = 3.0, bh = 0.9, gap = 0.2;
real yMain = 0, dx = 4.0, xStart = -6;

// Colors
pen userFill = rgb(0.85, 0.92, 1.0),    userBorder = rgb(0.2, 0.4, 0.6) + linewidth(1.2);
pen gateFill = rgb(1.0, 0.95, 0.85),     gateBorder = rgb(0.5, 0.35, 0.15) + linewidth(1.2);
pen workFill = rgb(1.0, 0.95, 0.8),      workBorder = rgb(0.5, 0.4, 0.15) + linewidth(1.2);
pen resFill  = rgb(0.9, 1.0, 0.95),      resBorder  = rgb(0.2, 0.5, 0.4) + linewidth(1.2);
pen arrowPen = rgb(0.2, 0.2, 0.2) + linewidth(0.9);

// --- Create and position nodes ---
picture pUser    = shift(xStart,        yMain) * label_box_pic(bw, bh, "User",    userFill, userBorder);
picture pGateway = shift(xStart + dx,   yMain) * label_box_pic(bw, bh, "Gateway", gateFill, gateBorder);
picture pCore    = shift(xStart + 2*dx, yMain) * label_box_pic(bw, bh, "Core",    workFill, workBorder);
picture pResult  = shift(xStart + 3*dx, yMain) * label_box_pic(bw, bh, "Result",  resFill,  resBorder);

// --- Assemble ---
picture diagram;
size(diagram, 12cm);

arrowH(diagram, pUser,    pGateway, gap, arrowPen);
arrowH(diagram, pGateway, pCore,    gap, arrowPen);
arrowH(diagram, pCore,    pResult,  gap, arrowPen);

add(diagram, pUser);
add(diagram, pGateway);
add(diagram, pCore);
add(diagram, pResult);

shipout(shift(-min(diagram, true)) * diagram);
```

### 5.3 Cluster with Internal Dispatch

For systems with a router dispatching to multiple workers inside a cluster.

```asy
// ==========================================
// CLUSTER WITH DISPATCH
// ==========================================
real bw = 3.0, bh = 0.9, gap = 0.2;

pen routerFill  = rgb(0.85, 1.0, 0.9),  routerBorder = rgb(0.15, 0.45, 0.3) + linewidth(1.2);
pen workerFill  = rgb(1.0, 0.95, 0.8),  workerBorder = rgb(0.5, 0.4, 0.15) + linewidth(1.2);
pen clusterFill = rgb(0.96, 0.96, 1.0), clusterPen   = rgb(0.3, 0.3, 0.6) + linewidth(1.8);
pen dispatchPen = gray + linewidth(0.7) + dashed;

// Nodes inside the cluster
picture pRouter = shift(5.5, -0.5) * label_box_pic(bw, bh, new string[]{"Router", "Unique Instance"}, routerFill, routerBorder);
picture pPod1   = shift(3.0, -2.5) * label_box_pic(bw, bh, new string[]{"Pod 1", "Agent + UI"}, workerFill, workerBorder);
picture pPod2   = shift(5.5, -2.5) * label_box_pic(bw, bh, new string[]{"Pod 2", "Agent + UI"}, workerFill, workerBorder);
picture pPod3   = shift(8.0, -2.5) * label_box_pic(bw, bh, new string[]{"Pod N", "Agent + UI"}, workerFill, workerBorder);

picture diagram;
size(diagram, 12cm);

// Cluster background (drawn first)
drawCluster((1.5, -3.5), (9.5, 0.5), "Inference Cluster", clusterFill, clusterPen);

// Dispatch lines: Router → each Pod (using point() for precise anchors)
pair routerSouth = point(pRouter, S) + (0, -gap);
for (picture pod : new picture[] {pPod1, pPod2, pPod3}) {
    pair podNorth = point(pod, N) + (0, gap);
    pair bend = (routerSouth.x, routerSouth.y - 0.8);
    draw(diagram, routerSouth -- bend -- (podNorth.x, bend.y) -- podNorth,
         dispatchPen);
}

add(diagram, pRouter);
add(diagram, pPod1);
add(diagram, pPod2);
add(diagram, pPod3);

shipout(diagram);
```

---

## 6. Annotations

### 6.1 Layer Labels (Top)

For complex systems, add layer annotations on the left so readers know which architectural level they're viewing.

```asy
// Use point() to align annotations with node positions
label(diagram, "Web Canvas",  (xLeft - 2.2, point(pUser, N).y + 0.5), fontsize(8pt));
label(diagram, "Frontend",    (xLeft - 2.2, point(pUser, N).y + 0.1), fontsize(7pt) + gray);

label(diagram, "Permission",  (xLeft - 2.2, point(pGateway, N).y + 0.5), fontsize(8pt));
label(diagram, "Gateway",     (xLeft - 2.2, point(pGateway, N).y + 0.1), fontsize(7pt) + gray);
```

### 6.2 Step Numbering (Bottom)

For complex diagrams, add numbered steps below the diagram.

```asy
// Derive y position from the lowest node
real ySteps = point(pResult, S).y - 2.0;

label(diagram, "1. Send",     (point(pUser, S).x, ySteps), fontsize(8pt));
label(diagram, "2. Auth",     (point(pGateway, S).x, ySteps), fontsize(8pt));
label(diagram, "3. Route",    (point(pRouter, S).x, ySteps), fontsize(8pt));
label(diagram, "4. Dispatch", (point(pRouter, S).x, ySteps - 0.5), fontsize(8pt));
label(diagram, "5. Parallel", (point(pPod2, S).x, ySteps), fontsize(8pt));
label(diagram, "6. Merge",    (point(pResult, S).x, ySteps), fontsize(8pt));

// Dashed line above steps
draw(diagram, (point(pUser, W).x - 2, ySteps + 0.5)
           -- (point(pResult, E).x + 2, ySteps + 0.5),
      gray + dashed + linewidth(0.5));
```

### 6.3 Phase Dividers

For timelines, add horizontal dashed lines to separate phases.

```asy
// Midpoint between two node rows
real yDivider = (point(pPhase1, S).y + point(pPhase2, N).y) / 2;
draw(diagram, (xLeft - 1, yDivider) -- (xRight + 1, yDivider),
      gray + linewidth(0.5) + dashed);
label(diagram, "Yongle Reign", (xLeft - 1.8, yDivider), fontsize(7pt) + gray);
```

---

## 7. Complete Example: System Architecture

This example demonstrates a full system architecture diagram — layered components with clustering, dispatch, and step annotations.

```asy
// ==========================================
// SYSTEM ARCHITECTURE: REQUEST FLOW
// ==========================================

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw         = 3.8;
real bh         = 1.2;
real gap        = 0.2;
real dx         = 4.5;
real yTop       = 3.5;
real yBot       = -3.5;
real xStart     = -11;

// Colors
pen userColor    = rgb(0.90, 0.95, 1.00);  pen userBorder    = black + 1.2pt;
pen gatewayColor = rgb(1.00, 0.95, 0.85);  pen gatewayBorder = black + 1.2pt;
pen routerColor  = rgb(0.85, 1.00, 0.90);  pen routerBorder  = black + 1.2pt;
pen podColor     = rgb(1.00, 0.95, 0.75);  pen podBorder     = black + 1.2pt;
pen resultColor  = rgb(0.85, 1.00, 0.95);  pen resultBorder  = black + 1.2pt;
pen clusterFill  = rgb(0.96, 0.96, 0.99);
pen clusterPen   = rgb(0.3, 0.3, 0.6) + linewidth(1.8);
pen arrowPen     = rgb(0.2, 0.2, 0.2) + linewidth(0.9);
pen dispatchPen  = gray + linewidth(0.7) + dashed;

// ------------------------------------------
// NODE COMPONENT
// ------------------------------------------
picture label_box_pic(real bw, real bh, string[] lines,
                      pen fillPen, pen borderPen) {
    picture pic;
    fill(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), fillPen);
    draw(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), borderPen);
    real lineDy = 0.36;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

picture label_box_pic(real bw, real bh, string text,
                      pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, new string[]{text}, fillPen, borderPen);
}

// ------------------------------------------
// CREATE AND POSITION NODES
// ------------------------------------------
picture pUser    = shift(xStart,          yTop)        * label_box_pic(bw, bh, new string[]{"User", "bizyair.cn Canvas"}, userColor, userBorder);
picture pSCX     = shift(xStart + dx,     yTop)        * label_box_pic(bw, bh, new string[]{"SCX Gateway", "Auth, Quota, Billing"}, gatewayColor, gatewayBorder);
picture pCGR     = shift(xStart + 3*dx,   yTop - 1.5) * label_box_pic(bw, bh, new string[]{"CGR Router", "Unique Instance"}, routerColor, routerBorder);
picture pPod1    = shift(xStart + 2.5*dx, yBot)        * label_box_pic(bw, bh, new string[]{"Pod 1", "ComfyAgent + ComfyUI"}, podColor, podBorder);
picture pPod2    = shift(xStart + 3.5*dx, yBot)        * label_box_pic(bw, bh, new string[]{"Pod 2", "ComfyAgent + ComfyUI"}, podColor, podBorder);
picture pPodN    = shift(xStart + 5.5*dx, yBot)        * label_box_pic(bw, bh, new string[]{"Pod N", "ComfyAgent + ComfyUI"}, podColor, podBorder);
picture pResult  = shift(xStart + 7.0*dx, (yTop+yBot)/2) * label_box_pic(bw, bh, new string[]{"Result", "Image / Video / Data"}, resultColor, resultBorder);

// ------------------------------------------
// ASSEMBLE DIAGRAM
// ------------------------------------------
picture diagram;
size(diagram, 20cm);

// --- Title ---
label(diagram, "BizyAir.cn Architecture: Request Flow", (0, 7.5), fontsize(16pt));

// --- Cluster background ---
pair cbl = (xStart + 2.0*dx - bw/2 - 0.3, yTop - 0.5);
pair ctr = (xStart + 5.2*dx + bw/2 + 1.8, yBot - bh/2 - 1);
fill(diagram, box(cbl, ctr), clusterFill);
draw(diagram, box(cbl, ctr), clusterPen);
label(diagram, "Inference Core Cluster", ((cbl.x + ctr.x)/2, ctr.y + 0.5),
      fontsize(11pt) + rgb(0.3, 0.3, 0.6));

// --- Arrows (drawn before nodes → behind nodes) ---

// User → SCX (horizontal)
pair uEast  = point(pUser, E) + (gap, 0);
pair sWest  = point(pSCX,  W) + (-gap, 0);
draw(diagram, uEast -- sWest, arrow = Arrow(TeXHead), arrowPen);

// SCX → CGR (curved)
pair sEast  = point(pSCX, E) + (gap, 0);
pair cWest  = point(pCGR, W) + (-gap, 0);
draw(diagram, sEast{E}..{E}cWest, arrow = Arrow(TeXHead), arrowPen);

// CGR → Pods (dashed dispatch)
pair cgrSouth = point(pCGR, S) + (0, -gap);
for (picture pod : new picture[] {pPod1, pPod2, pPodN}) {
    pair podNorth = point(pod, N) + (0, gap);
    pair bend = (cgrSouth.x, cgrSouth.y - 0.8);
    draw(diagram, cgrSouth -- bend -- (podNorth.x, bend.y) -- podNorth,
         dispatchPen);
}

// Pods → Result (curved, dashed)
pair podEast  = point(pPodN, E) + (gap, 0);
pair resWest  = point(pResult, W) + (-gap, 0);
draw(diagram, podEast{E}..{E}resWest,
     arrow = Arrow(TeXHead), arrowPen + dashed);

// --- Add nodes on top of arrows ---
add(diagram, pUser);
add(diagram, pSCX);
add(diagram, pCGR);
add(diagram, pPod1);
add(diagram, pPod2);
add(diagram, pPodN);
add(diagram, pResult);

// --- Step numbering ---
real ySteps = point(pResult, S).y - 2.5;
label(diagram, "1. Send",     (point(pUser,  S).x, ySteps), fontsize(8pt));
label(diagram, "2. Auth",     (point(pSCX,   S).x, ySteps), fontsize(8pt));
label(diagram, "3. Route",    (point(pCGR,   S).x, ySteps), fontsize(8pt));
label(diagram, "4. Dispatch", (point(pCGR,   S).x, ySteps - 0.5), fontsize(8pt));
label(diagram, "5. Parallel", (point(pPod2,  S).x, ySteps), fontsize(8pt));
label(diagram, "6. Merge",    (point(pResult,S).x, ySteps), fontsize(8pt));

// --- Top annotations ---
real yAnnTopMain = yTop + 2.2;
real yAnnSubMain = yTop + 1.8;
label(diagram, "Web Canvas", (point(pUser,   S).x, yAnnTopMain), fontsize(8pt));
label(diagram, "Frontend",   (point(pUser,   S).x, yAnnSubMain), fontsize(7pt) + gray);
label(diagram, "Permission", (point(pSCX,    S).x, yAnnTopMain), fontsize(8pt));
label(diagram, "Gateway",    (point(pSCX,    S).x, yAnnSubMain), fontsize(7pt) + gray);
label(diagram, "Cluster",    (point(pCGR,    S).x, yAnnTopMain), fontsize(8pt));
label(diagram, "Router",     (point(pCGR,    S).x, yAnnSubMain), fontsize(7pt) + gray);
label(diagram, "Return",     (point(pResult, S).x, yAnnTopMain), fontsize(8pt));
label(diagram, "Output",     (point(pResult, S).x, yAnnSubMain), fontsize(7pt) + gray);

// --- Legend ---
label(diagram, "FaaS: Function-as-a-Service / CGR: Comfy Grid Runtime / SCX: Service Control X",
      (0, yBot - 3.5), fontsize(9pt));

shipout(diagram);
```

---

## 8. Complete Example: Cooking Workflow (Tomato Scrambled Eggs)

A workflow diagram showing the steps of cooking tomato scrambled eggs, with parallel preparation paths.

```asy
// ==========================================
// WORKFLOW: TOMATO SCRAMBLED EGGS
// Using picture + point() for modular node composition
// ==========================================

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw       = 3.0;
real bh       = 0.9;
real gap      = 0.25;
real nodeDy   = 1.6;

real xMain   = 0;
real xLeftB  = -2.8;   // left branch x
real xRightB =  2.8;   // right branch x
real y0      = 0;      // top of main column

pen prepFill    = rgb(1.00, 0.97, 0.90);
pen prepBorder  = rgb(0.50, 0.40, 0.20) + linewidth(1.2);
pen cookFill    = rgb(1.00, 0.92, 0.85);
pen cookBorder  = rgb(0.60, 0.35, 0.15) + linewidth(1.2);
pen doneFill    = rgb(0.90, 1.00, 0.95);
pen doneBorder  = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen arrowPen    = rgb(0.30, 0.20, 0.10) + linewidth(0.9);

// ------------------------------------------
// NODE COMPONENT — returns picture centered at origin
// ------------------------------------------
picture label_box_pic(real bw, real bh, string[] lines,
                      pen fillPen, pen borderPen) {
    picture pic;
    fill(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), fillPen);
    draw(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), borderPen);
    real lineDy = 0.32;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

picture label_box_pic(real bw, real bh, string text,
                      pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, new string[]{text}, fillPen, borderPen);
}

// ------------------------------------------
// ARROW HELPERS — using point() boundary anchors
// ------------------------------------------
void arrowDown(picture dest, picture top, picture bot) {
    pair a = point(top, S) + (0, -gap);
    pair b = point(bot, N) + (0,  gap);
    draw(dest, a -- b, arrow = Arrow(TeXHead), arrowPen);
}

void arrowBranch(picture dest, picture parent,
                 picture leftChild, picture rightChild) {
    pair p = point(parent, S);
    pair l = point(leftChild,  N) + (0, gap);
    pair r = point(rightChild, N) + (0, gap);
    pair fork = (p.x, p.y - 0.6);
    draw(dest, p -- fork, arrowPen);
    draw(dest, fork -- l, arrow = Arrow(TeXHead), arrowPen);
    draw(dest, fork -- r, arrow = Arrow(TeXHead), arrowPen);
}

void arrowJoinLeft(picture dest, picture side, picture main) {
    pair a = point(side, S) + (0, -gap);
    pair b = point(main,  W) + (-gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), arrowPen);
}

void arrowJoinRight(picture dest, picture side, picture main) {
    pair a = point(side, S) + (0, -gap);
    pair b = point(main,  E) + (gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), arrowPen);
}

// ------------------------------------------
// BUILD DIAGRAM
// ------------------------------------------

// --- Create and position nodes (shift baked into each picture) ---
picture pStart  = shift(xMain,   y0)            * label_box_pic(bw, bh, "Start", doneFill, doneBorder);
picture pPrep   = shift(xMain,   y0 - nodeDy)   * label_box_pic(bw, bh, new string[]{"Prep", "wash \& measure"}, prepFill, prepBorder);
picture pCut    = shift(xLeftB,  y0 - 2*nodeDy) * label_box_pic(bw, bh, "Cut Tomato", prepFill, prepBorder);
picture pBeat   = shift(xRightB, y0 - 2*nodeDy) * label_box_pic(bw, bh, "Beat Eggs", prepFill, prepBorder);
picture pHeat   = shift(xMain,   y0 - 3*nodeDy) * label_box_pic(bw, bh, "Heat Oil", cookFill, cookBorder);
picture pFryE   = shift(xMain,   y0 - 4*nodeDy) * label_box_pic(bw, bh, "Fry Eggs", cookFill, cookBorder);
picture pFryT   = shift(xMain,   y0 - 5*nodeDy) * label_box_pic(bw, bh, "Fry Tomato", cookFill, cookBorder);
picture pMix    = shift(xMain,   y0 - 6*nodeDy) * label_box_pic(bw, bh, "Mix", cookFill, cookBorder);
picture pSeason = shift(xMain,   y0 - 7*nodeDy) * label_box_pic(bw, bh, "Season", cookFill, cookBorder);
picture pDone   = shift(xMain,   y0 - 8*nodeDy) * label_box_pic(bw, bh, "Serve", doneFill, doneBorder);

// --- Assemble ---
picture diagram;

// Arrows (drawn first → behind nodes)
arrowDown(diagram, pStart, pPrep);
arrowBranch(diagram, pPrep, pCut, pBeat);
arrowJoinLeft(diagram, pCut, pHeat);
arrowJoinRight(diagram, pBeat, pHeat);
arrowDown(diagram, pHeat, pFryE);
arrowDown(diagram, pFryE, pFryT);
arrowDown(diagram, pFryT, pMix);
arrowDown(diagram, pMix, pSeason);
arrowDown(diagram, pSeason, pDone);

// Add nodes on top of arrows
add(diagram, pStart);
add(diagram, pPrep);
add(diagram, pCut);
add(diagram, pBeat);
add(diagram, pHeat);
add(diagram, pFryE);
add(diagram, pFryT);
add(diagram, pMix);
add(diagram, pSeason);
add(diagram, pDone);

// --- Title ---
label(diagram, "\textbf{Workflow: Tomato Scrambled Eggs}",
      (xMain, y0 + 1.2), fontsize(14pt));

// --- Side annotations (using point() for y-alignment) ---
real xAnnotLeft  = xLeftB  - 2.2;
real xAnnotRight = xRightB + 2.2;

label(diagram, "Ingredients", (xAnnotLeft,  point(pPrep,   N).y - bh/2), fontsize(8pt));
label(diagram, "Tomato",      (xAnnotLeft,  point(pCut,  S).y + 0.35), fontsize(8pt));
label(diagram, "Eggs",        (xAnnotLeft,  point(pBeat, S).y - 0.35), fontsize(8pt));
label(diagram, "Cooking",     (xAnnotLeft,  point(pHeat, S).y),        fontsize(8pt));
label(diagram, "Medium heat", (xAnnotLeft,  point(pFryE, S).y),        fontsize(8pt));
label(diagram, "Stir-fry",    (xAnnotLeft,  point(pFryT, S).y),        fontsize(8pt));
label(diagram, "Combine",     (xAnnotLeft,  point(pMix,  S).y),        fontsize(8pt));
label(diagram, "Salt",        (xAnnotLeft,  point(pSeason,S).y),       fontsize(8pt));

label(diagram, "2 tomatoes",  (xAnnotRight, point(pCut,   S).y + 0.35), fontsize(8pt));
label(diagram, "3 eggs",      (xAnnotRight, point(pBeat,  S).y - 0.35), fontsize(8pt));
label(diagram, "1 min",       (xAnnotRight, point(pFryE,  S).y),        fontsize(8pt));
label(diagram, "2 min",       (xAnnotRight, point(pFryT,  S).y),        fontsize(8pt));
label(diagram, "Quick toss",  (xAnnotRight, point(pMix,   S).y),        fontsize(8pt));
label(diagram, "Pinch",       (xAnnotRight, point(pSeason,S).y),        fontsize(8pt));
label(diagram, "Enjoy!",      (xAnnotRight, point(pDone,  S).y),        fontsize(8pt));

// --- Step numbering ---
real ySteps = y0 - 9.5*nodeDy;
label(diagram, "1. Prep",     (xMain - 3.5, ySteps), fontsize(8pt));
label(diagram, "2. Parallel", (xMain - 1.0, ySteps), fontsize(8pt));
label(diagram, "3. Heat",     (xMain + 1.0, ySteps), fontsize(8pt));
label(diagram, "4. Cook",     (xMain + 3.0, ySteps), fontsize(8pt));
label(diagram, "5. Serve",    (xMain + 5.0, ySteps), fontsize(8pt));

// --- Bottom quote ---
label(diagram, "\"The secret to great tomato eggs is frying the eggs until fluffy.\"",
      (xMain, y0 - 10.5*nodeDy), fontsize(9pt));

// ------------------------------------------
// CENTER AND SHIP
// ------------------------------------------
shipout(shift(-min(diagram, true)) * diagram);
```

---

## 9. Style Guide Summary

| Element | Usage | Style |
|---------|-------|-------|
| Component box | Individual service/node/stage | `picture`-returning function, centered at `(0,0)` |
| Component placement | Positioning in parent picture | `shift(x, y) * component(args)` |
| Arrow endpoints | Connecting nodes | `point(node, dir)` — no manual `bh/2` math |
| Cluster box | Group of related components | Large rectangle, light fill, bold border |
| Dashed group | Logical/optional grouping | Dashed border, no fill |
| Solid arrow | Primary data/control flow | `Arrow(TeXHead)`, 0.9bp |
| Dashed arrow | Internal dispatch, secondary flow | Gray, dashed, 0.7bp |
| Curved arrow | Avoid crossing other lines | Bezier curve with `{dir}..{dir}` |
| Layer label | Annotate architectural layer | Left-aligned gray text, y-aligned with `point()` |
| Step number | Bottom timeline annotation | Small gray text, evenly spaced |
| Node text | Name + one-line description | Name centered, description below in gray |

---

## 10. Common Pitfalls

1. **Computing arrow endpoints manually** — Use `point(node, S)` instead of `center.y - bh/2 - gap`. `point()` adapts automatically to any box size and transform.

2. **Overcrowding nodes** — Keep to name + one short line. Put details in side annotations or captions.

3. **Inconsistent arrow styles** — Use solid for main flow, dashed for internal/subordinate flow.

4. **Missing cluster labels** — Every bounding box should have a label indicating what the group represents.

5. **Arrow crossings** — Route around clusters or use curves. Avoid crossing solid arrows.

6. **Monochrome diagrams** — Use the color palette to distinguish roles. Color is faster to parse than text.

7. **No layer context** — For complex systems, add layer annotations on the left so readers know which architectural level they're viewing.

8. **Using `void` node functions instead of `picture`-returning functions** — A `void boxLabel(pair c, ...)` function draws directly on `currentpicture`, making it impossible to query boundary anchors or reposition the node later. Always use `picture label_box_pic(...)` so you can `point()` and `shift()`.

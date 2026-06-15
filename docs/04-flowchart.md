# Diagrams of Systems, Flows, and Relationships

This document covers how to create **system architecture diagrams**, **data flow diagrams**, **model architecture diagrams**, and **workflow diagrams** using Asymptote's default primitives. These diagrams express relationships between entities — components, stages, layers, or tasks — rather than rigid algorithmic control flow.

The `flowchart` standard module is intentionally **not used** here. Its shapes (Start/End ovals, Decision diamonds) are too restrictive for system diagrams. Default primitives provide full control over layout, grouping, and arrow styling.

---

## 1. Philosophy

A good system diagram answers: **What are the parts, and how do they relate?**

Key principles:

- **Nodes are entities** — components, services, layers, stages, or actors
- **Edges are relationships** — data flow, control flow, dependency, or dispatch
- **Grouping shows hierarchy** — clusters, layers, or logical boundaries
- **Color encodes role** — different colors for different types of entities
- **Minimal text in nodes** — name + one-line description; details go in captions
- **Precise coordinate calculation** — Asymptote's strength is exact positioning. Use variables and arithmetic to compute every coordinate, rather than relying on margin/heuristic parameters.

---

## 2. Configuration Pattern

All diagram parameters should be defined at the top as named constants. This makes the diagram easy to adjust and ensures consistency.

```asy
unitsize(1.0cm);       // Set the base unit for the diagram

// Coordinate system anchors
real xMain    = 0;      // Center column x-coordinate
real xLeft    = -4.5;   // Left annotation column
real xRight   = 4.5;    // Right annotation column
real yTop     = 10;     // Top of the diagram

// Spacing
real dy       = 1.5;    // Vertical step between nodes
real bw       = 3.0;    // Box width
real bh       = 0.9;    // Box height
real gap      = 0.2;    // Gap between box and arrow
```

**Key insight:** By defining `bw` (box width) and `bh` (box height) once, all helper functions can compute exact coordinates. No magic numbers repeated throughout the code.

---

## 3. Core Building Blocks

### 3.1 Component Box (The Basic Node)

The fundamental unit. A rectangle with a name and optional subtitle.

```asy
// ==========================================
// COMPONENT BOX
// ==========================================
void boxLabel(pair c, string[] lines, pen fillpen, pen borderpen) {
    pair bl = c + (-bw/2, -bh/2);   // bottom-left corner
    pair tr = c + (bw/2, bh/2);     // top-right corner
    fill(box(bl, tr), fillpen);
    draw(box(bl, tr), borderpen);
    real lineDy = 0.32;              // line spacing inside box
    real y0 = c.y + (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(lines[i], (c.x, y0 - i * lineDy), fontsize(9pt));
}

// Single-line overload
void boxLabel(pair c, string text, pen fillpen, pen borderpen) {
    string[] lines = {text};
    boxLabel(c, lines, fillpen, borderpen);
}
```

**Usage:**

```asy
pen userFill    = rgb(0.85, 0.92, 1.0);
pen userBorder  = rgb(0.2, 0.4, 0.6) + linewidth(1.2);

boxLabel((0, 0), "SCX Gateway", userFill, userBorder);
boxLabel((0, 0), new string[]{"SCX Gateway", "Auth, Quota, Billing"}, userFill, userBorder);
```

### 3.2 Precise Arrow Functions

**Never use `margin=EndMargin` or similar heuristic parameters.** Instead, compute the exact start and end points using box dimensions and the `gap` constant.

```asy
// ==========================================
// ARROW HELPERS — Precise coordinate calculation
// ==========================================

// Vertical arrow: connects bottom of topBox to top of botBox
void arrV(pair topBox, pair botBox, pen p) {
    pair start = (topBox.x, topBox.y - bh/2 - gap);
    pair end   = (botBox.x, botBox.y + bh/2 + gap);
    draw(start -- end, arrow = Arrow(TeXHead), p);
}

// Horizontal arrow: connects right of leftBox to left of rightBox
void arrH(pair leftBox, pair rightBox, pen p) {
    pair start = (leftBox.x + bw/2 + gap, leftBox.y);
    pair end   = (rightBox.x - bw/2 - gap, rightBox.y);
    draw(start -- end, arrow = Arrow(TeXHead), p);
}

// Orthogonal merge: side branch back to main flow
void arrMerge(pair sideBox, pair mainBox, pen p) {
    pair a = (sideBox.x, sideBox.y - bh/2 - gap);
    pair b = (mainBox.x - bw/2 - gap, mainBox.y);
    draw(a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), p);
}

// Curved arrow (for crossing routes or long jumps)
void arrCurve(pair from, pair to, real bend, pen p) {
    draw(from{right}..{right}to, arrow = Arrow(TeXHead), p);
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
| One node branching to two side nodes | **Curved** (fork shape) | Distributes arrows cleanly without overlap |
| Long-distance jump or feedback loop | **Curved** (wide arc) | Signals "绕行" or non-local relationship |
| Reverse-direction flow (right node → left node) | **Curved** (S-shape) | Avoids head-on collision with main flow |

**Rule of thumb:** If a straight arrow would pass through another node, cross another arrow, or create visual confusion → use a curve. Straight arrows are for "obvious next step"; curves are for "绕行 to avoid obstacles".

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

### 3.4 Picture-Based Modular Composition (Advanced)

For diagrams with **more than 5 nodes**, parallel branches, or multi-level layouts, the `pair`-coordinate approach becomes fragile. When you move one node, you must manually update all arrows and annotations tied to it.

Asymptote's `picture` type solves this by embedding position information into the node itself. Once placed, you query its absolute anchor points (`N`, `S`, `E`, `W`, `NE`, etc.) to draw arrows and labels. This mirrors the pattern used in `examples/long_timeline.asy`.

**When to use which approach:**

| Diagram size | Approach | Rationale |
|-------------|----------|-----------|
| ≤ 5 nodes | `pair` + `boxLabel()` | Less boilerplate, quick to write |
| > 5 nodes, parallel branches, clusters | `picture` + `add()` | Nodes self-contained; arrows auto-follow |

**Core idea:**

```asy
// 1. Build a node as a picture centered at (0,0)
picture makeNode(string text, pen fillpen, pen borderpen) {
    picture pic;
    pair bl = (-bw/2, -bh/2);
    pair tr = ( bw/2,  bh/2);
    fill(pic, box(bl, tr), fillpen);
    draw(pic, box(bl, tr), borderpen);
    label(pic, text, fontsize(9pt));
    return pic;
}

// 2. Place it by baking shift into the picture itself
picture nodeA = shift(0,  0) * makeNode("Start", doneFill, doneBorder);
picture nodeB = shift(0, -2) * makeNode("Process", cookFill, cookBorder);

// 3. Add to a parent picture
picture diagram;
add(diagram, nodeA);
add(diagram, nodeB);

// 4. Draw arrows using the picture's absolute anchor points
draw(diagram, point(nodeA, S) -- point(nodeB, N),
     arrow = Arrow(TeXHead));

// 5. Center and ship
diagram = shift(-min(diagram, true)) * diagram;
add(diagram);
```

**Key advantages:**
- `point(node, S)` returns the absolute south edge after `shift` — no manual `bh/2` math
- Moving a node only requires changing one `shift(x,y)` call; arrows and labels follow automatically
- Parallel nodes at the same y-level no longer cause annotation overlap (offset with `±dy`)

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
unitsize(1.0cm);

real xMain = 0, xLeft = -4.5, xRight = 4.5;
real yTop = 10, dy = 1.5;
real bw = 3.0, bh = 0.9, gap = 0.2;

// Define colors...

// Node positions
pair pStart = (xMain, yTop);
pair pPrep  = (xMain, yTop - dy);
pair pCut   = (xMain - 3.0, yTop - 2*dy);   // left branch
pair pBeat  = (xMain + 3.0, yTop - 2*dy);   // right branch
pair pCook  = (xMain, yTop - 3*dy);
// ...etc

// Draw nodes
boxLabel(pStart, "Start", doneFill, doneBorder);
boxLabel(pPrep, new string[]{"Prep", "wash & measure"}, prepFill, prepBorder);
boxLabel(pCut, "Cut", prepFill, prepBorder);
boxLabel(pBeat, "Beat", prepFill, prepBorder);
boxLabel(pCook, "Cook", cookFill, cookBorder);

// Draw arrows (precise endpoints)
arrV(pStart, pPrep, arrowPen);
arrH(pPrep, pCut, arrowPen);
arrH(pPrep, pBeat, arrowPen);
arrMerge(pCut, pCook, arrowPen);
arrMerge(pBeat, pCook, arrowPen);
```

### 5.2 Horizontal Pipeline (Left to Right)

For sequential data flow: ingest → process → output.

```asy
// ==========================================
// HORIZONTAL PIPELINE
// ==========================================
unitsize(1.1cm);

real yMain = 0;
real dx = 4.5;
real xStart = -8;

pair pUser    = (xStart, yMain);
pair pGateway = (xStart + dx, yMain);
pair pCore    = (xStart + 2*dx, yMain);
pair pResult  = (xStart + 3*dx, yMain);

boxLabel(pUser, "User", userFill, userBorder);
boxLabel(pGateway, "Gateway", gatewayFill, gatewayBorder);
boxLabel(pCore, "Core", workerFill, workerBorder);
boxLabel(pResult, "Result", resultFill, resultBorder);

arrH(pUser, pGateway, arrowPen);
arrH(pGateway, pCore, arrowPen);
arrH(pCore, pResult, arrowPen);
```

### 5.3 Cluster with Internal Dispatch

For systems with a router dispatching to multiple workers inside a cluster.

```asy
// ==========================================
// CLUSTER WITH DISPATCH
// ==========================================

// Cluster bounding box
pair cbl = (1.5, -3.5);
pair ctr = (9.5, 0.5);
drawCluster(cbl, ctr, "Inference Cluster", clusterFill, clusterBorder);

// Router at top center of cluster
pair pRouter = (5.5, -0.5);
boxLabel(pRouter, new string[]{"Router", "Unique Instance"}, routerFill, routerBorder);

// Worker pods below
pair pPod1 = (3.0, -2.5);
pair pPod2 = (5.5, -2.5);
pair pPod3 = (8.0, -2.5);

boxLabel(pPod1, new string[]{"Pod 1", "Agent + UI"}, workerFill, workerBorder);
boxLabel(pPod2, new string[]{"Pod 2", "Agent + UI"}, workerFill, workerBorder);
boxLabel(pPod3, new string[]{"Pod N", "Agent + UI"}, workerFill, workerBorder);

// Dashed dispatch lines from router to pods
pen dispatchPen = gray + linewidth(0.7) + dashed;
pair cgrBot = (pRouter.x, pRouter.y - bh/2 - gap);

for (pair pod : new pair[] {pPod1, pPod2, pPod3}) {
    pair podTop = (pod.x, pod.y + bh/2 + gap);
    draw(cgrBot -- (cgrBot.x, cgrBot.y - 0.8) -- (podTop.x, cgrBot.y - 0.8) -- podTop,
         dispatchPen);
}
```

---

## 6. Annotations

### 6.1 Layer Labels (Top)

For complex systems, add layer annotations on the left so readers know which architectural level they're viewing.

```asy
label("Web Canvas",  (xLeft, pUser.y + 1.5), fontsize(8pt));
label("Frontend",    (xLeft, pUser.y + 1.1), fontsize(7pt) + gray);

label("Permission",  (xLeft, pGateway.y + 1.5), fontsize(8pt));
label("Gateway",     (xLeft, pGateway.y + 1.1), fontsize(7pt) + gray);

label("Cluster",     (xLeft, pRouter.y + 1.5), fontsize(8pt));
label("Router",      (xLeft, pRouter.y + 1.1), fontsize(7pt) + gray);
```

### 6.2 Step Numbering (Bottom)

For complex diagrams, add numbered steps below the diagram.

```asy
real ySteps = yBot - 2.5;
label("1. Send",     (pUser.x, ySteps), fontsize(8pt));
label("2. Auth",     (pGateway.x, ySteps), fontsize(8pt));
label("3. Route",    (pRouter.x, ySteps), fontsize(8pt));
label("4. Dispatch", (pRouter.x, ySteps - 0.5), fontsize(8pt));
label("5. Parallel", (pPod2.x, ySteps), fontsize(8pt));
label("6. Merge",    (pResult.x, ySteps), fontsize(8pt));

// Dashed line above steps
draw((xStart - 2, ySteps + 0.5) -- (xEnd + 2, ySteps + 0.5),
     gray + dashed + linewidth(0.5));
```

### 6.3 Dynasty / Phase Dividers

For timelines, add horizontal dashed lines to separate phases.

```asy
real yDivider = (pPhase1.y + pPhase2.y) / 2;
draw((xLeft - 1, yDivider) -- (xRight + 1, yDivider),
     gray + linewidth(0.5) + dashed);
label("Yongle Reign", (xLeft - 1.8, yDivider), fontsize(7pt) + gray);
```

---

## 7. Complete Example: System Architecture

This example demonstrates a full system architecture diagram in the style of the reference image — layered components with clustering, dispatch, and step annotations.

```asy
// ==========================================
// SYSTEM ARCHITECTURE: REQUEST FLOW
// ==========================================
unitsize(1.1cm);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real yTop       = 3.5;
real yBot       = -3.5;
real dx         = 4.5;
real bw         = 3.8;
real bh         = 1.2;
real gap        = 0.2;
real xStart     = -11;

// Annotation positions
real yAnnTopMain = yTop + 2.2;
real yAnnSubMain = yTop + 1.8;
real ySteps      = yBot - 2.5;

// Colors
pen userColor    = rgb(0.90, 0.95, 1.00);
pen gatewayColor = rgb(1.00, 0.95, 0.85);
pen routerColor  = rgb(0.85, 1.00, 0.90);
pen podColor     = rgb(1.00, 0.95, 0.75);
pen resultColor  = rgb(0.85, 1.00, 0.95);
pen clusterFill  = rgb(0.96, 0.96, 0.99);
pen clusterPen   = rgb(0.3, 0.3, 0.6) + linewidth(1.8);
pen arrowPen     = rgb(0.2, 0.2, 0.2) + linewidth(0.9);

// ------------------------------------------
// HELPERS
// ------------------------------------------
void boxLabel(pair c, string[] lines, pen fillpen) {
    pair bl = c + (-bw/2, -bh/2);
    pair tr = c + (bw/2, bh/2);
    fill(box(bl, tr), fillpen);
    draw(box(bl, tr), black + 1.2pt);
    real lineDy = 0.36;
    real y0 = c.y + (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(lines[i], (c.x, y0 - i * lineDy), fontsize(9pt));
}

void arrH(pair leftBox, pair rightBox) {
    draw((leftBox.x + bw/2 + gap, leftBox.y) -- (rightBox.x - bw/2 - gap, rightBox.y),
         arrow = Arrow(TeXHead), linewidth(0.9));
}

// ------------------------------------------
// TITLE
// ------------------------------------------
label("BizyAir.cn Architecture: Request Flow", (0, 7.5), fontsize(16pt));

// ------------------------------------------
// ACCESS LAYER
// ------------------------------------------
pair pUser = (xStart, yTop);
boxLabel(pUser, new string[]{"User", "bizyair.cn Canvas"}, userColor);

pair pSCX = (xStart + dx, yTop);
boxLabel(pSCX, new string[]{"SCX Gateway", "Auth, Quota, Billing"}, gatewayColor);

arrH(pUser, pSCX);

// ------------------------------------------
// CORE CLUSTER
// ------------------------------------------
pair cbl = (xStart + 2.0*dx - bw/2 - 0.3, yTop - 0.5);
pair ctr = (xStart + 5.2*dx + bw/2 + 1.8, yBot - bh/2 - 1);
fill(box(cbl, ctr), clusterFill);
draw(box(cbl, ctr), clusterPen);
label("Inference Core Cluster", ((cbl.x + ctr.x)/2, ctr.y + 0.5),
      fontsize(11pt) + rgb(0.3, 0.3, 0.6));

// CGR Router
pair pCGR = (xStart + 3.0*dx, yTop - 1.5);
boxLabel(pCGR, new string[]{"CGR Router", "Unique Instance"}, routerColor);

// Pods
pair pPod1 = (xStart + 2.5*dx, yBot);
pair pPod2 = (xStart + 3.5*dx, yBot);
pair pPodN = (xStart + 5.5*dx, yBot);

boxLabel(pPod1, new string[]{"Pod 1", "ComfyAgent + ComfyUI"}, podColor);
boxLabel(pPod2, new string[]{"Pod 2", "ComfyAgent + ComfyUI"}, podColor);
boxLabel(pPodN, new string[]{"Pod N", "ComfyAgent + ComfyUI"}, podColor);

// SCX -> CGR (curved)
pair scxOut = (pSCX.x + bw/2 + gap, pSCX.y);
pair cgrIn  = (pCGR.x - bw/2 - gap, pCGR.y);
draw(scxOut{E}..{E}cgrIn, arrow = Arrow(TeXHead), linewidth(0.9));

// CGR -> Pods (dashed dispatch)
pair cgrBot = (pCGR.x, pCGR.y - bh/2 - gap);
pen dispatchPen = gray + linewidth(0.7) + dashed;

for (pair pod : new pair[] {pPod1, pPod2, pPodN}) {
    pair podTop = (pod.x, pod.y + bh/2 + gap);
    draw(cgrBot -- (cgrBot.x, cgrBot.y - 0.8) -- (podTop.x, cgrBot.y - 0.8) -- podTop,
         dispatchPen);
}

// Pods -> Result
pair pResult = (xStart + 7.0*dx, (yTop + yBot)/2);
boxLabel(pResult, new string[]{"Result", "Image / Video / Data"}, resultColor);

pair podRowRight = (pPodN.x + bw/2 + gap, pPodN.y);
pair resultLeft  = (pResult.x - bw/2 - gap, pResult.y);
draw(podRowRight{E}..{E}resultLeft,
     arrow = Arrow(TeXHead), linewidth(0.9) + dashed);

// ------------------------------------------
// STEP NUMBERING
// ------------------------------------------
label("1. Send",    (pUser.x, ySteps), fontsize(8pt));
label("2. Auth",    (pSCX.x, ySteps), fontsize(8pt));
label("3. Route",   (pCGR.x, ySteps), fontsize(8pt));
label("4. Dispatch", (pCGR.x, ySteps - 0.5), fontsize(8pt));
label("5. Parallel", (pPod2.x, ySteps), fontsize(8pt));
label("6. Merge",   (pResult.x, ySteps), fontsize(8pt));

// ------------------------------------------
// TOP ANNOTATIONS
// ------------------------------------------
label("Web Canvas", (pUser.x, yAnnTopMain), fontsize(8pt));
label("Frontend",   (pUser.x, yAnnSubMain), fontsize(7pt) + gray);

label("Permission", (pSCX.x, yAnnTopMain), fontsize(8pt));
label("Gateway",    (pSCX.x, yAnnSubMain), fontsize(7pt) + gray);

label("Cluster",    (pCGR.x, yAnnTopMain), fontsize(8pt));
label("Router",     (pCGR.x, yAnnSubMain), fontsize(7pt) + gray);

label("Return",     (pResult.x, yAnnTopMain), fontsize(8pt));
label("Output",     (pResult.x, yAnnSubMain), fontsize(7pt) + gray);

// ------------------------------------------
// LEGEND
// ------------------------------------------
label("FaaS: Function-as-a-Service / CGR: Comfy Grid Runtime / SCX: Service Control X",
      (0, yBot - 3.5), fontsize(9pt));
```

---

## 8. Complete Example: Cooking Workflow (番茄炒蛋)

A workflow diagram showing the steps of cooking tomato scrambled eggs, with parallel preparation paths. This example uses the **picture-based modular composition** pattern (see §3.4) because the diagram has parallel branches and side annotations that would be fragile with raw `pair` coordinates.

```asy
// ==========================================
// WORKFLOW: TOMATO SCRAMBLED EGGS
// Using picture types for modular node composition
// ==========================================
unitsize(1.0cm);

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
// NODE BUILDER — returns a picture centered at (0,0)
// ------------------------------------------
picture makeNode(string[] lines, pen fillpen, pen borderpen) {
    picture pic;
    pair bl = (-bw/2, -bh/2);
    pair tr = ( bw/2,  bh/2);
    fill(pic, box(bl, tr), fillpen);
    draw(pic, box(bl, tr), borderpen);
    real lineDy = 0.32;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

picture makeNode(string text, pen fillpen, pen borderpen) {
    return makeNode(new string[]{text}, fillpen, borderpen);
}

// ------------------------------------------
// ARROW HELPERS — draw on dest using placed picture anchors
// ------------------------------------------
void arrowDown(picture dest, picture topNode, picture botNode) {
    pair a = point(topNode, S) + (0, -gap);
    pair b = point(botNode, N) + (0,  gap);
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

void arrowJoinLeft(picture dest, picture sideNode, picture mainNode) {
    pair a = point(sideNode, S) + (0, -gap);
    pair b = point(mainNode,  W) + (-gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), arrowPen);
}

void arrowJoinRight(picture dest, picture sideNode, picture mainNode) {
    pair a = point(sideNode, S) + (0, -gap);
    pair b = point(mainNode,  E) + (gap, 0);
    draw(dest, a -- (a.x, b.y) -- b, arrow = Arrow(TeXHead), arrowPen);
}

// ------------------------------------------
// BUILD MAIN DIAGRAM
// ------------------------------------------
picture diagram;

// --- Create and position nodes (shift baked into each picture) ---
picture pStart  = shift(xMain,   y0)            * makeNode("Start", doneFill, doneBorder);
picture pPrep   = shift(xMain,   y0 - nodeDy)   * makeNode(new string[]{"Prep", "wash \& measure"}, prepFill, prepBorder);
picture pCut    = shift(xLeftB,  y0 - 2*nodeDy) * makeNode("Cut Tomato", prepFill, prepBorder);
picture pBeat   = shift(xRightB, y0 - 2*nodeDy) * makeNode("Beat Eggs", prepFill, prepBorder);
picture pHeat   = shift(xMain,   y0 - 3*nodeDy) * makeNode("Heat Oil", cookFill, cookBorder);
picture pFryE   = shift(xMain,   y0 - 4*nodeDy) * makeNode("Fry Eggs", cookFill, cookBorder);
picture pFryT   = shift(xMain,   y0 - 5*nodeDy) * makeNode("Fry Tomato", cookFill, cookBorder);
picture pMix    = shift(xMain,   y0 - 6*nodeDy) * makeNode("Mix", cookFill, cookBorder);
picture pSeason = shift(xMain,   y0 - 7*nodeDy) * makeNode("Season", cookFill, cookBorder);
picture pDone   = shift(xMain,   y0 - 8*nodeDy) * makeNode("Serve", doneFill, doneBorder);

// Add all nodes to diagram
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

// --- Draw arrows using node picture anchor points ---
arrowDown(diagram, pStart, pPrep);
arrowJoinRight(diagram, pPrep, pCut);
arrowJoinLeft(diagram, pPrep, pBeat);
arrowJoinLeft(diagram, pCut, pHeat);
arrowJoinRight(diagram, pBeat, pHeat);
arrowDown(diagram, pHeat, pFryE);
arrowDown(diagram, pFryE, pFryT);
arrowDown(diagram, pFryT, pMix);
arrowDown(diagram, pMix, pSeason);
arrowDown(diagram, pSeason, pDone);

// --- Title ---
label(diagram, "\textbf{Workflow: Tomato Scrambled Eggs}",
      (xMain, y0 + 1.2), fontsize(14pt));

// --- Side annotations ---
real xAnnotLeft  = xLeftB  - 2.2;
real xAnnotRight = xRightB + 2.2;

label(diagram, "Ingredients", (xAnnotLeft,  point(pPrep, N).y - bh/2), fontsize(8pt));
label(diagram, "Tomato",      (xAnnotLeft,  point(pCut,  (0,0)).y + 0.35), fontsize(8pt));
label(diagram, "Eggs",        (xAnnotLeft,  point(pBeat, (0,0)).y - 0.35), fontsize(8pt));
label(diagram, "Cooking",     (xAnnotLeft,  point(pHeat, (0,0)).y),    fontsize(8pt));
label(diagram, "Medium heat", (xAnnotLeft,  point(pFryE, (0,0)).y),    fontsize(8pt));
label(diagram, "Stir-fry",    (xAnnotLeft,  point(pFryT, (0,0)).y),    fontsize(8pt));
label(diagram, "Combine",     (xAnnotLeft,  point(pMix,  (0,0)).y),    fontsize(8pt));
label(diagram, "Salt",        (xAnnotLeft,  point(pSeason,(0,0)).y),   fontsize(8pt));

label(diagram, "2 tomatoes",  (xAnnotRight, point(pCut,  (0,0)).y + 0.35), fontsize(8pt));
label(diagram, "3 eggs",      (xAnnotRight, point(pBeat, (0,0)).y - 0.35), fontsize(8pt));
label(diagram, "1 min",       (xAnnotRight, point(pFryE, (0,0)).y),    fontsize(8pt));
label(diagram, "2 min",       (xAnnotRight, point(pFryT, (0,0)).y),    fontsize(8pt));
label(diagram, "Quick toss",  (xAnnotRight, point(pMix,  (0,0)).y),    fontsize(8pt));
label(diagram, "Pinch",       (xAnnotRight, point(pSeason,(0,0)).y),   fontsize(8pt));
label(diagram, "Enjoy!",      (xAnnotRight, point(pDone, (0,0)).y),    fontsize(8pt));

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
diagram = shift(-min(diagram, true)) * diagram;
add(diagram);
```

---

## 9. Style Guide Summary

| Element | Usage | Style |
|---------|-------|-------|
| Component box | Individual service/node/stage | Rectangle, colored fill, 1.2pt border |
| Cluster box | Group of related components | Large rectangle, light fill, bold border |
| Dashed group | Logical/optional grouping | Dashed border, no fill |
| Solid arrow | Primary data/control flow | `Arrow(TeXHead)`, 0.9bp |
| Dashed arrow | Internal dispatch, secondary flow | Gray, dashed, 0.7bp |
| Curved arrow | Avoid crossing other lines | Bezier curve with `{dir}..{dir}` |
| Layer label | Annotate architectural layer | Left-aligned gray text |
| Step number | Bottom timeline annotation | Small gray text, evenly spaced |
| Node text | Name + one-line description | Name centered, description below in gray |

---

## 10. Common Pitfalls

1. **Using `margin=EndMargin` instead of precise coordinates** — Asymptote's strength is exact positioning. Compute arrow endpoints with `bh/2 + gap` rather than relying on heuristic margin parameters.

2. **Overcrowding nodes** — Keep to name + one short line. Put details in side annotations or captions.

3. **Inconsistent arrow styles** — Use solid for main flow, dashed for internal/subordinate flow.

4. **Missing cluster labels** — Every bounding box should have a label indicating what the group represents.

5. **Arrow crossings** — Route around clusters or use curves. Avoid crossing solid arrows.

6. **Monochrome diagrams** — Use the color palette to distinguish roles. Color is faster to parse than text.

7. **No layer context** — For complex systems, add layer annotations on the left so readers know which architectural level they're viewing.

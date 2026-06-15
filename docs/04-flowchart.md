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

---

## 2. Core Building Blocks

### 2.1 Component Box (The Basic Node)

The fundamental unit. A rectangle with a name and optional subtitle.

```asy
// ==========================================
// COMPONENT BOX
// ==========================================
real boxWidth = 3.0;
real boxHeight = 1.2;

path componentBox(pair c, real w, real h) {
    return box(c + (-w/2, -h/2), c + (w/2, h/2));
}

// Draw a component with name + subtitle
void drawComponent(pair pos, string name, string desc="",
                   pen fillPen=lightyellow, pen borderPen=black+linewidth(1)) {
    path p = componentBox(pos, boxWidth, boxHeight);
    filldraw(p, fillPen, borderPen);
    if (desc == "") {
        label(name, pos);
    } else {
        label(name, pos + (0, 0.15));
        label("\small " + desc, pos + (0, -0.25), gray(0.3));
    }
}
```

### 2.2 Cluster / Group Box

A large rectangle that encloses related components, with a label at the bottom or top.

```asy
// ==========================================
// CLUSTER BOX
// ==========================================
void drawCluster(pair min, pair max, string label,
                 pen fillPen=rgb(0.96,0.96,1.0),
                 pen borderPen=rgb(0.3,0.3,0.6)+linewidth(1.5)) {
    path p = box(min, max);
    filldraw(p, fillPen, borderPen);
    // Label at bottom center
    label(label, ((min.x+max.x)/2, min.y - 0.3), borderPen);
}

// Dashed logical group (no fill)
void drawDashedGroup(pair min, pair max, string label="") {
    path p = box(min, max);
    draw(p, gray(0.5) + dashed + linewidth(1));
    if (label != "") {
        label("\small " + label, ((min.x+max.x)/2, max.y + 0.3), gray(0.5));
    }
}
```

### 2.3 Layer Annotation

Horizontal bands that indicate architectural layers (e.g., Frontend, Gateway, Core, Storage).

```asy
// ==========================================
// LAYER LABELS
// ==========================================
void drawLayerLabel(real y, string name, string subtitle="") {
    label("\small \textbf{" + name + "}", (-6, y), W, gray(0.4));
    if (subtitle != "") {
        label("\scriptsize " + subtitle, (-6, y - 0.4), W, gray(0.5));
    }
    // Light gray horizontal line spanning the diagram width
    draw((-5.5, y-0.6)--(8, y-0.6), gray(0.8)+linewidth(0.5));
}
```

---

## 3. Arrows and Connectors

System diagrams use diverse arrow styles to convey different relationship types.

### 3.1 Arrow Style Reference

```asy
// ==========================================
// ARROW STYLES
// ==========================================

// Standard data flow (solid)
pen solidArrow = rgb(0.2,0.2,0.2) + linewidth(1.2);

// Internal/dispatch flow (dashed)
pen dashedArrow = gray(0.5) + dashed + linewidth(1);

// Return/feedback flow (dotted or different color)
pen returnArrow = rgb(0.4,0.4,0.6) + linewidth(1);

// Curved arrow (for crossing routes)
path curvedArrow(pair a, pair b, real bend=1.5) {
    pair mid = (a + b) / 2;
    pair perp = rotate(90) * unit(b - a);
    return a..controls (mid + bend*perp)..b;
}

// Bidirectional arrow
draw(a--b, arrow=Arrows);

// Orthogonal routing (horizontal then vertical)
path ortho(pair a, pair b) {
    return a--(b.x, a.y)--b;
}
```

### 3.2 Drawing Arrows with Labels

```asy
// Arrow with inline label
draw(a--b, solidArrow, arrow=Arrow);
label("\small Request", (a+b)/2, N);

// Curved arrow with label
path c = curvedArrow(a, b, 1.0);
draw(c, solidArrow, arrow=Arrow);
label("\small Dispatch", midpoint(c), NE);
```

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
// COLOR PALETTE
// ==========================================
pen userFill     = rgb(0.85, 0.92, 1.0);
pen userBorder   = rgb(0.2, 0.4, 0.6) + linewidth(1);
pen gatewayFill  = rgb(1.0, 0.95, 0.85);
pen gatewayBorder= rgb(0.5, 0.35, 0.15) + linewidth(1);
pen routerFill   = rgb(0.85, 1.0, 0.9);
pen routerBorder = rgb(0.15, 0.45, 0.3) + linewidth(1);
pen workerFill   = rgb(1.0, 0.95, 0.8);
pen workerBorder = rgb(0.5, 0.4, 0.15) + linewidth(1);
pen storageFill  = rgb(0.95, 0.9, 0.95);
pen storageBorder= rgb(0.4, 0.3, 0.5) + linewidth(1);
pen resultFill   = rgb(0.9, 1.0, 0.95);
pen resultBorder = rgb(0.2, 0.5, 0.4) + linewidth(1);
pen clusterFill  = rgb(0.96, 0.96, 1.0);
pen clusterBorder= rgb(0.3, 0.3, 0.6) + linewidth(1.5);
```

---

## 5. Layout Patterns

### 5.1 Horizontal Pipeline (Left to Right)

For sequential data flow: ingest → process → output.

```asy
// ==========================================
// PIPELINE LAYOUT
// ==========================================
size(400, 150);

real bw = 2.8;
real bh = 1.0;
real hGap = 3.5;

pair pIngest  = (0, 0);
pair pProcess = (hGap, 0);
pair pStore   = (2*hGap, 0);
pair pServe   = (3*hGap, 0);

// Draw nodes
filldraw(componentBox(pIngest, bw, bh), userFill, userBorder);
label("Ingest", pIngest);

filldraw(componentBox(pProcess, bw, bh), workerFill, workerBorder);
label("Process", pProcess);

filldraw(componentBox(pStore, bw, bh), storageFill, storageBorder);
label("Store", pStore);

filldraw(componentBox(pServe, bw, bh), resultFill, resultBorder);
label("Serve", pServe);

// Draw arrows
draw(pIngest--pProcess, solidArrow, arrow=Arrow);
draw(pProcess--pStore, solidArrow, arrow=Arrow);
draw(pStore--pServe, solidArrow, arrow=Arrow);
```

### 5.2 Layered Architecture (Top to Bottom)

For hierarchical systems: client → gateway → core → storage.

```asy
// ==========================================
// LAYERED ARCHITECTURE
// ==========================================
size(400, 400);

real bw = 3.0;
real bh = 1.0;
real vGap = 2.5;

pair pClient  = (0, 0);
pair pGateway = (0, -vGap);
pair pCore    = (0, -2*vGap);
pair pStorage = (0, -3*vGap);

// Layer labels on the left
drawLayerLabel(0, "Client", "Frontend");
drawLayerLabel(-vGap, "Gateway", "Auth, Quota");
drawLayerLabel(-2*vGap, "Core", "Business Logic");
drawLayerLabel(-3*vGap, "Storage", "Persistence");

// Draw nodes
filldraw(componentBox(pClient, bw, bh), userFill, userBorder);
label("Client", pClient);

filldraw(componentBox(pGateway, bw, bh), gatewayFill, gatewayBorder);
label("API Gateway", pGateway);

filldraw(componentBox(pCore, bw, bh), workerFill, workerBorder);
label("Core Service", pCore);

filldraw(componentBox(pStorage, bw, bh), storageFill, storageBorder);
label("Database", pStorage);

// Arrows
draw(pClient--pGateway, solidArrow, arrow=Arrow);
draw(pGateway--pCore, solidArrow, arrow=Arrow);
draw(pCore--pStorage, solidArrow, arrow=Arrow);
```

### 5.3 Cluster with Internal Dispatch

For systems with a router dispatching to multiple workers inside a cluster.

```asy
// ==========================================
// CLUSTER WITH DISPATCH
// ==========================================
size(500, 250);

// Cluster bounding box
pair clusterMin = (-2, -3.5);
pair clusterMax = (8, 0.5);
drawCluster(clusterMin, clusterMax, "Inference Cluster", clusterFill, clusterBorder);

// Router at top center of cluster
pair pRouter = (3, -0.5);
filldraw(componentBox(pRouter, 2.5, 0.9), routerFill, routerBorder);
label("Router", pRouter);

// Worker pods below
real podY = -2.5;
real podGap = 2.5;
pair pPod1 = (0.5, podY);
pair pPod2 = (3.0, podY);
pair pPod3 = (5.5, podY);

filldraw(componentBox(pPod1, 2.0, 0.8), workerFill, workerBorder);
label("\small Pod 1", pPod1);

filldraw(componentBox(pPod2, 2.0, 0.8), workerFill, workerBorder);
label("\small Pod 2", pPod2);

filldraw(componentBox(pPod3, 2.0, 0.8), workerFill, workerBorder);
label("\small Pod N", pPod3);

// Dashed dispatch lines from router to pods
for (pair pod : new pair[] {pPod1, pPod2, pPod3}) {
    draw(pRouter--(pRouter.x, pod.y+0.5)--pod,
         gray(0.5) + dashed + linewidth(0.8),
         arrow=Arrow);
}

// External input to router
pair pGateway = (-4.5, -0.5);
filldraw(componentBox(pGateway, 2.5, 0.9), gatewayFill, gatewayBorder);
label("Gateway", pGateway);

draw(pGateway--pRouter, solidArrow, arrow=Arrow);
```

### 5.4 Parallel Branches with Merge

For tasks that split into parallel paths and later merge.

```asy
// ==========================================
// PARALLEL BRANCHES
// ==========================================
size(400, 200);

pair pStart  = (0, 0);
pair pTaskA  = (-2, -2);
pair pTaskB  = (2, -2);
pair pMerge  = (0, -4);

filldraw(componentBox(pStart, 2.0, 0.8), routerFill, routerBorder);
label("Split", pStart);

filldraw(componentBox(pTaskA, 2.2, 0.8), workerFill, workerBorder);
label("Task A", pTaskA);

filldraw(componentBox(pTaskB, 2.2, 0.8), workerFill, workerBorder);
label("Task B", pTaskB);

filldraw(componentBox(pMerge, 2.0, 0.8), resultFill, resultBorder);
label("Merge", pMerge);

// Arrows
draw(pStart--pTaskA, solidArrow, arrow=Arrow);
draw(pStart--pTaskB, solidArrow, arrow=Arrow);
draw(pTaskA--(pTaskA.x, pMerge.y)--pMerge, solidArrow, arrow=Arrow);
draw(pTaskB--(pTaskB.x, pMerge.y)--pMerge, solidArrow, arrow=Arrow);
```

---

## 6. Advanced Techniques

### 6.1 Curved Arrows for Crossing Routes

When straight arrows would cross, use curves.

```asy
// ==========================================
// CURVED ARROW
// ==========================================
pair a = (0, 0);
pair b = (4, 0);

// Arc upward
draw(a{up}..{up}b, solidArrow, arrow=Arrow);

// Or explicit control points
path c = a..controls (2, 1.5)..b;
draw(c, solidArrow, arrow=Arrow);
```

### 6.2 Step Numbering at Bottom

For complex diagrams, add numbered steps below the diagram.

```asy
// ==========================================
// STEP NUMBERING
// ==========================================
string[] steps = {
    "1. Authenticate",
    "2. Route",
    "3. Dispatch",
    "4. Process",
    "5. Merge"
};

real stepY = -5.5;
real stepGap = 2.8;
for (int i = 0; i < steps.length; ++i) {
    label("\small " + steps[i], (-4 + i*stepGap, stepY), gray(0.4));
}

// Dashed line above steps
draw((-5, stepY+0.5)--(12, stepY+0.5), gray(0.7)+dashed+linewidth(0.5));
```

### 6.3 Two-Line Component Labels

Nodes often need a name + short description.

```asy
// ==========================================
// TWO-LINE LABEL
// ==========================================
pair pos = (0, 0);
real bw = 3.2;
real bh = 1.2;

filldraw(componentBox(pos, bw, bh), gatewayFill, gatewayBorder);
label("SCX Gateway", pos + (0, 0.2));
label("\small Auth, Quota, Billing", pos + (0, -0.25), gray(0.35));
```

### 6.4 Return / Feedback Loops

Dashed or differently colored arrows for responses.

```asy
// ==========================================
// FEEDBACK LOOP
// ==========================================
pair result = (6, -1);
pair client = (-4, -1);

// Return path (dashed, going below)
pair midReturn = ((result.x+client.x)/2, -4);
draw(result--midReturn--client,
     rgb(0.4,0.4,0.6)+dashed+linewidth(1),
     arrow=Arrow);
label("\small Result", midReturn, S, rgb(0.4,0.4,0.6));
```

---

## 7. Complete Example: System Architecture

This example demonstrates a full system architecture diagram in the style of the reference image — layered components with clustering, dispatch, and step annotations.

```asy
// ==========================================
// SYSTEM ARCHITECTURE: REQUEST FLOW
// ==========================================
size(600, 350);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real compW = 2.8;      // component width
real compH = 1.0;      // component height
real smallW = 2.0;     // small component width
real vLayer = 2.0;     // vertical layer spacing

pen userFill     = rgb(0.85, 0.92, 1.0);
pen userBorder   = rgb(0.2, 0.4, 0.6) + linewidth(1);
pen gatewayFill  = rgb(1.0, 0.95, 0.85);
pen gatewayBorder= rgb(0.5, 0.35, 0.15) + linewidth(1);
pen routerFill   = rgb(0.85, 1.0, 0.9);
pen routerBorder = rgb(0.15, 0.45, 0.3) + linewidth(1);
pen workerFill   = rgb(1.0, 0.95, 0.8);
pen workerBorder = rgb(0.5, 0.4, 0.15) + linewidth(1);
pen resultFill   = rgb(0.9, 1.0, 0.95);
pen resultBorder = rgb(0.2, 0.5, 0.4) + linewidth(1);
pen clusterFill  = rgb(0.96, 0.96, 1.0);
pen clusterBorder= rgb(0.3, 0.3, 0.6) + linewidth(1.5);
pen solidArrow   = rgb(0.2, 0.2, 0.2) + linewidth(1.2);
pen dashedArrow  = gray(0.5) + dashed + linewidth(0.9);

// ------------------------------------------
// LAYER ANNOTATIONS (left side)
// ------------------------------------------
label("\small Web Canvas", (-7.5, 0.3), W, gray(0.4));
label("\scriptsize Frontend", (-7.5, -0.1), W, gray(0.5));

label("\small Permission", (-7.5, -vLayer+0.3), W, gray(0.4));
label("\scriptsize Gateway", (-7.5, -vLayer-0.1), W, gray(0.5));

label("\small Cluster", (-7.5, -2*vLayer+0.3), W, gray(0.4));
label("\scriptsize Router", (-7.5, -2*vLayer-0.1), W, gray(0.5));

label("\small Return", (-7.5, -3*vLayer+0.3), W, gray(0.4));
label("\scriptsize Output", (-7.5, -3*vLayer-0.1), W, gray(0.5));

// ------------------------------------------
// COMPONENTS
// ------------------------------------------

// User (leftmost)
pair pUser = (-4.5, 0);
filldraw(box(pUser+(-compW/2,-compH/2), pUser+(compW/2,compH/2)),
         userFill, userBorder);
label("User", pUser+(0,0.15));
label("\small bizyair.cn", pUser+(0,-0.22), gray(0.35));

// Gateway
pair pGateway = (-0.5, -vLayer);
filldraw(box(pGateway+(-compW/2,-compH/2), pGateway+(compW/2,compH/2)),
         gatewayFill, gatewayBorder);
label("SCX Gateway", pGateway+(0,0.15));
label("\small Auth, Quota", pGateway+(0,-0.22), gray(0.35));

// Inference Core Cluster (large bounding box)
pair clusterMin = (1.5, -4.0);
pair clusterMax = (9.5, -0.5);
filldraw(box(clusterMin, clusterMax), clusterFill, clusterBorder);
label("\small Inference Core Cluster", ((clusterMin.x+clusterMax.x)/2, clusterMin.y-0.3),
      rgb(0.3,0.3,0.6));

// CGR Router inside cluster
pair pRouter = (4.5, -1.2);
filldraw(box(pRouter+(-smallW/2,-compH/2), pRouter+(smallW/2,compH/2)),
         routerFill, routerBorder);
label("CGR Router", pRouter+(0,0.15));
label("\small Unique Instance", pRouter+(0,-0.22), gray(0.35));

// Dashed dispatch zone
pair dispatchMin = (2.5, -3.5);
pair dispatchMax = (8.5, -1.8);
draw(box(dispatchMin, dispatchMax), gray(0.5)+dashed+linewidth(1));
label("\small Dispatch", ((dispatchMin.x+dispatchMax.x)/2, (dispatchMin.y+dispatchMax.y)/2),
      gray(0.5));

// Pods
real podY = -3.2;
pair pPod1 = (3.0, podY);
pair pPod2 = (5.0, podY);
pair pPod3 = (7.0, podY);
pair pPod4 = (9.0, podY);

filldraw(box(pPod1+(-smallW/2,-0.7), pPod1+(smallW/2,0.7)), workerFill, workerBorder);
label("\small Pod 1", pPod1+(0,0.12));
label("\scriptsize ComfyAgent", pPod1+(0,-0.18), gray(0.35));

filldraw(box(pPod2+(-smallW/2,-0.7), pPod2+(smallW/2,0.7)), workerFill, workerBorder);
label("\small Pod 2", pPod2+(0,0.12));
label("\scriptsize ComfyAgent", pPod2+(0,-0.18), gray(0.35));

filldraw(box(pPod3+(-smallW/2,-0.7), pPod3+(smallW/2,0.7)), workerFill, workerBorder);
label("\small Pod ...", pPod3+(0,0.12));
label("\scriptsize ...", pPod3+(0,-0.18), gray(0.35));

filldraw(box(pPod4+(-smallW/2,-0.7), pPod4+(smallW/2,0.7)), workerFill, workerBorder);
label("\small Pod N", pPod4+(0,0.12));
label("\scriptsize ComfyAgent", pPod4+(0,-0.18), gray(0.35));

// Result (rightmost)
pair pResult = (12, -2.5);
filldraw(box(pResult+(-compW/2,-compH/2), pResult+(compW/2,compH/2)),
         resultFill, resultBorder);
label("Result", pResult+(0,0.15));
label("\small Image / Data", pResult+(0,-0.22), gray(0.35));

// ------------------------------------------
// ARROWS
// ------------------------------------------

// User -> Gateway
draw(pUser--pGateway, solidArrow, arrow=Arrow);

// Gateway -> Router (curved)
path g2r = pGateway{right}..controls (1.5, -vLayer+0.5)..{right}pRouter;
draw(g2r, solidArrow, arrow=Arrow);

// Router -> Pods (dashed dispatch)
for (pair pod : new pair[] {pPod1, pPod2, pPod3, pPod4}) {
    draw((pRouter.x, pRouter.y-0.6)--(pRouter.x, pod.y+0.5)--pod,
         dashedArrow, arrow=Arrow);
}

// Pods -> Result (curved merge)
path r2out = pPod4{right}..controls (11, podY)..{up}pResult;
draw(r2out, solidArrow, arrow=Arrow);
label("\small Merge", (10.5, -2.8), SE, gray(0.4));

// ------------------------------------------
// STEP ANNOTATIONS (bottom)
// ------------------------------------------
string[] steps = {
    "1. Send",
    "2. Auth",
    "3. Route",
    "4. Dispatch",
    "5. Parallel",
    "6. Merge"
};
real stepY = -5.5;
real stepGap = 3.2;
for (int i = 0; i < steps.length; ++i) {
    label("\small " + steps[i], (-5.5 + i*stepGap, stepY), gray(0.4));
}

// ------------------------------------------
// CAPTION
// ------------------------------------------
label("\small FaaS: Function-as-a-Service / CGR: Comfy Grid Runtime / SCX: Service Control X",
      (3, -6.5), gray(0.5));
```

---

## 8. Complete Example: Cooking Flow (番茄炒蛋)

A workflow diagram showing the steps of cooking tomato scrambled eggs, with parallel preparation paths.

```asy
// ==========================================
// WORKFLOW: TOMATO SCRAMBLED EGGS
// ==========================================
size(400, 500);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw = 2.8;
real bh = 0.9;
real vGap = 1.6;
real branchGap = 3.5;

pen prepFill    = rgb(1.0, 0.97, 0.9);
pen prepBorder  = rgb(0.5, 0.4, 0.2) + linewidth(1);
pen cookFill    = rgb(1.0, 0.92, 0.85);
pen cookBorder  = rgb(0.6, 0.35, 0.15) + linewidth(1);
pen doneFill    = rgb(0.9, 1.0, 0.95);
pen doneBorder  = rgb(0.2, 0.5, 0.4) + linewidth(1);
pen arrowPen    = rgb(0.3, 0.2, 0.1) + linewidth(1);

// ------------------------------------------
// NODES
// ------------------------------------------
pair pStart = (0, 0);
pair pPrep  = (0, -vGap);
pair pCut   = (-branchGap/2, -2*vGap);
pair pBeat  = ( branchGap/2, -2*vGap);
pair pHeat  = (0, -3*vGap);
pair pFryE  = (0, -4*vGap);
pair pFryT  = (0, -5*vGap);
pair pMix   = (0, -6*vGap);
pair pSeason= (0, -7*vGap);
pair pDone  = (0, -8*vGap);

// Start
filldraw(ellipse(pStart, 1.8, 0.7), doneFill, doneBorder);
label("\small Start", pStart);

// Prep ingredients
filldraw(box(pPrep+(-bw/2,-bh/2), pPrep+(bw/2,bh/2)), prepFill, prepBorder);
label("\small Prep", pPrep+(0,0.12));
label("\scriptsize wash, measure", pPrep+(0,-0.18), gray(0.4));

// Parallel prep
filldraw(box(pCut+(-bw/2,-bh/2), pCut+(bw/2,bh/2)), prepFill, prepBorder);
label("\small Cut", pCut);

filldraw(box(pBeat+(-bw/2,-bh/2), pBeat+(bw/2,bh/2)), prepFill, prepBorder);
label("\small Beat", pBeat);

// Cooking steps
for (int i = 0; i < 5; ++i) {
    pair p = (0, -(3+i)*vGap);
    filldraw(box(p+(-bw/2,-bh/2), p+(bw/2,bh/2)), cookFill, cookBorder);
}

label("\small Heat Oil", pHeat);
label("\small Fry Eggs", pFryE);
label("\small Fry Tomato", pFryT);
label("\small Mix", pMix);
label("\small Season", pSeason);

// Done
filldraw(ellipse(pDone, 1.8, 0.7), doneFill, doneBorder);
label("\small Serve", pDone);

// ------------------------------------------
// ARROWS
// ------------------------------------------
draw(pStart--pPrep, arrowPen, arrow=Arrow);

// Split to parallel prep
draw(pPrep--pCut, arrowPen, arrow=Arrow);
draw(pPrep--pBeat, arrowPen, arrow=Arrow);

// Merge back
draw(pCut--(pCut.x, pHeat.y)--pHeat, arrowPen, arrow=Arrow);
draw(pBeat--(pBeat.x, pHeat.y)--pHeat, arrowPen, arrow=Arrow);

// Sequential cooking
draw(pHeat--pFryE, arrowPen, arrow=Arrow);
draw(pFryE--pFryT, arrowPen, arrow=Arrow);
draw(pFryT--pMix, arrowPen, arrow=Arrow);
draw(pMix--pSeason, arrowPen, arrow=Arrow);
draw(pSeason--pDone, arrowPen, arrow=Arrow);
```

---

## 9. Style Guide Summary

| Element | Usage | Style |
|---------|-------|-------|
| Component box | Individual service/node/stage | Rectangle, colored fill |
| Cluster box | Group of related components | Large rectangle, light fill, bold border |
| Dashed group | Logical/optional grouping | Dashed border, no fill |
| Solid arrow | Primary data/control flow | Dark, 1.2bp, `arrow=Arrow` |
| Dashed arrow | Internal dispatch, secondary flow | Gray, dashed, 0.9bp |
| Curved arrow | Avoid crossing other lines | Bezier curve with control points |
| Layer label | Annotate architectural layer | Left-aligned gray text |
| Step number | Bottom timeline annotation | Small gray text, evenly spaced |
| Node text | Name + one-line description | Name centered, description below in gray |

---

## 10. Common Pitfalls

1. **Overcrowding nodes** — Keep to name + one short line. Put details in captions.

2. **Inconsistent arrow styles** — Use solid for main flow, dashed for internal/subordinate flow.

3. **Missing cluster labels** — Every bounding box should have a label indicating what the group represents.

4. **Arrow crossings** — Route around clusters or use curves. Avoid crossing solid arrows.

5. **Monochrome diagrams** — Use the color palette to distinguish roles. Color is faster to parse than text.

6. **No layer context** — For complex systems, add layer annotations on the left so readers know which architectural level they're viewing.

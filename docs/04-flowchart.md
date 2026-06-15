# Flowcharts with Asymptote

This document demonstrates how to create professional flowcharts using **only Asymptote's default capabilities** — without importing the `flowchart` module. The default drawing primitives (`draw`, `fill`, `label`, `box`) are more than sufficient for clean, readable flowcharts, and produce better results than the `flowchart` standard library.

---

## 1. Philosophy

**Do NOT use `import flowchart;`.**

The `flowchart` module is overly rigid and produces generic-looking diagrams. With the default primitives, you have full control over:

- Exact positioning and sizing
- Custom shapes and styling
- Precise arrow routing
- Consistent, professional aesthetics

This document teaches the **fundamental techniques** for building flowcharts from scratch.

---

## 2. Core Techniques

### 2.1 Basic Shapes

**Rectangle (process box):**

```asy
// Configuration
real boxWidth = 3.0;
real boxHeight = 1.2;
real cornerRadius = 0.2;
pair center = (0, 0);

// Rectangle path
path processBox = box((-boxWidth/2, -boxHeight/2), (boxWidth/2, boxHeight/2));

// Rounded rectangle
path roundedBox = roundedBox((-boxWidth/2, -boxHeight/2), (boxWidth/2, boxHeight/2), cornerRadius);

// Draw
filldraw(processBox, lightyellow, black + linewidth(1));
```

**Diamond (decision):**

```asy
// Diamond vertices
pair diamondCenter = (0, 0);
real diamondWidth = 2.5;
real diamondHeight = 1.5;

pair diamondTop = (0, diamondHeight/2);
pair diamondBottom = (0, -diamondHeight/2);
pair diamondLeft = (-diamondWidth/2, 0);
pair diamondRight = (diamondWidth/2, 0);

path decisionDiamond = diamondTop--diamondRight--diamondBottom--diamondLeft--cycle;

filldraw(decisionDiamond, lightyellow, black + linewidth(1));
```

**Ellipse (start/end):**

```asy
pair center = (0, 0);
real ellipseWidth = 2.5;
real ellipseHeight = 1.0;

path startEllipse = ellipse(center, ellipseWidth/2, ellipseHeight/2);
filldraw(startEllipse, lightyellow, black + linewidth(1));
```

**Parallelogram (input/output):**

```asy
real paraWidth = 3.0;
real paraHeight = 1.2;
real skew = 0.4;

path parallelogram =
    (-paraWidth/2 + skew, paraHeight/2)--
    (paraWidth/2 + skew, paraHeight/2)--
    (paraWidth/2 - skew, -paraHeight/2)--
    (-paraWidth/2 - skew, -paraHeight/2)--cycle;

filldraw(parallelogram, lightyellow, black + linewidth(1));
```

### 2.2 Reusable Shape Functions

Define functions for each shape type to ensure consistency:

```asy
// ==========================================
// SHAPE DEFINITIONS
// ==========================================

// Process box
path processBox(pair center, real width, real height, real radius=0) {
    pair lowerLeft = center + (-width/2, -height/2);
    pair upperRight = center + (width/2, height/2);
    if (radius > 0) {
        return roundedBox(lowerLeft, upperRight, radius);
    }
    return box(lowerLeft, upperRight);
}

// Decision diamond
path decisionDiamond(pair center, real width, real height) {
    return center+(0,height/2)--center+(width/2,0)--
           center+(0,-height/2)--center+(-width/2,0)--cycle;
}

// Start/end ellipse
path terminalEllipse(pair center, real width, real height) {
    return ellipse(center, width/2, height/2);
}

// Input/output parallelogram
path ioParallelogram(pair center, real width, real height, real skew=0.4) {
    return center+(-width/2+skew, height/2)--center+(width/2+skew, height/2)--
           center+(width/2-skew, -height/2)--center+(-width/2-skew, -height/2)--cycle;
}

// Subroutine (double-bordered rectangle)
path subroutineBox(pair center, real width, real height) {
    path outer = box(center+(-width/2, -height/2), center+(width/2, height/2));
    path inner = box(center+(-width/2+0.1, -height/2+0.1), center+(width/2-0.1, height/2-0.1));
    // Return both paths; draw outer first, then inner
    return outer;
}
```

### 2.3 Arrows and Connectors

```asy
// Straight arrow
draw(startPoint--endPoint, arrow=Arrow);

// Orthogonal routing (right-angle connectors)
pair start = (0, 0);
pair end = (3, -2);

// Horizontal then vertical
path connector = start--(end.x, start.y)--end;
draw(connector, arrow=Arrow);

// Vertical then horizontal
path connector2 = start--(start.x, end.y)--end;
draw(connector2, arrow=Arrow);

// Elbow with offset
real elbowOffset = 1.0;
path connector3 = start--(start.x + elbowOffset, start.y)--
                  (start.x + elbowOffset, end.y)--end;
draw(connector3, arrow=Arrow);
```

### 2.4 Labels — Keep Blocks Clean

**Critical rule:** Each block contains **only a keyword or short phrase (1-3 words)**. Detailed explanations go in comments, not in the diagram.

```asy
// GOOD: Block contains only keyword
filldraw(processBox((0,0), 3, 1.2), lightyellow, black+linewidth(1));
label("Process", (0,0));

// BAD: Block contains a sentence
label("Read input data from file", (0,0));  // Too much text!

// GOOD: Details in comments
// Step 1: Read input data from file
filldraw(processBox((0,0), 3, 1.2), lightyellow, black+linewidth(1));
label("Read Input", (0,0));
```

---

## 3. Layout Patterns

### 3.1 Vertical Flow (Top to Bottom)

```asy
// ==========================================
// CONFIGURATION
// ==========================================
real boxWidth = 3.0;
real boxHeight = 1.2;
real verticalSpacing = 2.0;
pair startPos = (0, 0);

// ==========================================
// VERTICAL POSITIONS
// ==========================================
pair posStart    = startPos;
pair posProcess1 = startPos + (0, -verticalSpacing);
pair posDecision = startPos + (0, -2*verticalSpacing);
pair posProcess2 = startPos + (0, -3*verticalSpacing);
pair posEnd      = startPos + (0, -4*verticalSpacing);

// ==========================================
// DRAW SHAPES
// ==========================================
// Start
filldraw(terminalEllipse(posStart, 2.5, 1.0), lightyellow, black+linewidth(1));
label("Start", posStart);

// Process 1
filldraw(processBox(posProcess1, boxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Initialize", posProcess1);

// Decision
filldraw(decisionDiamond(posDecision, 2.5, 1.5), lightyellow, black+linewidth(1));
label("Valid?", posDecision);

// Process 2
filldraw(processBox(posProcess2, boxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Process", posProcess2);

// End
filldraw(terminalEllipse(posEnd, 2.5, 1.0), lightyellow, black+linewidth(1));
label("End", posEnd);

// ==========================================
// CONNECT ARROWS
// ==========================================
draw(posStart--posProcess1, arrow=Arrow);
draw(posProcess1--posDecision, arrow=Arrow);
draw(posDecision--posProcess2, arrow=Arrow);
draw(posProcess2--posEnd, arrow=Arrow);
```

### 3.2 Handling Decision Branches

```asy
// ==========================================
// DECISION BRANCHES
// ==========================================
// "Yes" branch goes down (main flow)
draw(posDecision--posProcess2, arrow=Arrow);
label("Yes", (posDecision + posProcess2)/2, E);

// "No" branch goes to the right
pair posError = posDecision + (4, 0);
filldraw(processBox(posError, boxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Error", posError);

draw(posDecision--posError, arrow=Arrow);
label("No", (posDecision + posError)/2, N);

// Merge back to main flow
pair posMerge = posProcess2 + (0, -verticalSpacing/2);
draw(posError--(posError.x, posMerge.y)--posMerge, arrow=Arrow);
```

### 3.3 Horizontal Spacing for Side Branches

```asy
// ==========================================
// CONFIGURATION
// ==========================================
real mainBoxWidth = 3.0;
real branchBoxWidth = 2.5;
real boxHeight = 1.2;
real vSpace = 2.0;
real hSpace = 4.0;

// ==========================================
// MAIN FLOW (LEFT COLUMN)
// ==========================================
pair pStart   = (0, 0);
pair pInput   = (0, -vSpace);
pair pProcess = (0, -2*vSpace);
pair pOutput  = (0, -3*vSpace);
pair pEnd     = (0, -4*vSpace);

// ==========================================
// SIDE BRANCH (RIGHT COLUMN)
// ==========================================
pair pValidate = (hSpace, -2*vSpace);
pair pRetry    = (hSpace, -vSpace);

// Draw main flow
filldraw(terminalEllipse(pStart, 2.5, 1), lightyellow, black+linewidth(1));
label("Start", pStart);

filldraw(ioParallelogram(pInput, mainBoxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Input", pInput);

filldraw(processBox(pProcess, mainBoxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Compute", pProcess);

filldraw(ioParallelogram(pOutput, mainBoxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Output", pOutput);

filldraw(terminalEllipse(pEnd, 2.5, 1), lightyellow, black+linewidth(1));
label("End", pEnd);

// Draw side branch
filldraw(decisionDiamond(pValidate, 2.5, 1.5), lightyellow, black+linewidth(1));
label("OK?", pValidate);

filldraw(processBox(pRetry, branchBoxWidth, boxHeight), lightyellow, black+linewidth(1));
label("Retry", pRetry);

// ==========================================
// ARROWS
// ==========================================
draw(pStart--pInput, arrow=Arrow);
draw(pInput--pProcess, arrow=Arrow);
draw(pProcess--pOutput, arrow=Arrow);
draw(pOutput--pEnd, arrow=Arrow);

// Side branch connections
draw(pProcess--pValidate, arrow=Arrow);
label("Check", (pProcess + pValidate)/2, N);

draw(pValidate--pRetry, arrow=Arrow);
label("No", (pValidate + pRetry)/2, W);

draw(pRetry--pInput, arrow=Arrow);
label("Retry", (pRetry + pInput)/2, N);

draw(pValidate--(pValidate.x, pOutput.y)--pOutput, arrow=Arrow);
label("Yes", (pValidate + (pValidate.x, pOutput.y))/2, E);
```

---

## 4. Styling and Aesthetics

### 4.1 Consistent Color Scheme

```asy
// ==========================================
// COLOR SCHEME
// ==========================================
pen boxFill = lightyellow;
pen boxBorder = black + linewidth(1);
pen decisionFill = lightyellow;
pen terminalFill = lightyellow;
pen arrowPen = black + linewidth(1);
pen labelPen = black;

// Alternative: Blue theme
pen boxFill = rgb(0.9, 0.95, 1.0);
pen boxBorder = rgb(0.2, 0.4, 0.6) + linewidth(1);
pen arrowPen = rgb(0.2, 0.4, 0.6) + linewidth(1);
```

### 4.2 Font Sizes

```asy
// Use LaTeX for consistent sizing
label("\small Process", center);
label("\footnotesize Valid?", center);
```

### 4.3 Spacing Guidelines

- **Box height:** 1.0–1.5 units
- **Box width:** 2.5–4.0 units (wider for longer keywords)
- **Vertical spacing:** 1.5–2.5 times box height
- **Horizontal spacing (branches):** 3.0–5.0 units
- **Arrow length:** At least 0.5 units from box edge

---

## 5. Complete Example: Algorithm Flowchart

```asy
// ==========================================
// ALGORITHM: BUBBLE SORT
// ==========================================

// ==========================================
// CONFIGURATION
// ==========================================
real bw = 3.0;      // Box width
real bh = 1.2;      // Box height
real vs = 2.2;      // Vertical spacing
real hs = 4.5;      // Horizontal spacing for branches
pen fillPen = rgb(0.95, 0.95, 1.0);
pen borderPen = rgb(0.2, 0.3, 0.5) + linewidth(1);
pen arrowPen = rgb(0.2, 0.3, 0.5) + linewidth(1);
pen labelPen = rgb(0.1, 0.1, 0.1);

// ==========================================
// SHAPE HELPERS
// ==========================================
path process(pair c, real w, real h) {
    return box(c+(-w/2,-h/2), c+(w/2,h/2));
}

path decision(pair c, real w, real h) {
    return c+(0,h/2)--c+(w/2,0)--c+(0,-h/2)--c+(-w/2,0)--cycle;
}

path terminal(pair c, real w, real h) {
    return ellipse(c, w/2, h/2);
}

// ==========================================
// NODE POSITIONS
// ==========================================
pair pStart  = (0, 0);
pair pInit   = (0, -vs);
pair pOutLoop = (0, -2*vs);
pair pInLoop  = (hs, -2*vs);
pair pCompare = (hs, -3*vs);
pair pSwap    = (hs, -4*vs);
pair pEndIn   = (0, -3*vs);
pair pEndOut  = (0, -4*vs);
pair pEnd     = (0, -5*vs);

// ==========================================
// DRAW NODES
// ==========================================
// Start
filldraw(terminal(pStart, 2.5, 1), fillPen, borderPen);
label("Start", pStart, labelPen);

// Initialize i = 0
filldraw(process(pInit, bw, bh), fillPen, borderPen);
label("$i \leftarrow 0$", pInit, labelPen);

// Outer loop: i < n-1
filldraw(decision(pOutLoop, 2.8, 1.5), fillPen, borderPen);
label("\small $i < n-1$?", pOutLoop, labelPen);

// Inner loop: j = 0
filldraw(process(pInLoop, bw, bh), fillPen, borderPen);
label("$j \leftarrow 0$", pInLoop, labelPen);

// Compare: a[j] > a[j+1]
filldraw(decision(pCompare, 3.2, 1.5), fillPen, borderPen);
label("\small $a[j] > a[j+1]$?", pCompare, labelPen);

// Swap
filldraw(process(pSwap, bw, bh), fillPen, borderPen);
label("Swap", pSwap, labelPen);

// End inner loop
filldraw(process(pEndIn, 2.5, bh), fillPen, borderPen);
label("$j \leftarrow j+1$", pEndIn, labelPen);

// End outer loop
filldraw(process(pEndOut, 2.5, bh), fillPen, borderPen);
label("$i \leftarrow i+1$", pEndOut, labelPen);

// End
filldraw(terminal(pEnd, 2.5, 1), fillPen, borderPen);
label("End", pEnd, labelPen);

// ==========================================
// ARROWS
// ==========================================
draw(pStart--pInit, arrowPen, arrow=Arrow);
draw(pInit--pOutLoop, arrowPen, arrow=Arrow);

// Outer loop: Yes -> inner loop
draw(pOutLoop--pInLoop, arrowPen, arrow=Arrow);
label("Yes", (pOutLoop+pInLoop)/2, N);

// Inner loop setup -> compare
draw(pInLoop--pCompare, arrowPen, arrow=Arrow);

// Compare: Yes -> swap
draw(pCompare--pSwap, arrowPen, arrow=Arrow);
label("Yes", (pCompare+pSwap)/2, W);

// Swap -> increment j
pair midSwap = (pSwap + pEndIn)/2;
draw(pSwap--(pSwap.x, pEndIn.y)--pEndIn, arrowPen, arrow=Arrow);

// Compare: No -> increment j (direct)
draw(pCompare--(pCompare.x, pEndIn.y)--pEndIn, arrowPen, arrow=Arrow);
label("No", (pCompare+(pCompare.x, pEndIn.y))/2, E);

// Increment j -> back to compare
pair loopBackJ = (pEndIn.x - 1.5, pEndIn.y);
draw(pEndIn--loopBackJ--(loopBackJ.x, pCompare.y)--pCompare, arrowPen, arrow=Arrow);

// Outer loop: No -> end
draw(pOutLoop--pEnd, arrowPen, arrow=Arrow);
label("No", (pOutLoop+pEnd)/2, W);

// Increment i -> back to outer loop
pair loopBackI = (pEndOut.x - 2.5, pEndOut.y);
draw(pEndOut--loopBackI--(loopBackI.x, pOutLoop.y)--pOutLoop, arrowPen, arrow=Arrow);
```

---

## 6. Advanced Patterns

### 6.1 Loop Connectors (Off-page)

For complex flowcharts, loop-back arrows can be routed around the diagram:

```asy
// Loop back on the left side
pair loopLeft = (-3, pCompare.y);
pair loopBottom = (-3, pEndIn.y);
draw(pEndIn--loopBottom--loopLeft--(loopLeft.x, pCompare.y)--pCompare, arrow=Arrow);
```

### 6.2 Parallel Processes

```asy
// Two parallel tracks
pair track1 = (0, 0);
pair track2 = (5, 0);

filldraw(processBox(track1, 3, 1.2), lightyellow, black+linewidth(1));
label("Task A", track1);

filldraw(processBox(track2, 3, 1.2), lightyellow, black+linewidth(1));
label("Task B", track2);

// Merge point
pair mergePoint = (2.5, -3);
filldraw(processBox(mergePoint, 3, 1.2), lightyellow, black+linewidth(1));
label("Merge", mergePoint);

draw(track1--(track1.x, mergePoint.y)--mergePoint, arrow=Arrow);
draw(track2--(track2.x, mergePoint.y)--mergePoint, arrow=Arrow);
```

### 6.3 Subroutine Call (Double-Bordered Box)

```asy
path outer = box((-1.5, -0.6), (1.5, 0.6));
path inner = box((-1.4, -0.5), (1.4, 0.5));

filldraw(outer, lightyellow, black+linewidth(1));
draw(inner, black+linewidth(1));
label("Subroutine", (0, 0));
```

---

## 7. Style Guide Summary

| Element | Shape | Fill | Border |
|---------|-------|------|--------|
| Start/End | Ellipse | Light yellow/blue | 1bp black |
| Process | Rectangle | Light yellow/blue | 1bp black |
| Decision | Diamond | Light yellow/blue | 1bp black |
| Input/Output | Parallelogram | Light yellow/blue | 1bp black |
| Subroutine | Double rectangle | Light yellow/blue | 1bp black |

| Rule | Guideline |
|------|-----------|
| Block content | 1-3 words only |
| Details | In comments, not blocks |
| Spacing | 1.5-2.5x box height vertically |
| Branch spacing | 3-5 units horizontally |
| Arrow style | `arrow=Arrow` with consistent pen |
| Colors | Consistent theme throughout |
| Labels | Use LaTeX math mode for variables |

---

## 8. Common Pitfalls

1. **Text overflow:** Never put sentences in blocks. Use keywords only.

2. **Inconsistent sizing:** Use named constants for all dimensions.

3. **Arrow crossings:** Route arrows around the diagram perimeter when possible.

4. **Missing merge points:** Every branch should eventually merge back or end.

5. **No start/end:** Every flowchart must have exactly one start and at least one end.

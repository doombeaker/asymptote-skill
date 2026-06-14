# CAD and Engineering Drawings with Asymptote

## Using the CAD Module

```asy
import CAD;
```

The `CAD.asy` module provides standard line types and conventions for technical and engineering drawings following ISO/DIN standards.

## Line Types

The CAD module defines standard line types for technical drawings:

```asy
sCAD cad = sCAD.Create(1);  // Create with line group 1 (standard)

// Common line types
cad.pVisibleEdge;        // Visible edges (solid, full width)
cad.pInvisibleEdge;      // Hidden edges (dashed)
cad.pMiddleLine;         // Center lines (dash-dot)
cad.pMeasureLine;        // Dimension lines (thin solid)
cad.pMeasureHelpLine;    // Extension lines (thin solid)
cad.pHatch;              // Hatching lines (thin solid)
cad.pSectionPlane;       // Cutting plane lines (thick chain)
cad.pSymmetryLine;       // Symmetry lines (dash-dot)
```

## Line Groups

The `Create()` function accepts a line group parameter (0-3) that controls line widths:

```asy
sCAD cad0 = sCAD.Create(0);  // Fine (0.35mm/0.18mm)
sCAD cad1 = sCAD.Create(1);  // Medium (0.5mm/0.25mm) - default
sCAD cad2 = sCAD.Create(2);  // Thick (0.7mm/0.35mm)
sCAD cad3 = sCAD.Create(3);  // Extra thick (1.0mm/0.5mm)
```

## Dimensioning

```asy
// Linear dimension
draw((0,0)--(3,0), cad.pMeasureLine);
draw((0,-0.2)--(0,0.2), cad.pMeasureHelpLine);
draw((3,-0.2)--(3,0.2), cad.pMeasureHelpLine);
label("30", (1.5,-0.5), S);

// Angular dimension
// (Use arc and label with angle)
```

## Section Views

```asy
// Cutting plane line
draw((0,2)--(4,2), cad.pSectionPlane);

// Hatching
path section = (1,0)--(3,0)--(3,2)--(1,2)--cycle;
fill(section, pattern("hatch"));
```

## Technical Drawing Example

```asy
import CAD;

sCAD cad = sCAD.Create(1);

// Main outline
path outline = (0,0)--(4,0)--(4,3)--(0,3)--cycle;
draw(outline, cad.pVisibleEdge);

// Hidden feature
path hidden = (1,1)--(3,1)--(3,2)--(1,2)--cycle;
draw(hidden, cad.pInvisibleEdge);

// Center lines
draw((2,-0.3)--(2,3.3), cad.pMiddleLine);
draw((-0.3,1.5)--(4.3,1.5), cad.pMiddleLine);

// Hole
draw(circle((2,1.5), 0.5), cad.pVisibleEdge);

// Dimensions
draw((0,-0.5)--(4,-0.5), cad.pMeasureLine);
draw((0,-0.3)--(0,-0.7), cad.pMeasureHelpLine);
draw((4,-0.3)--(4,-0.7), cad.pMeasureHelpLine);
label("40", (2,-0.8), S);
```

## Geometric Tolerancing Symbols

```asy
// Flatness symbol
label("$\\square$", (0,0));    // flatness
label("$\\circ$", (0,0));      // circularity
label("$\\perp$", (0,0));      // perpendicularity
label("$\\parallel$", (0,0));  // parallelism
label("$\\phi$", (0,0));       // diameter
```

## Title Block

```asy
void titleblock(pair ll, real w=8cm, real h=1.5cm) {
    path p = box(ll, ll+(w,h));
    draw(p, cad.pVisibleEdge);
    
    // Dividers
    real col1 = w*0.5;
    real col2 = w*0.75;
    draw((ll.x+col1,ll.y)--(ll.x+col1,ll.y+h), cad.pVisibleEdge);
    draw((ll.x+col2,ll.y)--(ll.x+col2,ll.y+h), cad.pVisibleEdge);
    
    // Labels
    label("Title", (ll.x+col1/2, ll.y+h/2));
    label("Scale", (ll.x+(col1+col2)/2, ll.y+h/2));
    label("Date", (ll.x+(col2+w)/2, ll.y+h/2));
}
```

## Tips for Engineering Drawings

1. **Follow standards** — use appropriate line types for each feature
2. **Consistent scale** — define `unitsize()` for metric or imperial
3. **Layer objects** — use `layer()` for complex drawings
4. **Use grids** — `add(grid(...))` for alignment
5. **Dimension properly** — follow ISO 129 standards
6. **Title blocks** — always include drawing metadata

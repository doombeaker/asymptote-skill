# Asymptote Basics

## Core Language Syntax

Asymptote uses C++-like syntax with mathematical orientation.

### Data Types

```asy
int n = 5;
real x = 3.14159;
pair z = (1, 2);           // 2D point/coordinate
triple v = (1, 2, 3);      // 3D point
color c = red;             // color
pen p = red+linewidth(1);  // drawing pen
path g = (0,0)--(1,1);     // path
path[] gg = {g, (1,0)--(0,1)};  // path array
```

### Basic Drawing Commands

#### draw
```asy
void draw(picture pic=currentpicture, Label L="", path g,
          align align=NoAlign, pen p=currentpen,
          arrowbar arrow=None, arrowbar bar=None, margin margin=NoMargin,
          Label legend="", marker marker=nomarker);
```

Examples:
```asy
// Define endpoints with meaningful names
pair origin = (0,0);
pair target = (100,100);

// Basic line drawing with named variables
draw(origin--target);                                    // simple line
draw(origin--(1,1), red);                                // colored line
draw(origin--(1,1), arrow=Arrow);                        // with arrow
draw(origin--(1,1), arrow=Arrows);                       // arrows both ends
draw(origin--(1,1), bar=Bars);                           // dimension bars

// Use a named path for reusable geometry
path unitCircle = circle(origin, 1);
draw(unitCircle, dashed);                                // dashed circle

// Combine pens descriptively
pen thickRed = red + linewidth(2);
draw(unitCircle, thickRed);                              // thick red circle
```

#### fill
```asy
void fill(picture pic=currentpicture, path g, pen p=currentpen);
void filldraw(picture pic=currentpicture, path g, pen fillpen=currentpen,
              pen drawpen=currentpen);
```

Examples:
```asy
fill(unitsquare, blue);
filldraw(circle((0,0),1), yellow, black);         // fill yellow, outline black
```

#### clip
```asy
void clip(picture pic=currentpicture, path g);
```

#### label
```asy
void label(picture pic=currentpicture, Label L, pair position,
           align align=NoAlign, pen p=currentpen, filltype filltype=NoFill);
```

Examples:
```asy
label("$A$", (0,0), NE);
label("$E=mc^2$", (0,0), N, blue);
label(rotate(45)*"Rotated", (1,1), E);
```

### Path Construction

```asy
// ==========================================
// STRAIGHT LINE SEGMENTS
// ==========================================
pair bottomLeft = (0,0);
pair bottomRight = (1,0);
pair topRight = (1,1);
pair topLeft = (0,1);

// A square path constructed from named corners
path squarePath = bottomLeft--bottomRight--topRight--topLeft--cycle;

// Single segment
path diagonal = bottomLeft--topRight;

// ==========================================
// BEZIER CURVES (CUBIC SPLINES)
// ==========================================
pair curveStart = (0,0);
pair curveMid = (1,1);
pair curveEnd = (2,0);

path smoothCurve = curveStart..curveMid..curveEnd;
path directedCurve = curveStart{up}..curveMid..{down}curveEnd;
path controlledCurve = curveStart..controls (1,1) and (2,1)..(3,0);

// ==========================================
// CIRCULAR ARCS
// ==========================================
pair arcCenter = (0,0);
path quarterArc = arc(arcCenter, 1, 0, 90);                     // center, radius, angle1, angle2
path arcThroughPoints = arc(arcCenter, (1,0), (0,1), CCW);      // arc through two points

// ==========================================
// CIRCLES AND ELLIPSES
// ==========================================
path unitCirc = circle(arcCenter, 1);
path ellipseShape = ellipse(arcCenter, 2, 1);

// ==========================================
// PREDEFINED PATHS
// ==========================================
unitsquare;        // (0,0)--(1,0)--(1,1)--(0,1)--cycle
unitcircle;        // E..N..W..S..cycle
box((0,0),(1,1));  // rectangle with given corners
```

### Path Operators

```asy
path g1 = (0,0)--(1,0);
path g2 = (1,0)--(1,1);
path g = g1 & g2;           // concatenate (must share endpoint)
path g = g1 ^^ g2;          // group into path[] array (move pen, don't connect)
path g = reverse(g1);       // reverse direction
path g = subpath(g1, 0, 0.5);  // extract subpath (t from 0 to 1)
```

### Pens

```asy
// Define pens with descriptive names for consistent styling
pen mainColor = red;
pen customRGB = rgb(0.5, 0.2, 0.8);
pen customCMYK = cmyk(0.1, 0.2, 0.3, 0.4);
pen thinLine = linewidth(1);              // line width in bp
pen metricLine = linewidth(0.5mm);        // line width in mm
pen dashPattern = dashed;
pen dotPattern = dotted;
pen customDash = linetype(new real[] {4,2,1,2});
pen capStyle = squarecap;                 // line cap style
pen joinStyle = miterjoin;                // line join style
pen semiTransparent = opacity(0.5);       // transparency

// Combine pens into reusable styles
pen highlightStyle = red + linewidth(2) + dashed + squarecap;
pen annotationStyle = blue + linewidth(0.5) + dotted;
```

### Transforms

```asy
// Name transforms descriptively to clarify intent
transform moveRight = shift((1,2));          // translation
transform doubleSize = scale(2);             // uniform scaling
transform stretchX = xscale(2);              // x-only scaling
transform compressY = yscale(0.5);           // y-only scaling
transform rotate45 = rotate(45);             // rotation in degrees
transform mirrorDiag = reflect((0,0),(1,1)); // reflection across line
transform shear = slant(0.5);                // slant transform

// Apply named transforms to geometry
pair testPoint = (1,0);
pair movedPoint = moveRight * testPoint;
path transformedSquare = rotate45 * unitsquare;
```

### Figure Size and Scaling

```asy
size(100, 100);                   // width, height in bp
size(5cm, 3cm);                   // metric units
size(0, 100);                     // 0 = no restriction in that dimension
unitsize(1cm);                    // make coordinates represent cm
```

### Arrows and Markers

```asy
// Arrow specifiers
None, Blank, BeginArrow, MidArrow, EndArrow (Arrow), Arrows
BeginArcArrow, EndArcArrow (ArcArrow), MidArcArrow, ArcArrows

// Custom arrow
arrowbar myArrow = Arrow(arrowhead=HookHead, size=3mm, angle=20, filltype=Draw);

// Arrowhead styles
DefaultHead, SimpleHead, HookHead, TeXHead

// Bar specifiers (for dimensions)
None, BeginBar, EndBar (Bar), Bars

// Margins
NoMargin, BeginMargin, EndMargin (Margin), Margins
Margin(real begin, real end=begin)
PenMargin, PenMargins, DotMargin, TrueMargin
```

### Fill Types

```asy
Fill, FillDraw, Draw, NoFill, UnFill
Fill(pen), FillDraw(pen, pen)
```

### Loops and Arrays

```asy
// Define grid parameters as named constants
int numLines = 10;
real lineHeight = 1.0;

// Draw vertical grid lines using a loop
for (int i = 0; i < numLines; ++i) {
    pair bottom = (i, 0);
    pair top = (i, lineHeight);
    draw(bottom--top);
}

// Array of named points for a polygon
pair[] triangleVertices = {(0,0), (1,0), (0.5,1)};
real[] sampleXCoords = {1, 2, 3, 4, 5};
```

### Functions

```asy
real f(real x) { return x^2; }
path graph(real f(real), real a, real b, int n=100);

// Anonymous functions
real g(real x) = x^3;
```

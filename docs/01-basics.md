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
draw((0,0)--(100,100));                          // simple line
draw((0,0)--(1,1), red);                          // colored line
draw((0,0)--(1,1), arrow=Arrow);                  // with arrow
draw((0,0)--(1,1), arrow=Arrows);                 // arrows both ends
draw((0,0)--(1,1), bar=Bars);                     // dimension bars
draw(circle((0,0),1), dashed);                    // dashed circle
draw(g, red+linewidth(2));                        // thick red line
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
// Straight line segments
path g = (0,0)--(1,0)--(1,1)--(0,1)--cycle;       // square
path g = (0,0)--(1,1);                             // single segment

// Bezier curves (cubic splines)
path g = (0,0)..(1,1)..(2,0);                      // smooth curve
path g = (0,0){up}..(1,1)..{down}(2,0);            // with direction hints
path g = (0,0)..controls (1,1) and (2,1)..(3,0);   // explicit control points

// Circular arcs
path g = arc((0,0), 1, 0, 90);                     // arc: center, radius, angle1, angle2
path g = arc((0,0), (1,0), (0,1), CCW);            // arc through two points

// Circles and ellipses
path c = circle((0,0), 1);
path e = ellipse((0,0), 2, 1);

// Predefined paths
unitsquare;    // (0,0)--(1,0)--(1,1)--(0,1)--cycle
unitcircle;    // E..N..W..S..cycle
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
pen p = red;                      // color
pen p = rgb(0.5, 0.2, 0.8);     // RGB color
pen p = cmyk(0.1, 0.2, 0.3, 0.4); // CMYK color
pen p = linewidth(1);             // line width in bp
pen p = linewidth(0.5mm);         // line width in mm
pen p = dashed;                   // dash pattern
pen p = dotted;
pen p = linetype(new real[] {4,2,1,2}); // custom dash pattern
pen p = squarecap;                // line cap style
pen p = miterjoin;                // line join style
pen p = opacity(0.5);             // transparency

// Combine pens
pen p = red + linewidth(2) + dashed + squarecap;
```

### Transforms

```asy
transform t = shift((1,2));       // translation
transform t = scale(2);           // uniform scaling
transform t = xscale(2);          // x-only scaling
transform t = yscale(0.5);        // y-only scaling
transform t = rotate(45);         // rotation in degrees
transform t = reflect((0,0),(1,1)); // reflection across line
transform t = slant(0.5);         // slant transform

// Apply transform
pair p = t*(1,0);
path g = t*unitsquare;
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
// For loop
for(int i=0; i < 10; ++i) {
    draw((i,0)--(i,1));
}

// Array operations
pair[] pts = {(0,0), (1,0), (0.5,1)};
real[] xs = {1, 2, 3, 4, 5};
```

### Functions

```asy
real f(real x) { return x^2; }
path graph(real f(real), real a, real b, int n=100);

// Anonymous functions
real g(real x) = x^3;
```

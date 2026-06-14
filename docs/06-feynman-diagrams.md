# Feynman Diagrams with Asymptote

## Using the feynman Module

```asy
import feynman;
```

The `feynman.asy` module provides specialized tools for drawing particle physics Feynman diagrams.

## Setup and Defaults

```asy
import feynman;

// Set default line width
currentpen = linewidth(0.8);

// Scale all defaults appropriately
fmdefaults();

// Disable middle arrows if desired
currentarrow = None;
```

## Particle Lines

### Fermion Lines
```asy
// Straight fermion line
drawFermion((0,0)--(2,0));

// Fermion with arrow
currentarrow = Arrow;
drawFermion((0,0)--(2,0));

// Curved fermion
drawFermion((0,0){up}..(1,1)..{down}(2,0));
```

### Photon Lines
```asy
// Wavy photon line
drawPhoton((0,0)--(2,0));

// With amplitude and width
drawPhoton((0,0)--(2,0), amplitude=0.3, width=0.1);
```

### Gluon Lines
```asy
// Coiled gluon line
drawGluon((0,0)--(2,0));

// Curved gluon
drawGluon(arc((1,0), (0,0), (2,0)));
```

### Scalar Lines
```asy
// Dashed scalar line
drawScalar((0,0)--(2,0));
```

### Ghost Lines
```asy
// Dotted ghost line
drawGhost((0,0)--(2,0));
```

## Vertices

```asy
// Simple dot vertex
drawVertex((1,0));

// Cross vertex (for QCD vertices)
drawVertexOX((1,0));

// Box vertex
drawVertexBox((1,0));

// Big cross vertex
drawVertexBoxX((1,0));

// Blob vertex (for effective vertices)
drawVertexBlob((1,0));
```

## Momentum Arrows

```asy
// Add momentum arrow to a line
drawMomentumArrow((0,0)--(2,0), "$p$");
drawMomentumArrow((0,0)--(2,0), "$p$", offset=0.2);
```

## Complete Example: QED Vertex

```asy
import feynman;

pair a = (0,0);
pair b = (2,0);
pair c = (1,1.5);

// Incoming fermion
drawFermion(a--b);

// Photon
drawPhoton(b--c);

// Vertex
drawVertex(b);

// Labels
label("$e^-$", a, W);
label("$e^-$", c, N);
label("$\\gamma$", (b+c)/2, E);
```

## Complete Example: QCD Gluon Exchange

```asy
import feynman;

currentpen = linewidth(0.8);
fmdefaults();

pair xu = (-40,45);
pair xl = (-40,-45);
pair yu = (40,45);
pair yl = (40,-45);
pair zu = (0,5);
pair zl = (0,-5);

// Fermion lines
drawFermion(xu--zu--yu);
drawFermion(xl--zl--yl);

// Vertices
drawVertexOX(zu);
drawVertexOX(zl);

// Gluon
drawGluon(arc((0,0), (-20,25), (-20,-25), CW));

// Labels
label("$q$", xu, W);
label("$q$", yu, E);
label("$q$", xl, W);
label("$q$", yl, E);
```

## Double Lines

```asy
// Double line (for cut propagators or Wilson lines)
drawDoubleLine((0,0)--(2,0));
```

## Customizing Appearance

```asy
// Change default pens
gluonpen = red;
photonpen = blue;
fermionpen = black;
scalarpen = green+dashed;
vertexpen = black;

// Change sizes
vertexsize = 0.05cm;
gluonamplitude = 0.2;
photonamplitude = 0.15;
```

## Tips for Feynman Diagrams

1. Always call `fmdefaults()` after setting `currentpen`
2. Use `overpaint=true` to prevent line overlap issues
3. The order of drawing matters: draw underlying lines first
4. Use `arc()` for curved boson lines between vertices
5. Momentum arrows are added after drawing the main line

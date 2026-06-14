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

// Vertex positions with descriptive names
pair incomingPos = (0,0);
pair vertexPos = (2,0);
pair outgoingPos = (1,1.5);

// Incoming fermion line
drawFermion(incomingPos--vertexPos);

// Photon line emitted from vertex
drawPhoton(vertexPos--outgoingPos);

// Interaction vertex
drawVertex(vertexPos);

// Particle labels
label("$e^-$", incomingPos, W);
label("$e^-$", outgoingPos, N);
label("$\\gamma$", (vertexPos + outgoingPos)/2, E);
```

## Complete Example: QCD Gluon Exchange

```asy
import feynman;

// Feynman diagram styling
currentpen = linewidth(0.8);
fmdefaults();

// Left-side quark positions (incoming)
pair upperQuarkLeft = (-40,45);
pair lowerQuarkLeft = (-40,-45);

// Right-side quark positions (outgoing)
pair upperQuarkRight = (40,45);
pair lowerQuarkRight = (40,-45);

// Interaction vertices
pair upperVertex = (0,5);
pair lowerVertex = (0,-5);

// Fermion lines for both quarks
drawFermion(upperQuarkLeft--upperVertex--upperQuarkRight);
drawFermion(lowerQuarkLeft--lowerVertex--lowerQuarkRight);

// QCD vertices (cross style)
drawVertexOX(upperVertex);
drawVertexOX(lowerVertex);

// Gluon exchange between vertices
drawGluon(arc((0,0), (-20,25), (-20,-25), CW));

// Quark labels
label("$q$", upperQuarkLeft, W);
label("$q$", upperQuarkRight, E);
label("$q$", lowerQuarkLeft, W);
label("$q$", lowerQuarkRight, E);
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

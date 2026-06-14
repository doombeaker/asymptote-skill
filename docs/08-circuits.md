# Circuit Diagrams with Asymptote

## Overview

Asymptote does not have a dedicated circuit diagram module like `circuitikz` for LaTeX. However, it is fully capable of drawing circuit diagrams using its primitive drawing commands and the geometry module. This document provides conventions and techniques for creating clean, professional circuit schematics.

## Basic Circuit Elements

### Resistor
```asy
path resistor(pair a, pair b, real width=0.3, int zigzags=5) {
    pair mid = (a+b)/2;
    pair dir = unit(b-a);
    pair perp = rotate(90)*dir;
    real len = length(b-a);
    real step = len/zigzags;
    
    guide g = a;
    for(int i=0; i < zigzags; ++i) {
        real t = i*step;
        g = g--(a+t*dir+width*perp)--(a+(t+step/2)*dir-width*perp);
    }
    g = g--b;
    return g;
}

// Usage
pair A = (0,0), B = (2,0);
draw(A--resistor(A,B)--B);
label("$R_1$", (A+B)/2, N);
```

### Capacitor
```asy
void capacitor(pair a, pair b, real gap=0.2) {
    pair mid = (a+b)/2;
    pair dir = unit(b-a);
    pair perp = rotate(90)*dir;
    
    pair p1 = mid - gap*dir/2;
    pair p2 = mid + gap*dir/2;
    
    draw(a--p1);
    draw(p2--b);
    draw(p1+0.3*perp--p1-0.3*perp, linewidth(1));
    draw(p2+0.3*perp--p2-0.3*perp, linewidth(1));
}
```

### Inductor
```asy
path inductor(pair a, pair b, int loops=4) {
    pair dir = unit(b-a);
    pair perp = rotate(90)*dir;
    real len = length(b-a);
    real loopwidth = len/loops;
    
    guide g = a;
    for(int i=0; i < loops; ++i) {
        real t = i*loopwidth;
        g = g..(a+(t+loopwidth/2)*dir+0.2*perp)..(a+(t+loopwidth)*dir);
    }
    g = g..b;
    return g;
}
```

### Battery
```asy
void battery(pair a, pair b) {
    pair mid = (a+b)/2;
    pair dir = unit(b-a);
    pair perp = rotate(90)*dir;
    
    pair p1 = mid - 0.15*dir;
    pair p2 = mid + 0.15*dir;
    
    draw(a--p1);
    draw(p2--b);
    draw(p1+0.15*perp--p1-0.15*perp, linewidth(2));  // long line = +
    draw(p2+0.05*perp--p2-0.05*perp, linewidth(1));  // short line = -
    
    label("$+$", p1+0.25*perp, N);
    label("$-$", p2-0.25*perp, S);
}
```

### Ground
```asy
void ground(pair p) {
    draw(p--p+(0,-0.3));
    draw((p+(-0.2,-0.3))--(p+(0.2,-0.3)), linewidth(1));
    draw((p+(-0.1,-0.4))--(p+(0.1,-0.4)), linewidth(0.5));
    draw((p+(-0.05,-0.5))--(p+(0.05,-0.5)), linewidth(0.5));
}
```

## Complete Circuit Example

```asy
size(300,200);

// ==========================================
// NODE DEFINITIONS
// ==========================================
pair topLeft = (0,2);
pair topRight = (3,2);
pair bottomRight = (3,0);
pair bottomLeft = (0,0);

// ==========================================
// TOP BRANCH: Resistor
// ==========================================
draw(topLeft--topRight);
label("$R_1$", (topLeft + topRight)/2, N);

// ==========================================
// RIGHT BRANCH: Capacitor
// ==========================================
capacitor(topRight, bottomRight);
label("$C_1$", (topRight + bottomRight)/2, E);

// ==========================================
// BOTTOM BRANCH: Wire
// ==========================================
draw(bottomRight--bottomLeft);

// ==========================================
// LEFT BRANCH: Battery (power source)
// ==========================================
battery(bottomLeft, topLeft);
label("$V_{in}$", (bottomLeft + topLeft)/2, W);

// ==========================================
// GROUND AND OUTPUT LABELS
// ==========================================
ground(bottomRight);
label("$V_{out}$", topRight, NE);
```

## Operational Amplifier

```asy
void opamp(pair center, real scale=1) {
    pair[] pts = {
        scale*(-0.5,-0.5), scale*(0.5,0), scale*(-0.5,0.5)
    };
    path p = pts[0]--pts[1]--pts[2]--cycle;
    draw(p);
    
    // Input labels
    label("$-$", center+scale*(-0.35,-0.25), E);
    label("$+$", center+scale*(-0.35,0.25), E);
    
    // Output
    label("OUT", center+scale*(0.35,0), W);
}
```

## Grid-Based Layout

```asy
// Use a grid for consistent spacing
real gridSpacingX = 1.5;   // horizontal spacing between nodes
real gridSpacingY = 1.5;   // vertical spacing between nodes

// Helper function to compute grid node positions
pair gridNode(int col, int row) {
    return (col * gridSpacingX, row * gridSpacingY);
}

// Place components on the grid using named positions
pair nodeStart = gridNode(0,1);
pair nodeBeforeResistor = gridNode(1,1);
pair nodeAfterResistor = gridNode(2,1);
pair nodeEnd = gridNode(3,1);

draw(nodeStart--nodeBeforeResistor);
resistor(nodeBeforeResistor, nodeAfterResistor);
draw(nodeAfterResistor--nodeEnd);
```

## Tips for Circuit Diagrams

1. **Use consistent spacing** — define grid units and stick to them
2. **Group components** — use `picture` objects for reusable subcircuits
3. **Label clearly** — place labels near components with appropriate alignment
4. **Use colors** — different colors for power, ground, signals
5. **Draw nodes** — use `dot()` for connection points
6. **Orthogonal wiring** — use only horizontal and vertical lines when possible

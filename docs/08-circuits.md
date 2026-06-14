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

// Define nodes
pair A = (0,2);
pair B = (3,2);
pair C = (3,0);
pair D = (0,0);

// Draw components
draw(A--B);
label("$R_1$", (A+B)/2, N);

capacitor(B, C);
label("$C_1$", (B+C)/2, E);

draw(C--D);
battery(D, A);
label("$V_{in}$", (D+A)/2, W);

// Ground
ground(C);

// Voltage labels
label("$V_{out}$", B, NE);
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
real dx = 1.5;  // horizontal spacing
real dy = 1.5;  // vertical spacing

pair node(int i, int j) {
    return (i*dx, j*dy);
}

// Place components on grid
draw(node(0,1)--node(1,1));
resistor(node(1,1), node(2,1));
draw(node(2,1)--node(3,1));
```

## Tips for Circuit Diagrams

1. **Use consistent spacing** — define grid units and stick to them
2. **Group components** — use `picture` objects for reusable subcircuits
3. **Label clearly** — place labels near components with appropriate alignment
4. **Use colors** — different colors for power, ground, signals
5. **Draw nodes** — use `dot()` for connection points
6. **Orthogonal wiring** — use only horizontal and vertical lines when possible

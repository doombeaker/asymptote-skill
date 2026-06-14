# Animations with Asymptote

## Using the animation Module

```asy
import animate;
```

or

```asy
import animation;
```

The `animation.asy` module provides frame-based animation generation. The `animate` module is a thin wrapper that loads `animation` and sets up LaTeX `animate` package support.

## Basic Animation Setup

```asy
import animate;

animation a;

// Generate frames
for(int i=0; i < 30; ++i) {
    save();
    // Draw frame content
    draw(circle((0,0), i/10.0));
    a.add();
    restore();
}

// Export
a.movie(loops=3, delay=50);  // delay in milliseconds
```

## Animation Object Methods

```asy
animation a;

// Add current picture as frame
a.add();

// Add a specific picture
a.add(pic);

// Export as movie (requires ImageMagick)
a.movie(loops=0, delay=100);

// Export as multipage PDF
a.pdf("output.pdf");

// Export individual frames
a.export("frame", format="png");
```

## Frame Management

```asy
// Clear all frames
a.clear();

// Get number of frames
int n = a.pictures.length;
```

## Common Animation Patterns

### Rotating Object
```asy
import animate;

animation a;

for(int i=0; i < 36; ++i) {
    save();
    draw(rotate(10*i)*unitsquare, blue);
    a.add();
    restore();
}

a.movie(loops=0, delay=100);
```

### Growing Circle
```asy
import animate;

animation a;

for(int i=1; i <= 20; ++i) {
    save();
    filldraw(circle((0,0), i/5.0), paleblue, blue);
    a.add();
    restore();
}

a.movie(loops=2, delay=100);
```

### Parametric Curve Drawing
```asy
import animate;
import graph;

animation a;
real f(real x) { return sin(x); }

for(int i=1; i <= 50; ++i) {
    save();
    draw(graph(f, 0, 2pi*i/50), red);
    xaxis("$x$"); yaxis("$y$");
    a.add();
    restore();
}

a.movie(delay=50);
```

### 3D Rotation
```asy
import animate;
import three;

animation a;

for(int i=0; i < 36; ++i) {
    save();
    currentprojection = perspective(5*cos(2pi*i/36), 5*sin(2pi*i/36), 2);
    draw(unitcube, blue);
    a.add();
    restore();
}

a.movie(delay=100);
```

## Advanced Animation with Controls

```asy
import animate;

animation a;

// Global settings
settings.tex = "pdflatex";

for(int i=0; i < 60; ++i) {
    save();
    
    // Complex frame
    real t = i/60.0;
    pair center = (2*cos(2pi*t), 2*sin(2pi*t));
    filldraw(circle(center, 0.5), red);
    draw(circle((0,0), 2), dashed);
    
    a.add();
    restore();
}

// With custom options
a.movie(loops=0, delay=50, controls=true);
```

## Embedded Animations in LaTeX

```asy
// This creates an animation for use with LaTeX animate package
import animate;

animation a;

for(int i=0; i < 30; ++i) {
    save();
    // ... draw frame ...
    a.add();
    restore();
}

// The default output works with \animategraphics in LaTeX
a.movie();
```

In LaTeX:
```latex
\usepackage{animate}
% ...
\animategraphics[controls,loop]{12}{output}{}{}
```

## Tips for Animations

1. Always use `save()` and `restore()` between frames
2. Keep frame content independent; don't rely on cumulative drawing
3. Use `settings.render` for 3D animation quality
4. For smooth animations, use at least 24-30 frames per second
5. Test with a small number of frames first
6. Use `settings.outformat = "pdf"` for LaTeX-embedded animations

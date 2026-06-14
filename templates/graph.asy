// Template: Scientific Graph
// Use this as a starting point for 2D function plots

import graph;

size(10cm, 6cm);

// Define functions
real f(real x) { return sin(x); }
real g(real x) { return cos(x); }

// Set axis limits
xlimits(-pi, pi);
ylimits(-1.5, 1.5);

// Draw functions
draw(graph(f, -pi, pi, n=200), red, "$\\sin x$");
draw(graph(g, -pi, pi, n=200), blue, "$\\cos x$");

// Draw axes
xaxis("$x$", BottomTop, LeftTicks(Step=pi/2, step=pi/4, NoZero));
yaxis("$y$", LeftRight, RightTicks(Step=0.5, step=0.25));

// Legend
attach(legend(), point(NE), 20SE);

// Grid
add(grid(-pi, pi, -1.5, 1.5, gray+0.3));

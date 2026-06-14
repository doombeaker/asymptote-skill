# Scientific Graphs with Asymptote

## Using the graph Module

```asy
import graph;
```

The `graph.asy` module provides comprehensive scientific plotting capabilities.

## Basic Function Plotting

```asy
import graph;

size(200,150);

real f(real x) { return sin(x); }
real g(real x) { return cos(x); }

draw(graph(f, -pi, pi), red, "$\\sin x$");
draw(graph(g, -pi, pi), blue, "$\\cos x$");

xaxis("$x$", arrow=Arrow);
yaxis("$y$", arrow=Arrow);
```

## Axes and Ticks

```asy
// Basic axis
xaxis("$x$", BottomTop, LeftTicks);
yaxis("$y$", LeftRight, RightTicks);

// Axis with custom ticks
xaxis("$x$", BottomTop, LeftTicks(Step=1, step=0.5, NoZero));
yaxis("$y$", LeftRight, RightTicks(Step=2));

// Logarithmic axis
xaxis("$x$", BottomTop, LeftTicks(Label(), begin=false, end=false), Log);
yaxis("$y$", LeftRight, RightTicks, Log);

// Custom tick labels
string[] labels = {"Jan", "Feb", "Mar"};
xaxis("Month", Bottom, Ticks(Step=1, step=1, labels), begin=false, end=false);
```

## Data Plotting

```asy
// From arrays
real[] x = {1,2,3,4,5};
real[] y = {1,4,9,16,25};
draw(graph(x, y), red);

// From file
file fin = input("data.txt").line().csv();
real[] x = fin.dimension(0,0);
real[] y = fin.dimension(1,0);
draw(graph(x, y));

// Scatter plot
for(int i=0; i < x.length; ++i) {
    dot((x[i], y[i]));
}
```

## Legends

```asy
legend("$\\sin x$", red);
legend("$\\cos x$", blue);
attach(legend(), point(N), 10N);
```

## Polar Plots

```asy
import graph;

real f(real t) { return 1+cos(t); }  // cardioid
path g = polargraph(f, 0, 2pi);
filldraw(g, pink);
xaxis("$x$", above=true);
yaxis("$y$", above=true);
```

## Parametric Plots

```asy
real x(real t) { return cos(t); }
real y(real t) { return sin(t); }
draw(graph(x, y, 0, 2pi));
```

## 3D Graphs (graph3)

```asy
import graph3;

size(200,150,IgnoreAspect);

currentprojection = perspective(6,3,2);

// Surface plot
real f(pair z) { return z.x^2 + z.y^2; }
draw(surface(f, (-2,-2), (2,2), nx=20, ny=20), paleblue);

// Parametric surface
triple f(pair z) {
    real u = z.x, v = z.y;
    return (cos(u)*cos(v), cos(u)*sin(v), sin(u));
}
draw(surface(f, (0,0), (pi,2pi), nu=20, nv=20), paleyellow);

xaxis3("$x$", arrow=Arrow3);
yaxis3("$y$", arrow=Arrow3);
zaxis3("$z$", arrow=Arrow3);
```

## Contour Plots

```asy
import contour;

real f(pair z) { return z.x^2 - z.y^2; }

// Contour lines
contour(f, (-2,-2), (2,2), new real[]{-1,0,1});

// Filled contours
import palette;
palette(contour(f, (-2,-2), (2,2), 20), Rainbow());
```

## Color Palettes

```asy
import palette;

// Available palettes
Rainbow(), Grayscale(), BWRainbow(), DarkRainbow(), Neon()
// Custom palette
pen[] palette = gradient(red, green, blue);
```

## Scaling and Limits

```asy
scale(Log(true), Linear(true));  // log x, linear y
xlimits(1, 1000);
ylimits(0, 10);
```

## Error Bars

```asy
real[] x = {1,2,3};
real[] y = {2,4,6};
real[] dy = {0.5, 0.3, 0.4};
draw(graph(x, y), red);
errorbars(x, y, dy, red);
```

## Multiple Y Axes

```asy
picture q = secondaryY(new void(picture p) {
    scale(p, Linear, Linear);
    draw(p, graph(f2, a, b), blue);
    yaxis(p, "Secondary", Right, blue);
});
add(q);
```

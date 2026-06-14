// Template: 3D Surface Plot
// Use this as a starting point for 3D graphics

import three;
import graph3;
import palette;

size(10cm, 8cm, IgnoreAspect);

// Set projection
currentprojection = perspective(6, 3, 2);

// Define surface function
real f(pair z) {
    real x = z.x, y = z.y;
    return sin(x)*cos(y);
}

// Draw surface with color mapping
surface s = surface(f, (-pi,-pi), (pi,pi), nx=50, ny=50, Spline);
s.colors(palette(s.map(zpart), Rainbow()));
draw(s);

// Draw axes
xaxis3("$x$", Bounds, InTicks(Step=pi, step=pi/2));
yaxis3("$y$", Bounds, InTicks(Step=pi, step=pi/2));
zaxis3("$z$", Bounds, InTicks(Step=0.5, step=0.25));

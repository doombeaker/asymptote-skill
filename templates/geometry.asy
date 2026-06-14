// Template: Basic 2D Geometry Drawing
// Use this as a starting point for geometric figures

size(10cm, 0);        // width=10cm, height auto-scaled
import geometry;      // import geometry module

// Define points
pair A = (0, 0);
pair B = (3, 0);
pair C = (1.5, 2.5);

// Draw triangle
draw(A--B--C--cycle, linewidth(1));

// Mark angles
markangle("$\\alpha$", B, A, C, radius=0.5cm);
markangle("$\\beta$", C, B, A, radius=0.5cm);
markangle("$\\gamma$", A, C, B, radius=0.5cm);

// Mark sides
draw(A--B, bar=Bars);     // dimension bar

// Labels
label("$A$", A, SW);
label("$B$", B, SE);
label("$C$", C, N);

// Optional: circumcircle
circle circ = circle(A, B, C);
draw(circ, dashed+gray);

// Optional: orthocenter
pair H = orthocenter(A, B, C);
dot("$H$", H, NE);

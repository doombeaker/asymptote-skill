# 2D Geometry with Asymptote

## Using the geometry Module

```asy
import geometry;
```

The `geometry.asy` module provides advanced geometric constructions including circles, lines, angles, triangles, and transformations.

## Points and Vectors

```asy
pair A = (0, 0);
pair B = (3, 0);
pair C = (1.5, 2.5);

// Distance
dist(A, B);

// Midpoint
pair M = (A+B)/2;

// Unit vector
pair u = unit(B-A);

// Rotate vector by 90 degrees
pair v = rotate(90)*(B-A);
```

## Lines

```asy
line l = line(A, B);              // line through two points
line l = line(A, 45);             // line through A with angle 45 degrees
line l = line(A, B-A);            // line through A in direction B-A

// Intersection
pair P = intersectionpoint(l1, l2);

// Parallel and perpendicular
line m = parallel(A, l);          // line through A parallel to l
line n = perpendicular(A, l);     // line through A perpendicular to l

// Distance from point to line
real d = distance(P, l);
```

## Circles

```asy
circle C = circle(A, 2);          // circle center A, radius 2
circle C = circle(A, B);          // circle with diameter AB
circle C = circle(A, B, C);       // circumcircle of triangle ABC

// Points on circle
pair P = relpoint(C, 0.25);       // point at relative position 0.25 around circle
pair P = angpoint(C, 45);         // point at 45 degrees

// Tangents
line[] t = tangents(P, C);        // tangents from point P to circle C
```

## Triangles

```asy
triangle T = triangle(A, B, C);

// Vertices
triangle.A, triangle.B, triangle.C

// Special points
pair O = T.O;                     // circumcenter
pair H = T.H;                     // orthocenter
pair G = T.G;                     // centroid
pair I = T.I;                     // incenter

// Special circles
circle CC = T.CC;                 // circumcircle
circle IC = T.IC;                 // incircle

// Angles
angle a = angle(B, A, C);         // angle BAC

// Draw angle mark
markangle("$\\alpha$", B, A, C);
```

## Angles and Marking

```asy
// Right angle
perpendicular(B, NE, A--C, blue);
perpendicularmark(B, NE);

// Angle arc
markangle("$\\theta$", B, A, C, radius=0.5cm);
markangle(B, A, C, radius=0.5cm, linewidth(1));

// Angle with arrow
markangleradiusfactor = 0.5;
markangle(B, A, C);
```

## Intersections

```asy
pair P = intersectionpoint(circle((0,0),1), circle((1,0),1));
pair[] P = intersectionpoints(circle((0,0),1), line((0,0),(1,1)));
```

## Conic Sections

```asy
// Ellipse
ellipse E = ellipse((0,0), 2, 1, 30);  // center, a, b, angle

// Parabola
parabola P = parabola((0,0), (0,1), (1,0));

// Hyperbola
hyperbola H = hyperbola((0,0), 2, 1);
```

## Transformations in Geometry

```asy
// Reflection
pair Pp = reflect(A, B)*P;        // reflect P across line AB

// Rotation around a point
pair Pp = rotate(60, A)*P;        // rotate P 60 degrees around A

// Homothety (scaling from a point)
pair Pp = scale(2, A)*P;          // scale by 2 from center A
```

## Grid and Axes

```asy
// Grid
add(grid(0, 5, 0, 5));

// Axes
xaxis("$x$", Arrow);
yaxis("$y$", Arrow);
```

## Common Geometric Patterns

### Triangle with Altitudes
```asy
import geometry;

// Triangle vertices with descriptive names
pair vertexA = (0,0);
pair vertexB = (4,0);
pair vertexC = (2,3);

// Draw the main triangle
triangle tri = triangle(vertexA, vertexB, vertexC);
draw(tri);

// Orthocenter and altitudes
pair orthocenterH = orthocenter(vertexA, vertexB, vertexC);
pair footOnAC = foot(vertexB, vertexA, vertexC);
pair footOnAB = foot(vertexC, vertexA, vertexB);

draw(vertexA--orthocenterH, dashed);
draw(vertexB--footOnAC, dashed);
draw(vertexC--footOnAB, dashed);

// Label points for clarity
label("$A$", vertexA, SW);
label("$B$", vertexB, SE);
label("$C$", vertexC, N);
label("$H$", orthocenterH, NE);
```

### Circle with Tangent
```asy
import geometry;

// Circle definition
pair centerO = (0,0);
real circleRadius = 1.0;
circle unitCircle = circle(centerO, circleRadius);

// External point from which tangents are drawn
pair externalPointP = (2, 0);

// Draw the circle and external point
draw(unitCircle);
dot("$P$", externalPointP, E);

// Calculate and draw one tangent line
line[] tangentLines = tangents(externalPointP, unitCircle);
draw(tangentLines[0]);

// Find the tangent point on the circle
line centerToP = line(centerO, externalPointP);
pair tangentPointT = intersectionpoint(centerToP, unitCircle);
dot("$T$", tangentPointT, NW);
```

### Regular Polygon
```asy
// Configuration: number of sides and circumradius
int numSides = 6;
real circumradius = 1.0;
pair center = (0,0);

// Generate vertices evenly distributed around a circle
pair[] polygonVertices;
for (int i = 0; i < numSides; ++i) {
    real angle = 360 * i / numSides;
    pair vertex = rotate(angle) * (circumradius, 0);
    polygonVertices.push(vertex);
}

// Draw the regular polygon
draw(polygon(polygonVertices), cyclic=true);
```

### Venn Diagram
```asy
// Venn diagram parameters
real circleRadius = 1.5;
real centerOffset = 1.0;   // distance from origin to each circle center

// Define two overlapping circles
pair leftCenter = (-centerOffset, 0);
pair rightCenter = (centerOffset, 0);
path leftCircle = circle(leftCenter, circleRadius);
path rightCircle = circle(rightCenter, circleRadius);

// Fill with semi-transparent colors for overlap visualization
fill(leftCircle, red + opacity(0.5));
fill(rightCircle, green + opacity(0.5));

// Draw outlines
draw(leftCircle);
draw(rightCircle);
```

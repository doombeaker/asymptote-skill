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
pair A = (0,0), B = (4,0), C = (2,3);
draw(A--B--C--cycle);
pair H = orthocenter(A, B, C);
draw(A--H, dashed);
draw(B--foot(B, A, C), dashed);
draw(C--foot(C, A, B), dashed);
```

### Circle with Tangent
```asy
import geometry;
pair O = (0,0);
circle C = circle(O, 1);
draw(C);
pair P = (2, 0);
dot("$P$", P, E);
line[] t = tangents(P, C);
draw(t[0]);
line OP = line(O, P);
pair T = intersectionpoint(OP, C);
dot("$T$", T, NW);
```

### Regular Polygon
```asy
int n = 6;
pair[] vertices;
for(int i=0; i < n; ++i) {
    vertices.push(rotate(360*i/n)*(1,0));
}
draw(polygon(vertices), cyclic=true);
```

### Venn Diagram
```asy
path c1 = circle((-1,0), 1.5);
path c2 = circle((1,0), 1.5);
fill(c1, red+opacity(0.5));
fill(c2, green+opacity(0.5));
draw(c1); draw(c2);
```

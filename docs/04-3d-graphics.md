# 3D Graphics with Asymptote

## Using the three Module

```asy
import three;
```

The `three.asy` module enables 3D vector graphics with projections, surfaces, lighting, and materials.

## Projections

```asy
// Perspective projection
currentprojection = perspective(6,3,2);
currentprojection = perspective(camera=(6,3,2), up=Y, target=O);

// Orthographic projection
currentprojection = orthographic(6,3,2);

// Oblique projection
currentprojection = oblique;

// Set viewport
currentprojection = perspective(6,3,2, showtarget=false);
```

## Basic 3D Objects

```asy
// Points and vectors
triple A = (0,0,0);
triple B = (1,0,0);

// 3D path
draw(O--X, red);     // X=(1,0,0), Y=(0,1,0), Z=(0,0,1)
draw(O--Y, green);
draw(O--Z, blue);

// 3D arrow
draw(O--(1,1,1), arrow=Arrow3);
```

## Surfaces

```asy
// Plane
surface s = surface(planar(patch((0,0,0)--(1,0,0)--(1,1,0)--(0,1,0)--cycle)));
draw(s, blue);

// Sphere
surface s = surface(sphere(O, 1));
draw(s, green, render(merge=true));

// Cylinder
surface s = surface(cylinder(O, 1, 2, Z));
draw(s, yellow);

// Revolution (surface of revolution)
path3 g = (1,0,0)..(2,0,1)..(1,0,2);
revolution r = revolution(g, Z);
draw(r.silhouette());
draw(surface(r), lightblue);
```

## Parametric Surfaces

```asy
triple f(pair z) {
    real u = z.x, v = z.y;
    return (cos(u)*sin(v), sin(u)*sin(v), cos(v));
}
surface s = surface(f, (0,0), (2pi,pi), nu=20, nv=20);
draw(s, paleyellow);
```

## Mesh and Wireframe

```asy
// Mesh lines
for(int i=0; i <= 10; ++i) {
    draw((0,0,i/10)--(1,0,i/10));
    draw((i/10,0,0)--(i/10,0,1));
}

// Skeleton
skeleton s;
r.transverse(s, 0.5);
draw(s.transverse.front, red);
draw(s.transverse.back, dashed);
```

## Lighting and Materials

```asy
// Light sources
currentlight = viewport(true, (1,1,1), O);
currentlight = White;
currentlight = nolight;

// Material properties
pen p = material(diffusepen=gray(0.5), ambientpen=gray(0.2),
                 emissivepen=gray(0), specularpen=gray(0.7));
draw(s, p);

// Shiny material
pen p = material(white, black, red, black);
draw(s, p);
```

## Rendering Options

```asy
// PRC (3D in PDF)
settings.render = 4;  // quality level
settings.prc = true;  // enable PRC

// WebGL (3D in HTML)
settings.outformat = "html";
settings.render = 0;

// Image rendering
settings.render = 4;
settings.outformat = "png";
```

## 3D Labels

```asy
label("$A$", A, NE);
label(Label("$x$", embed=Embed), X, E);
```

## Intersections in 3D

```asy
path3 p = (0,0,0)--(1,1,1);
path3 q = (0,1,0)--(1,0,1);
triple P = intersectionpoint(p, q);
```

## Tube Drawing

```asy
import tube;

path3 p = (0,0,0)..(1,0,1)..(2,0,0);
draw(tube(p, scale(0.1)*unitcircle), yellow);
```

## Common 3D Examples

### Cube
```asy
import three;
draw(unitcube, blue);
```

### Coordinate System
```asy
import three;
draw(O--2X, red, arrow=Arrow3);
draw(O--2Y, green, arrow=Arrow3);
draw(O--2Z, blue, arrow=Arrow3);
label("$x$", 2X, E);
label("$y$", 2Y, N);
label("$z$", 2Z, N);
```

### Parametric Curve in 3D
```asy
import three;
triple f(real t) {
    return (cos(t), sin(t), t/2pi);
}
draw(graph(f, 0, 4pi), red);
```

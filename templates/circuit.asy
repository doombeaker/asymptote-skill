// Template: Circuit Diagram
// Use this as a starting point for electrical circuits

size(10cm, 0);

// Helper functions for circuit elements
path resistor(pair a, pair b, real w=0.3, int n=5) {
    pair d = unit(b-a), p = rotate(90)*d;
    real s = length(b-a)/n;
    guide g = a;
    for(int i=0; i<n; ++i)
        g = g--(a+i*s*d+w*p)--(a+(i+0.5)*s*d-w*p);
    return g--b;
}

void capacitor(pair a, pair b) {
    pair m=(a+b)/2, d=unit(b-a), p=rotate(90)*d;
    draw(a--m-0.1*d); draw(m+0.1*d--b);
    draw(m-0.1*d+0.25*p--m-0.1*d-0.25*p, linewidth(1));
    draw(m+0.1*d+0.25*p--m+0.1*d-0.25*p, linewidth(1));
}

void battery(pair a, pair b) {
    pair m=(a+b)/2, d=unit(b-a), p=rotate(90)*d;
    draw(a--m-0.1*d); draw(m+0.1*d--b);
    draw(m-0.1*d+0.2*p--m-0.1*d-0.2*p, linewidth(2));
    draw(m+0.1*d+0.08*p--m+0.1*d-0.08*p, linewidth(1));
}

void ground(pair p) {
    draw(p--p+(0,-0.25));
    draw((p+(-0.15,-0.25))--(p+(0.15,-0.25)), linewidth(1));
    draw((p+(-0.08,-0.35))--(p+(0.08,-0.35)), linewidth(0.5));
}

// Circuit nodes
pair A = (0,2), B = (3,2), C = (3,0), D = (0,0);

// Draw circuit
draw(A--resistor(A,B)--B);
label("$R_1$", (A+B)/2, N);

capacitor(B, C);
label("$C_1$", (B+C)/2, E);

draw(C--D);
battery(D, A);
label("$V_{in}$", (D+A)/2, W);

ground(C);

// Node labels
label("$V_{out}$", B, NE);
dot("$+$", A, NW);
dot("$-$", D, SW);

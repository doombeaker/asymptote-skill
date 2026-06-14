// Template: Animation
// Use this as a starting point for frame-based animations

import animate;

animation a;
int nframes = 30;

for(int i=0; i < nframes; ++i) {
    save();
    
    // Animation parameter (0 to 1)
    real t = i/(nframes-1);
    
    // Draw animated content
    pair center = (2*cos(2pi*t), 2*sin(2pi*t));
    filldraw(circle(center, 0.3), red, black);
    draw(circle((0,0), 2), dashed+gray);
    
    a.add();
    restore();
}

// Export animation
a.movie(loops=0, delay=100);  // delay in ms, 0=loop forever

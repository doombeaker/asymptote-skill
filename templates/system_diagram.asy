// ==========================================
// TEMPLATE: System Architecture Diagram
// Layers, clusters, dispatch lines, and annotations
// Uses picture + point() pattern for modular composition
// ==========================================

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw         = 3.8;
real bh         = 1.2;
real gap        = 0.2;
real dx         = 4.5;
real yTop       = 3.5;
real yBot       = -3.5;

pen userColor    = rgb(0.90, 0.95, 1.00);  pen userBorder    = black + 1.2pt;
pen gatewayColor = rgb(1.00, 0.95, 0.85);  pen gatewayBorder = black + 1.2pt;
pen routerColor  = rgb(0.85, 1.00, 0.90);  pen routerBorder  = black + 1.2pt;
pen workerColor  = rgb(1.00, 0.95, 0.75);  pen workerBorder  = black + 1.2pt;
pen resultColor  = rgb(0.85, 1.00, 0.95);  pen resultBorder  = black + 1.2pt;
pen clusterFill  = rgb(0.96, 0.96, 0.99);
pen clusterPen   = rgb(0.3, 0.3, 0.6) + linewidth(1.8);
pen arrowPen     = rgb(0.2, 0.2, 0.2) + linewidth(0.9);
pen dispatchPen  = gray + linewidth(0.7) + dashed;

// ------------------------------------------
// NODE COMPONENT — returns picture centered at origin
// ------------------------------------------
picture label_box_pic(real bw, real bh, string[] lines,
                      pen fillPen, pen borderPen) {
    picture pic;
    fill(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), fillPen);
    draw(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), borderPen);
    real lineDy = 0.36;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(7pt));
    return pic;
}

picture label_box_pic(real bw, real bh, string text,
                      pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, new string[]{text}, fillPen, borderPen);
}

// ------------------------------------------
// TODO: Replace components with your system architecture
// ------------------------------------------
real xStart = -11;

// --- Create and position nodes ---
picture pUser    = shift(xStart,            yTop)        * label_box_pic(bw, bh, new string[]{"User", "Client Application"}, userColor, userBorder);
picture pGateway = shift(xStart + dx,       yTop)        * label_box_pic(bw, bh, new string[]{"Gateway", "Auth, Routing"}, gatewayColor, gatewayBorder);
picture pRouter  = shift(xStart + 3.25*dx,  yTop - 1.5) * label_box_pic(bw, bh, new string[]{"Router", "Load Balancer"}, routerColor, routerBorder);
picture pWorker1 = shift(xStart + 2*dx,   yBot)        * label_box_pic(bw, bh, new string[]{"Worker 1", "CPU Tasks"}, workerColor, workerBorder);
picture pWorkerDot = shift(xStart + 3.25*dx,   yBot)        * label_box_pic(bw, bh, new string[]{"Worker ...", "CPU Tasks"}, workerColor, workerBorder);
picture pWorker2 = shift(xStart + 4.5*dx,   yBot)        * label_box_pic(bw, bh, new string[]{"Worker N", "GPU Tasks"}, workerColor, workerBorder);
picture pResult  = shift(xStart + 6.0*dx,   (yTop+yBot)/2) * label_box_pic(bw, bh, new string[]{"Result", "Output"}, resultColor, resultBorder);

// ------------------------------------------
// ASSEMBLE DIAGRAM
// ------------------------------------------
picture diagram;
size(diagram, 20cm);

// --- Cluster background (drawn first) ---
pair cbl = (xStart + 2.0*dx - bw/2 - 0.3, yTop - 0.5);
pair ctr = (xStart + 4.5*dx + bw/2 + 0.3, yBot - bh/2 - 1);
fill(diagram, box(cbl, ctr), clusterFill);
draw(diagram, box(cbl, ctr), clusterPen);
label(diagram, "Core Cluster", ((cbl.x + ctr.x)/2, ctr.y + 0.5),
      fontsize(11pt) + rgb(0.3, 0.3, 0.6));

// --- Arrows (drawn before nodes → behind nodes) ---

// User → Gateway
pair uEast = point(pUser, E) + (gap, 0);
pair gWest = point(pGateway, W) + (-gap, 0);
draw(diagram, uEast -- gWest, arrow = Arrow(TeXHead), arrowPen);

// Gateway → Router (curved)
pair gEast = point(pGateway, E) + (gap, 0);
pair rWest = point(pRouter,  W) + (-gap, 0);
draw(diagram, gEast{E}..{E}rWest, arrow = Arrow(TeXHead), arrowPen);

// Router → Workers (dashed dispatch)
pair routerSouth = point(pRouter, S) + (0, -gap);
for (picture worker : new picture[] {pWorker1, pWorkerDot, pWorker2}) {
    pair wNorth = point(worker, N) + (0, gap);
    pair bend = (routerSouth.x, routerSouth.y - 0.8);
    draw(diagram, routerSouth -- bend -- (wNorth.x, bend.y) -- wNorth,
         dispatchPen);
}

// Workers → Result (curved, dashed)
pair w2East  = point(pWorker2, E) + (gap, 0);
pair resWest = point(pResult,  W) + (-gap, 0);
draw(diagram, w2East{E}..{E}resWest,
     arrow = Arrow(TeXHead), arrowPen + dashed);

// --- Add nodes on top of arrows ---
add(diagram, pUser);
add(diagram, pGateway);
add(diagram, pRouter);
add(diagram, pWorker1);
add(diagram, pWorkerDot);
add(diagram, pWorker2);
add(diagram, pResult);

// --- Step numbering ---
real ySteps = point(pResult, S).y - 6;
label(diagram, "1. Request",  (point(pUser,    S).x, ySteps), fontsize(8pt));
label(diagram, "2. Auth",     (point(pGateway, S).x, ySteps), fontsize(8pt));
label(diagram, "3. Dispatch", (point(pRouter,  S).x, ySteps), fontsize(8pt));
label(diagram, "4. Process",  (point(pWorker2, S).x, ySteps), fontsize(8pt));
label(diagram, "5. Return",   (point(pResult,  S).x, ySteps), fontsize(8pt));

shipout(diagram);

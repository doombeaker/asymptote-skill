// ==========================================
// TEMPLATE: System Architecture Diagram
// Layers, clusters, dispatch lines, and annotations
// ==========================================
unitsize(1.0cm);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw       = 3.8;
real bh       = 1.2;
real gap      = 0.2;
real dx       = 4.5;
real yTop     = 3.5;
real yBot     = -3.5;

pen userColor    = rgb(0.90, 0.95, 1.00);
pen gatewayColor = rgb(1.00, 0.95, 0.85);
pen workerColor  = rgb(1.00, 0.95, 0.75);
pen resultColor  = rgb(0.85, 1.00, 0.95);
pen clusterFill  = rgb(0.96, 0.96, 0.99);
pen clusterPen   = rgb(0.3, 0.3, 0.6) + linewidth(1.8);
pen arrowPen     = rgb(0.2, 0.2, 0.2) + linewidth(0.9);
pen dispatchPen  = gray + linewidth(0.7) + dashed;

// ------------------------------------------
// HELPERS
// ------------------------------------------
void boxLabel(pair c, string[] lines, pen fillpen) {
    pair bl = c + (-bw/2, -bh/2);
    pair tr = c + ( bw/2,  bh/2);
    fill(box(bl, tr), fillpen);
    draw(box(bl, tr), black + 1.2pt);
    real lineDy = 0.36;
    real y0 = c.y + (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(lines[i], (c.x, y0 - i * lineDy), fontsize(9pt));
}

void boxLabel(pair c, string text, pen fillpen) {
    boxLabel(c, new string[]{text}, fillpen);
}

void arrH(pair leftBox, pair rightBox) {
    draw((leftBox.x + bw/2 + gap, leftBox.y) -- (rightBox.x - bw/2 - gap, rightBox.y),
         arrow = Arrow(TeXHead), linewidth(0.9));
}

// ------------------------------------------
// TODO: Replace components with your system architecture
// ------------------------------------------
real xStart = -11;

// --- Layer 1: User ---
pair pUser = (xStart, yTop);
boxLabel(pUser, new string[]{"User", "Client Application"}, userColor);

// --- Layer 2: Gateway ---
pair pGateway = (xStart + dx, yTop);
boxLabel(pGateway, new string[]{"Gateway", "Auth, Routing"}, gatewayColor);
arrH(pUser, pGateway);

// --- Layer 3: Core Cluster (boxed group) ---
pair cbl = (xStart + 2.0*dx - bw/2 - 0.3, yTop - 0.5);
pair ctr = (xStart + 4.5*dx + bw/2 + 0.3, yBot - bh/2 - 1);
fill(box(cbl, ctr), clusterFill);
draw(box(cbl, ctr), clusterPen);
label("Core Cluster", ((cbl.x + ctr.x)/2, ctr.y + 0.5),
      fontsize(11pt) + rgb(0.3, 0.3, 0.6));

// Router inside cluster
pair pRouter = (xStart + 3.25*dx, yTop - 1.5);
boxLabel(pRouter, new string[]{"Router", "Load Balancer"}, gatewayColor);

// Workers inside cluster
pair pWorker1 = (xStart + 2.5*dx, yBot);
pair pWorker2 = (xStart + 4.0*dx, yBot);
boxLabel(pWorker1, new string[]{"Worker 1", "CPU Tasks"}, workerColor);
boxLabel(pWorker2, new string[]{"Worker 2", "GPU Tasks"}, workerColor);

// Dashed dispatch lines from router to workers
pair routerBot = (pRouter.x, pRouter.y - bh/2 - gap);
for (pair w : new pair[] {pWorker1, pWorker2}) {
    pair wTop = (w.x, w.y + bh/2 + gap);
    draw(routerBot -- (routerBot.x, routerBot.y - 0.8)
              -- (wTop.x, routerBot.y - 0.8) -- wTop, dispatchPen);
}

// Gateway → Router (curved)
pair gOut = (pGateway.x + bw/2 + gap, pGateway.y);
pair rIn  = (pRouter.x - bw/2 - gap, pRouter.y);
draw(gOut{E}..{E}rIn, arrow = Arrow(TeXHead), linewidth(0.9));

// --- Layer 4: Result ---
pair pResult = (xStart + 6.0*dx, (yTop + yBot)/2);
boxLabel(pResult, new string[]{"Result", "Output"}, resultColor);

// Workers → Result (curved)
pair wRight = (pWorker2.x + bw/2 + gap, pWorker2.y);
pair resLeft = (pResult.x - bw/2 - gap, pResult.y);
draw(wRight{E}..{E}resLeft, arrow = Arrow(TeXHead), linewidth(0.9) + dashed);

// ------------------------------------------
// ANNOTATIONS (optional)
// ------------------------------------------
real ySteps = yBot - 2.5;
label("1. Request",  (pUser.x,    ySteps), fontsize(8pt));
label("2. Auth",     (pGateway.x, ySteps), fontsize(8pt));
label("3. Dispatch", (pRouter.x,  ySteps), fontsize(8pt));
label("4. Process",  (pWorker1.x, ySteps), fontsize(8pt));
label("5. Return",   (pResult.x,  ySteps), fontsize(8pt));

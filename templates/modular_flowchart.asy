// ==========================================
// TEMPLATE: Modular Flowchart (> 5 nodes or parallel branches)
// Uses picture composition — nodes self-contained, arrows auto-follow
// ==========================================
unitsize(1.0cm);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw       = 3.0;
real bh       = 0.9;
real gap      = 0.25;
real nodeDy   = 1.6;
real branchDx = 2.5;

pen doneFill   = rgb(0.90, 1.00, 0.95);
pen doneBorder = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen procFill   = rgb(1.00, 0.97, 0.90);
pen procBorder = rgb(0.50, 0.40, 0.20) + linewidth(1.2);
pen arrowPen   = rgb(0.30, 0.20, 0.10) + linewidth(0.9);

// ------------------------------------------
// NODE BUILDER — returns a picture centered at (0,0)
// ------------------------------------------
picture makeNode(string[] lines, pen fillpen, pen borderpen) {
    picture pic;
    pair bl = (-bw/2, -bh/2);
    pair tr = ( bw/2,  bh/2);
    fill(pic, box(bl, tr), fillpen);
    draw(pic, box(bl, tr), borderpen);
    real lineDy = 0.32;
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

picture makeNode(string text, pen fillpen, pen borderpen) {
    return makeNode(new string[]{text}, fillpen, borderpen);
}

// ------------------------------------------
// ARROW HELPERS — using picture anchor points
// ------------------------------------------
void arrowDown(picture dest, picture topNode, picture botNode) {
    pair a = point(topNode, S) + (0, -gap);
    pair b = point(botNode, N) + (0,  gap);
    draw(dest, a -- b, arrow = Arrow(TeXHead), arrowPen);
}

// Elegant curved branch: parent bottom → two children inner sides
// Left arrow enters leftChild from its right (E), right arrow enters rightChild from its left (W)
void arrowBranch(picture dest, picture parent,
                 picture leftChild, picture rightChild) {
    pair p = point(parent, S) + (0, -gap);
    pair l = point(leftChild, E) + (gap, 0);   // inner side of left child
    pair r = point(rightChild, W) + (-gap, 0); // inner side of right child
    // Control points: exit downward, approach from inward
    pair ctrlL1 = (p.x,     p.y - 0.4);
    pair ctrlL2 = (l.x,     l.y);
    pair ctrlR1 = (p.x,     p.y - 0.4);
    pair ctrlR2 = (r.x,     r.y);
    draw(dest, p..controls ctrlL1 and ctrlL2..l,  arrow = Arrow(TeXHead), arrowPen);
    draw(dest, p..controls ctrlR1 and ctrlR2..r, arrow = Arrow(TeXHead), arrowPen);
}

// Elegant curved join: side node bottom → main node side
// Smooth S-curve instead of orthogonal staircase
void arrowJoinLeft(picture dest, picture sideNode, picture mainNode) {
    pair a = point(sideNode, S) + (0, -gap);
    pair b = point(mainNode,  W) + (-gap, 0);
    pair ctrlA = (a.x, (a.y + b.y)/2);
    pair ctrlB = ((a.x + b.x)/2, b.y);
    draw(dest, a .. ctrlA .. ctrlB .. b, arrow = Arrow(TeXHead), arrowPen);
}

void arrowJoinRight(picture dest, picture sideNode, picture mainNode) {
    pair a = point(sideNode, S) + (0, -gap);
    pair b = point(mainNode,  E) + (gap, 0);
    pair ctrlA = (a.x, (a.y + b.y)/2);
    pair ctrlB = ((a.x + b.x)/2, b.y);
    draw(dest, a .. ctrlA .. ctrlB .. b, arrow = Arrow(TeXHead), arrowPen);
}

// ------------------------------------------
// TODO: Build your diagram below
// ------------------------------------------
picture diagram;

real xMain = 0;
real y0    = 0;

// --- Main column ---
picture pStart  = shift(xMain, y0)          * makeNode("Start", doneFill, doneBorder);
picture pPrep   = shift(xMain, y0 - nodeDy) * makeNode(new string[]{"Prep", "wash and measure"}, procFill, procBorder);
picture pMerge  = shift(xMain, y0 - 3*nodeDy) * makeNode("Merge", procFill, procBorder);
picture pDone   = shift(xMain, y0 - 4*nodeDy) * makeNode("End", doneFill, doneBorder);

// --- Parallel branches ---
picture pLeft  = shift(xMain - branchDx, y0 - 2*nodeDy) * makeNode("Left Task", procFill, procBorder);
picture pRight = shift(xMain + branchDx, y0 - 2*nodeDy) * makeNode("Right Task", procFill, procBorder);

// Add to diagram
add(diagram, pStart);
add(diagram, pPrep);
add(diagram, pLeft);
add(diagram, pRight);
add(diagram, pMerge);
add(diagram, pDone);

// Draw arrows
arrowDown(diagram, pStart, pPrep);
arrowBranch(diagram, pPrep, pLeft, pRight);
arrowJoinLeft(diagram, pLeft, pMerge);
arrowJoinRight(diagram, pRight, pMerge);
arrowDown(diagram, pMerge, pDone);

// Center and ship
diagram = shift(-min(diagram, true)) * diagram;
add(diagram);

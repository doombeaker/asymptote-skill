// ==========================================
// TEMPLATE: Minimal Flowchart (<= 5 nodes)
// Uses pair coordinates — quick to write, no boilerplate
// ==========================================
unitsize(1.0cm);

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw       = 3.0;   // Box width
real bh       = 0.9;   // Box height
real gap      = 0.2;   // Gap between box and arrow
real dy       = 1.5;   // Vertical step between nodes

// Color palette
pen doneFill   = rgb(0.90, 1.00, 0.95);
pen doneBorder = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen procFill   = rgb(1.00, 0.92, 0.85);
pen procBorder = rgb(0.60, 0.35, 0.15) + linewidth(1.2);
pen arrowPen   = rgb(0.30, 0.20, 0.10) + linewidth(0.9);

// ------------------------------------------
// HELPERS
// ------------------------------------------
void boxLabel(pair c, string[] lines, pen fillpen, pen borderpen) {
    pair bl = c + (-bw/2, -bh/2);
    pair tr = c + ( bw/2,  bh/2);
    fill(box(bl, tr), fillpen);
    draw(box(bl, tr), borderpen);
    real lineDy = 0.32;
    real y0 = c.y + (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(lines[i], (c.x, y0 - i * lineDy), fontsize(9pt));
}

void boxLabel(pair c, string text, pen fillpen, pen borderpen) {
    boxLabel(c, new string[]{text}, fillpen, borderpen);
}

// Straight vertical arrow
void arrV(pair topBox, pair botBox) {
    pair start = (topBox.x, topBox.y - bh/2 - gap);
    pair end   = (botBox.x, botBox.y + bh/2 + gap);
    draw(start -- end, arrow = Arrow(TeXHead), arrowPen);
}

// Straight horizontal arrow
void arrH(pair leftBox, pair rightBox) {
    pair start = (leftBox.x + bw/2 + gap, leftBox.y);
    pair end   = (rightBox.x - bw/2 - gap, rightBox.y);
    draw(start -- end, arrow = Arrow(TeXHead), arrowPen);
}

// ------------------------------------------
// TODO: Replace nodes below with your own workflow
// ------------------------------------------
pair pStart = (0, 0);
pair pStep1 = (0, -dy);
pair pStep2 = (0, -2*dy);
pair pEnd   = (0, -3*dy);

boxLabel(pStart, "Start", doneFill, doneBorder);
boxLabel(pStep1, new string[]{"Process", "description"}, procFill, procBorder);
boxLabel(pStep2, new string[]{"Another", "step"}, procFill, procBorder);
boxLabel(pEnd,   "End", doneFill, doneBorder);

arrV(pStart, pStep1);
arrV(pStep1, pStep2);
arrV(pStep2, pEnd);

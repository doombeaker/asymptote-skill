// ==========================================
// TEMPLATE: Minimal Vertical Flowchart
// Demonstrates: picture components, point() anchors, straight arrows
// Use this as the starting point for simple sequential workflows
// ==========================================

// ------------------------------------------
// CONFIGURATION
// ------------------------------------------
real bw     = 3.0;    // Box width
real bh     = 0.9;    // Box height
real gap    = 0.25;   // Gap between box edge and arrow tip
real lineDy = 0.32;   // Line spacing inside multi-line box
real nodeDy = 2.0;    // Vertical step between rows

real xCenter = 0;     // Center column x-coordinate
real yTop    = 0;      // Top of diagram

// Colors — one pen pair per role
pen startFill   = rgb(0.90, 0.95, 1.00);  pen startBorder   = rgb(0.25, 0.40, 0.60) + linewidth(1.2);
pen processFill = rgb(1.00, 0.97, 0.90);  pen processBorder = rgb(0.50, 0.40, 0.20) + linewidth(1.2);
pen doneFill    = rgb(0.90, 1.00, 0.95);  pen doneBorder    = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen arrowPen    = rgb(0.25, 0.25, 0.25) + linewidth(0.9);

// ------------------------------------------
// NODE COMPONENT — returns picture centered at origin
// ------------------------------------------
picture label_box_pic(real bw, real bh, real lineDy,
                      string[] lines, pen fillPen, pen borderPen) {
    picture pic;
    fill(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), fillPen);
    draw(pic, box((-bw/2, -bh/2), (bw/2, bh/2)), borderPen);
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), fontsize(9pt));
    return pic;
}

picture label_box_pic(real bw, real bh, real lineDy,
                      string text, pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, lineDy, new string[]{text}, fillPen, borderPen);
}

// ------------------------------------------
// ARROW HELPER — vertical arrow using point() anchors
// ------------------------------------------
void arrowDown(picture dest, picture top, picture bot) {
    pair a = point(top, S) + (0, -gap);
    pair b = point(bot, N) + (0,  gap);
    draw(dest, a -- b, arrow = Arrow(TeXHead), arrowPen);
}

// ------------------------------------------
// BUILD DIAGRAM
// ------------------------------------------

// --- Create and position nodes (shift baked into each picture) ---
picture pStart = shift(xCenter, yTop)
    * label_box_pic(bw, bh, lineDy, "Start", startFill, startBorder);

picture pStep1 = shift(xCenter, yTop - nodeDy)
    * label_box_pic(bw, bh, lineDy, new string[]{"Step 1", "Describe"}, processFill, processBorder);

picture pStep2 = shift(xCenter, yTop - 2*nodeDy)
    * label_box_pic(bw, bh, lineDy, new string[]{"Step 2", "Describe"}, processFill, processBorder);

picture pStep3 = shift(xCenter, yTop - 3*nodeDy)
    * label_box_pic(bw, bh, lineDy, new string[]{"Step 3", "Describe"}, processFill, processBorder);

picture pDone = shift(xCenter, yTop - 4*nodeDy)
    * label_box_pic(bw, bh, lineDy, "Done", doneFill, doneBorder);

// --- Assemble ---
picture diagram;
size(diagram, 10cm);

// Arrows (drawn first → behind nodes)
arrowDown(diagram, pStart, pStep1);
arrowDown(diagram, pStep1, pStep2);
arrowDown(diagram, pStep2, pStep3);
arrowDown(diagram, pStep3, pDone);

// Add nodes on top of arrows
add(diagram, pStart);
add(diagram, pStep1);
add(diagram, pStep2);
add(diagram, pStep3);
add(diagram, pDone);

// ------------------------------------------
// CENTER AND SHIP
// ------------------------------------------
shipout(shift(-min(diagram, true)) * diagram);

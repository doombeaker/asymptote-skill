// ==========================================
// TEMPLATE: Minimal Vertical Flowchart
// Demonstrates: picture components, point() anchors, straight arrows
// Use this as the starting point for simple sequential workflows
// ==========================================

import skillutils;

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

pen textPen = fontsize(9pt);

// Colors — one pen pair per role
pen startFill   = rgb(0.90, 0.95, 1.00);  pen startBorder   = rgb(0.25, 0.40, 0.60) + linewidth(1.2);
pen processFill = rgb(1.00, 0.97, 0.90);  pen processBorder = rgb(0.50, 0.40, 0.20) + linewidth(1.2);
pen doneFill    = rgb(0.90, 1.00, 0.95);  pen doneBorder    = rgb(0.20, 0.50, 0.40) + linewidth(1.2);
pen arrowPen    = rgb(0.25, 0.25, 0.25) + linewidth(0.9);

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

// --- Create and position nodes ---
picture pStart = label_box_pic((xCenter, yTop), bw, bh, lineDy, "Start", textPen, startFill, startBorder);

picture pStep1 = label_box_pic((xCenter, yTop - nodeDy), bw, bh, lineDy, new string[]{"Step 1", "Describe"}, textPen, processFill, processBorder);

picture pStep2 = label_box_pic((xCenter, yTop - 2*nodeDy), bw, bh, lineDy, new string[]{"Step 2", "Describe"}, textPen, processFill, processBorder);

picture pStep3 = label_box_pic((xCenter, yTop - 3*nodeDy), bw, bh, lineDy, new string[]{"Step 3", "Describe"}, textPen, processFill, processBorder);

picture pDone = label_box_pic((xCenter, yTop - 4*nodeDy), bw, bh, lineDy, "Done", textPen, doneFill, doneBorder);

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

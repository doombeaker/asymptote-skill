// Zheng He's Voyages - HORIZONTAL Timeline (Landscape)
// 1405-1433, Seven Voyages Across the Western Ocean
// Uses picture + point() pattern for modular composition
//
// SCALING PRINCIPLE:
//   Labels use fixed font sizes (7pt). For text to fit inside boxes,
//   output width must roughly match coordinate extent so 1 unit ≈ 1 cm.
//   With ~50 user-units width, outputWidth should be ~50 cm.

// ==========================================
// LAYOUT PARAMETERS — adjust these to tune the diagram
// ==========================================
real bw         = 2.6;      // Box width (user units ≈ cm at output)
real bh         = 0.95;     // Box height
real lineDy     = 0.33;     // Line spacing inside box
real gap        = 0.18;     // Arrow gap from box edge
real dx         = 3.0;      // Horizontal step between adjacent nodes
                           //   inter-box gap = dx - bw = 0.4

real rowDy      = 2.2;      // Vertical distance: main row ↔ upper/lower rows
real xStart     = -22.5;    // X coordinate of leftmost node (≈ -7.5*dx for centering)

// Annotation spacing (offsets from nearest structure)
real annotPad   = 0.3;      // Gap above main-row box top edge to top annotation
real annotLine  = 0.35;     // Vertical step between two annotation lines
real dividerPad = 0.8;      // Gap above upper-row box tops to divider line
real dividerLbl = 0.4;      // Gap above divider line to reign label
real botAnnot   = 1.5;      // Gap below lower-row box bottoms to bottom annotations
real barPad     = 1.2;      // Gap below lower-row box bottoms to color bar
real barH       = 0.25;     // Color bar height
real quotePad   = 2.8;      // Gap below lower-row box bottoms to quote
real titlePad   = 2.2;      // Gap above divider line to title

real outputWidth = 50;      // Output width in cm (≈ coordinate extent)

// ==========================================
// DERIVED POSITIONS — computed from parameters, do not edit
// ==========================================
real yMain  = 0;
real yUpper = yMain + rowDy;
real yLower = yMain - rowDy;

real yDivider   = yUpper + bh/2 + dividerPad;
real yAnnotTop  = yMain + bh/2 + annotPad;
real yAnnotSub  = yAnnotTop - annotLine;
real yBotAnnot1 = yLower - bh/2 - botAnnot;
real yBotAnnot2 = yBotAnnot1 - annotLine;
real yBar       = yLower - bh/2 - barPad;
real yQuote     = yLower - bh/2 - quotePad;
real yTitle     = yDivider + titlePad;

// ==========================================
// COLORS
// ==========================================
pen earlyColor   = rgb(0.90, 0.95, 1.00);  pen earlyBorder   = black + 1.0pt;
pen voyageColor  = rgb(1.00, 0.95, 0.85);  pen voyageBorder  = black + 1.0pt;
pen battleColor  = rgb(1.00, 0.85, 0.85);  pen battleBorder  = black + 1.0pt;
pen tributeColor = rgb(0.85, 1.00, 0.90);  pen tributeBorder = black + 1.0pt;
pen hongxiColor  = rgb(0.95, 0.90, 0.95);  pen hongxiBorder  = black + 1.0pt;
pen xuandeColor  = rgb(1.00, 0.90, 0.80);  pen xuandeBorder  = black + 1.0pt;
pen endColor     = gray(0.90);              pen endBorder     = black + 1.0pt;
pen arrowPen     = rgb(0.3, 0.2, 0.1) + linewidth(0.8);
pen lightArrow   = rgb(0.3, 0.2, 0.1) + linewidth(0.6);

// ==========================================
// NODE COMPONENT
// ==========================================
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

// Convenience wrapper using global bw/bh/lineDy
picture box2(string[] lines, pen fillPen, pen borderPen) {
    return label_box_pic(bw, bh, lineDy, lines, fillPen, borderPen);
}
picture box2(string text, pen fillPen, pen borderPen) {
    return box2(new string[]{text}, fillPen, borderPen);
}

// ==========================================
// ARROW HELPERS
// ==========================================
void chainH(picture dest, picture[] nodes, real gap, pen p) {
    for (int i = 0; i < nodes.length - 1; ++i)
        draw(dest, point(nodes[i], E) + (gap, 0)
                    -- point(nodes[i+1], W) + (-gap, 0),
             arrow = Arrow(TeXHead), p);
}

void arrowV(picture dest, picture src, pair srcDir,
            picture tgt, pair tgtDir, real gap, pen p) {
    draw(dest, point(src, srcDir) + gap * srcDir
                -- point(tgt,   tgtDir)   + gap * tgtDir,
         arrow = Arrow(TeXHead), p);
}

// ==========================================
// CREATE AND POSITION NODES
// ==========================================

// --- Main timeline (Yongle Reign) ---
picture pOrigin    = shift(xStart,          yMain) * box2(new string[]{"Origin", "Yunnan"}, earlyColor, earlyBorder);
picture pService   = shift(xStart + dx,     yMain) * box2(new string[]{"Serve", "Prince Yan"}, earlyColor, earlyBorder);
picture pV1        = shift(xStart + 2*dx,   yMain) * box2(new string[]{"1st Voyage", "1405-1407"}, voyageColor, voyageBorder);
picture pV1ret     = shift(xStart + 3*dx,   yMain) * box2(new string[]{"Return", "Envoys"}, tributeColor, tributeBorder);
picture pV2        = shift(xStart + 4*dx,   yMain) * box2(new string[]{"2nd Voyage", "1409-1411"}, voyageColor, voyageBorder);
picture pV2ret     = shift(xStart + 5*dx,   yMain) * box2(new string[]{"Return", "Captives"}, battleColor, battleBorder);
picture pV3        = shift(xStart + 6*dx,   yMain) * box2(new string[]{"3rd Voyage", "1413-1415"}, voyageColor, voyageBorder);
picture pV3ret     = shift(xStart + 7*dx,   yMain) * box2(new string[]{"Return", "1415"}, tributeColor, tributeBorder);
picture pV4        = shift(xStart + 8*dx,   yMain) * box2(new string[]{"4th Voyage", "1417-1419"}, tributeColor, tributeBorder);
picture pV5        = shift(xStart + 9*dx,   yMain) * box2(new string[]{"5th Voyage", "1421-1422"}, voyageColor, voyageBorder);
picture pV6        = shift(xStart + 10*dx,  yMain) * box2(new string[]{"6th Voyage", "1424"}, voyageColor, voyageBorder);

// --- Battle branches (below main) ---
picture pBattle1 = shift(xStart + 3*dx,  yLower) * box2(new string[]{"Old Port", "Chen Zuyi"}, battleColor, battleBorder);
picture pBattle2 = shift(xStart + 4*dx,  yLower) * box2(new string[]{"Ceylon", "Capture king"}, battleColor, battleBorder);
picture pBattle3 = shift(xStart + 6*dx,  yLower) * box2(new string[]{"Samudera", "Victory"}, battleColor, battleBorder);

// --- Transition: Yongle → Hongxi ---
picture pTransition = shift(xStart + 11.5*dx, yMain) * box2(new string[]{"1425", "Guard Nanjing"}, hongxiColor, hongxiBorder);

// --- Xuande: 7th Voyage ---
picture pV7        = shift(xStart + 13*dx, yMain)  * box2(new string[]{"7th Voyage", "1433"}, xuandeColor, xuandeBorder);
picture pV7detail  = shift(xStart + 13*dx, yUpper) * box2(new string[]{"17 States", "Hormuz"}, xuandeColor, xuandeBorder);

// --- Legacy ---
picture pLegacy        = shift(xStart + 15*dx, yMain)  * box2(new string[]{"Legacy", "7 Voyages"}, endColor, endBorder);
picture pLegacyDetail  = shift(xStart + 15*dx, yUpper) * box2(new string[]{"30+ Countries", "Treasure Fleet"}, endColor, endBorder);

// ==========================================
// ASSEMBLE DIAGRAM
// ==========================================
picture diagram;
size(diagram, outputWidth*cm);

// --- Title ---
label(diagram, "Zheng He: Seven Voyages (1405-1433) — Landscape Timeline",
      (0, yTitle), fontsize(14pt));

// --- Phase dividers ---
label(diagram, "Yongle Reign (1405-1424)", (xStart + 5.5*dx, yDivider + dividerLbl), fontsize(10pt));
draw(diagram, (xStart - 2, yDivider) -- (xStart + 17*dx, yDivider),
     gray + linewidth(0.8) + dashed);
label(diagram, "Xuande Reign (1433)", (xStart + 13*dx, yDivider + dividerLbl), fontsize(10pt));

// --- Arrows (drawn before nodes → behind nodes) ---

// Main flow (all horizontal links in one call)
chainH(diagram, new picture[] {pOrigin, pService, pV1, pV1ret, pV2, pV2ret,
                               pV3, pV3ret, pV4, pV5, pV6, pTransition, pV7, pLegacy},
       gap, arrowPen);

// Branch arrows: main → battles (down)
arrowV(diagram, pV1ret, S, pBattle1, N, gap, lightArrow);
arrowV(diagram, pV2,    S, pBattle2, N, gap, lightArrow);
arrowV(diagram, pV3,    S, pBattle3, N, gap, lightArrow);

// Branch arrow: battle → main (up)
arrowV(diagram, pBattle2, N, pV2ret, S, gap, lightArrow);

// Detail arrows: main → upper detail (up)
arrowV(diagram, pV7,     N, pV7detail,      S, gap, lightArrow);
arrowV(diagram, pLegacy, N, pLegacyDetail,  S, gap, lightArrow);

// --- Add all nodes on top of arrows ---
add(diagram, pOrigin);
add(diagram, pService);
add(diagram, pV1);      add(diagram, pV1ret);
add(diagram, pV2);      add(diagram, pV2ret);
add(diagram, pV3);      add(diagram, pV3ret);
add(diagram, pV4);
add(diagram, pV5);
add(diagram, pV6);
add(diagram, pBattle1); add(diagram, pBattle2); add(diagram, pBattle3);
add(diagram, pTransition);
add(diagram, pV7);      add(diagram, pV7detail);
add(diagram, pLegacy);  add(diagram, pLegacyDetail);

// --- Top annotations (above main row) ---
label(diagram, "Yunnan",       (point(pOrigin, N).x, yAnnotTop), fontsize(7pt));
label(diagram, "Zhu Di",       (point(pService, N).x, yAnnotTop), fontsize(7pt));
label(diagram, "Fleet sails",  (point(pV1, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "Emperor",      (point(pV1ret, N).x,   yAnnotTop), fontsize(7pt));
label(diagram, "delighted",    (point(pV1ret, N).x,   yAnnotSub), fontsize(7pt));
label(diagram, "Indian",       (point(pV2, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "Ocean",        (point(pV2, N).x,      yAnnotSub), fontsize(7pt));
label(diagram, "1411",         (point(pV2ret, N).x,   yAnnotTop), fontsize(7pt));
label(diagram, "Sumatra",      (point(pV3, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "1415",         (point(pV3ret, N).x,   yAnnotTop), fontsize(7pt));
label(diagram, "Malacca",      (point(pV4, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "Calicut",      (point(pV4, N).x,      yAnnotSub), fontsize(7pt));
label(diagram, "Persian",      (point(pV5, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "Gulf",         (point(pV5, N).x,      yAnnotSub), fontsize(7pt));
label(diagram, "Bestow",       (point(pV6, N).x,      yAnnotTop), fontsize(7pt));
label(diagram, "seal",         (point(pV6, N).x,      yAnnotSub), fontsize(7pt));
label(diagram, "Nanjing",      (point(pTransition, N).x, yAnnotTop), fontsize(7pt));
label(diagram, "Guard",        (point(pTransition, N).x, yAnnotSub), fontsize(7pt));

// --- Bottom annotations ---
label(diagram, "27,800 men",   (point(pV1, S).x,       yBotAnnot1), fontsize(7pt));
label(diagram, "LiuJia Port",  (point(pV1, S).x,       yBotAnnot2), fontsize(7pt));
label(diagram, "Ceylon king",  (point(pBattle2, S).x,  yBotAnnot1), fontsize(7pt));
label(diagram, "Alagakkonara", (point(pBattle2, S).x,  yBotAnnot2), fontsize(7pt));
label(diagram, "Su Ganla",     (point(pBattle3, S).x,  yBotAnnot1), fontsize(7pt));
label(diagram, "19 states",    (point(pV4, S).x,       yBotAnnot1), fontsize(7pt));
label(diagram, "tribute",      (point(pV4, S).x,       yBotAnnot2), fontsize(7pt));
label(diagram, "Bestow seal",  (point(pV6, S).x,       yBotAnnot1), fontsize(7pt));
label(diagram, "Old Port",     (point(pV6, S).x,       yBotAnnot2), fontsize(7pt));
label(diagram, "Hongxi",       (point(pTransition, S).x, yBotAnnot1), fontsize(7pt));
label(diagram, "Emperor",      (point(pTransition, S).x, yBotAnnot2), fontsize(7pt));
label(diagram, "Final",        (point(pV7, S).x,       yBotAnnot1), fontsize(7pt));
label(diagram, "voyage",       (point(pV7, S).x,       yBotAnnot2), fontsize(7pt));

// --- Bottom quote ---
label(diagram, "\"After Zheng He, all who sailed overseas praised him to foreign lands.\"",
      (0, yQuote), fontsize(9pt));

// --- Dynasty color bar (bottom decorative) ---
fill(diagram, box((xStart-1, yBar), (xStart+11.5*dx, yBar+barH)), voyageColor);
fill(diagram, box((xStart+11.5*dx, yBar), (xStart+13*dx, yBar+barH)), hongxiColor);
fill(diagram, box((xStart+13*dx, yBar), (xStart+15.5*dx, yBar+barH)), xuandeColor);
fill(diagram, box((xStart+15.5*dx, yBar), (xStart+17.5*dx, yBar+barH)), endColor);

shipout(diagram);

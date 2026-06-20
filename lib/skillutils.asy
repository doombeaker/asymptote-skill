// skillutils.asy — Reusable picture-based diagram utilities
//
// Provides label_box_pic() and label_rounded_pic() for creating positioned,
// styled label boxes as picture components (rectangular and rounded-corner),
// roundbox() for creating rounded rectangle paths, pics_bbox() for computing
// the combined bounding box of multiple pictures using point() anchors, and
// pics_cluster() for background cluster boxes.
//
// Follow the picture + point() pattern:
//   - Create nodes with label_box_pic() or label_rounded_pic()
//   - Connect with point() anchors
//   - Add to parent picture with add()

// ==========================================
// settings for using Chinese with Asymptote
// ==========================================
import settings;
tex="xelatex";
usepackage("ctex");

// ==========================================
// LABEL BOX — picture component with built-in positioning
// ==========================================

// Create a labeled, filled, bordered box as a picture, shifted to `position`.
//
// Parameters:
//   position   — shift vector applied to the returned picture,
//                so the box center lands at this point in the parent
//                coordinate system. Use (0,0) for an origin-centered
//                picture; the caller can also ignore this and apply
//                shift() externally if they prefer that style.
//   box_width  — total width of the box (user units)
//   box_height — total height of the box (user units)
//   lineDy     — vertical spacing between consecutive text lines
//   lines      — array of label strings, drawn top-to-bottom
//   label_text — pen for label rendering (font size, color, weight, etc.).
//                Unlike the original which hardcodes fontsize(9pt), this
//                gives the caller full control. Typical usage:
//                  fontsize(9pt)                 — size only
//                  fontsize(8pt) + rgb(0.5,0.5,0.5)  — size + color
//                  fontsize(10pt) + blue            — size + color
//   fillPen    — fill color/pen for the box interior
//   borderPen  — stroke color/pen for the box outline
//
// Returns:
//   A picture containing the box and labels, already shifted to `position`.
//   Use directly with add(dest, pic), or query anchors with point(pic, dir).
//
picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string[] lines,
                      pen label_text, pen fillPen, pen borderPen) {
    picture pic;

    // Draw box centered at origin
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    fill(pic, box(bl, tr), fillPen);
    draw(pic, box(bl, tr), borderPen);

    // Lay out lines top-to-bottom, vertically centered.
    // y0 = topmost line's y-coordinate (positive = up).
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);

    // Apply position shift and return
    return shift(position) * pic;
}

// Single-string convenience overload.
// Wraps the single text into a one-element string array.
picture label_box_pic(pair position, real box_width, real box_height,
                      real lineDy, string text,
                      pen label_text, pen fillPen, pen borderPen) {
    return label_box_pic(position, box_width, box_height, lineDy,
                         new string[]{text}, label_text, fillPen, borderPen);
}

// ==========================================
// BOUNDING BOX — combined extent of multiple pictures
// ==========================================

// Compute the axis-aligned bounding box enclosing all given pictures.
//
// Uses point(pic, SW) and point(pic, NE) instead of min(pic)/max(pic).
//
// WHY NOT min()/max():
//   min(pic)/max(pic) return coordinates through the picture's user→PS
//   transform. For a standalone sub-picture that has never been add()-ed
//   to a sized parent picture, this transform is the identity in PostScript
//   bp units (1/72 inch), NOT in user units. The resulting coordinates are
//   therefore in an unrelated scale and will appear wildly offset.
//
//   point(pic, dir) does NOT have this problem — it computes boundary
//   anchors from the picture's drawn content + stored transforms, returning
//   correct user-coordinate values even for standalone (un-added) pictures.
//
// Parameters:
//   pics — array of pictures whose combined extent is needed
//
// Returns:
//   A 2-element pair array: {bottomLeft, topRight}.
//   Usage:
//     pair[] bb = pics_bbox(new picture[]{pA, pB, pC});
//     pair lo = bb[0];  // overall bottom-left (min x, min y)
//     pair hi = bb[1];  // overall top-right  (max x, max y)
//
pair[] pics_bbox(picture[] pics) {
    pair lo = point(pics[0], SW);
    pair hi = point(pics[0], NE);

    for (int i = 1; i < pics.length; ++i) {
        pair lo_i = point(pics[i], SW);
        pair hi_i = point(pics[i], NE);
        lo = (min(lo.x, lo_i.x), min(lo.y, lo_i.y));
        hi = (max(hi.x, hi_i.x), max(hi.y, hi_i.y));
    }

    return new pair[]{lo, hi};
}

// ==========================================
// ROUNDED BOX — picture component with rounded corners
// ==========================================

// Create a rounded rectangle path.
//
// Parameters:
//   bl — bottom-left corner of the bounding rectangle
//   tr — top-right corner of the bounding rectangle
//   r  — corner radius (clamped to half the smaller dimension)
//
// Returns:
//   A cyclic path tracing the rounded rectangle, drawn clockwise
//   starting from the left edge above the bottom-left corner.
path roundbox(pair bl, pair tr, real r) {
    r = min(r, (tr.x - bl.x) / 2, (tr.y - bl.y) / 2);
    return (bl.x, bl.y + r){down}..{right}(bl.x + r, bl.y) --
           (tr.x - r, bl.y){right}..{up}(tr.x, bl.y + r) --
           (tr.x, tr.y - r){up}..{left}(tr.x - r, tr.y) --
           (bl.x + r, tr.y){left}..{down}(bl.x, tr.y - r) -- cycle;
}

// Create a labeled, filled, bordered rounded box as a picture,
// shifted to `position`.
//
// Parameters:
//   position   — shift vector applied to the returned picture,
//                so the box center lands at this point in the parent
//                coordinate system.
//   box_width  — total width of the box (user units)
//   box_height — total height of the box (user units)
//   radius     — corner radius (clamped to half the smaller dimension)
//   lineDy     — vertical spacing between consecutive text lines
//   lines      — array of label strings, drawn top-to-bottom
//   label_text — pen for label rendering (font size, color, weight, etc.)
//   fillPen    — fill color/pen for the box interior
//   borderPen  — stroke color/pen for the box outline
//
// Returns:
//   A picture containing the rounded box and labels, already shifted
//   to `position`. Use directly with add(dest, pic), or query anchors
//   with point(pic, dir).
//
picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string[] lines,
                          pen label_text, pen fillPen, pen borderPen) {
    picture pic;

    // Draw rounded box centered at origin
    pair bl = (-box_width / 2, -box_height / 2);
    pair tr = ( box_width / 2,  box_height / 2);
    path rbox = roundbox(bl, tr, radius);
    fill(pic, rbox, fillPen);
    draw(pic, rbox, borderPen);

    // Lay out lines top-to-bottom, vertically centered
    real y0 = (lines.length - 1) * lineDy / 2;
    for (int i = 0; i < lines.length; ++i)
        label(pic, lines[i], (0, y0 - i * lineDy), label_text);

    // Apply position shift and return
    return shift(position) * pic;
}

// Single-string convenience overload.
// Wraps the single text into a one-element string array.
picture label_rounded_pic(pair position, real box_width, real box_height,
                          real radius, real lineDy, string text,
                          pen label_text, pen fillPen, pen borderPen) {
    return label_rounded_pic(position, box_width, box_height, radius, lineDy,
                             new string[]{text}, label_text, fillPen, borderPen);
}

// ==========================================
// CLUSTER BOX — background box around a group of pictures
// ==========================================

// Draw a fill+border rectangle enclosing all given pictures with padding,
// returned as a picture. Intended to be added BEFORE the node pictures
// so it appears behind them.
//
// Parameters:
//   pics      — array of pictures to enclose
//   padx      — horizontal padding between the nodes' bbox and the box edge
//   pady      — vertical padding between the nodes' bbox and the box edge
//   fillPen   — interior fill pen (use nullpen for no fill)
//   borderPen — outline stroke pen (use nullpen for no border)
//
// Returns:
//   A picture containing just the background rectangle, positioned to
//   surround all nodes. Add it before the nodes so it renders behind:
//
//     picture bg = pics_cluster(new picture[]{pA, pB, pC}, 0.4, 0.3, clusterFill, clusterPen);
//     add(diagram, bg);       // behind
//     add(diagram, pA);       // in front
//     add(diagram, pB);
//     add(diagram, pC);
//
picture pics_cluster(picture[] pics, real padx, real pady,
                     pen fillPen, pen borderPen) {
    pair[] bb = pics_bbox(pics);
    pair lo = bb[0] - (padx, pady);
    pair hi = bb[1] + (padx, pady);

    picture bg;
    filldraw(bg, box(lo, hi), fillPen, borderPen);
    return bg;
}

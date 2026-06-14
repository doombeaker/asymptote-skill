# Flowcharts with Asymptote

## Using the flowchart Module

```asy
import flowchart;
```

The `flowchart.asy` module provides structured block diagram and flowchart drawing capabilities.

## Block Types

```asy
// Rectangle block
block b1 = rectangle("Process", (0,0));

// Rounded rectangle
block b2 = roundrectangle("Start", (0,2));

// Diamond (decision)
block b3 = diamond("Decision?", (2,1));

// Circle
block b4 = circle("", (4,1));

// Parallelogram (I/O)
block b5 = parallelogram("Input", (2,-1));

// Custom polygon
pair[] pts = {(0,0), (1,0.5), (1,1.5), (0,2), (-1,1.5), (-1,0.5)};
block b6 = polygon("Hexagon", pts, (0,3));
```

## Drawing Blocks

```asy
// Draw individual blocks
draw(b1);
draw(b2, fillpen=lightblue, drawpen=black+1);

// Draw all blocks in a picture
add(b1);
add(b2);
```

## Connecting Blocks

```asy
// Basic connection with arrow
blockconnector operator --=blockconnector(pic, t);
b1--Arrow--b2;

// With label
b1--Label("Yes", align=N)--Arrow--b2;

// Orthogonal routing
b1--Down--Left--Arrow--b3;
b1--Right--Up--Label("No")--Arrow--b4;

// Curved connection
b1..Arrow..b2;

// Dashed connection
b1--dashed--b2;
```

## Block Positioning

```asy
// Absolute positioning
block a = rectangle("A", (0,0));
block b = rectangle("B", (3,0));
block c = rectangle("C", (1.5,-2));

// Relative positioning (using transforms)
block b = rectangle("B", shift(3,0)*a.center);
```

## Styling

```asy
// Block fill and border
block b = rectangle("Process", (0,0), fillpen=lightyellow, drawpen=black+0.5);

// Text styling
block b = rectangle("Bold Text", (0,0), drawpen=currentpen+fontsize(10pt));

// Minimum sizes
real minblockwidth = 2cm;
real minblockheight = 1cm;
```

## Control System Diagram Example

```asy
size(0,4cm);
import flowchart;

block delay=roundrectangle("$e^{-sT_t}$", (0.33,0));
block system=roundrectangle("$\\frac{s+3}{s^2+0.3s+1}$", (0.6,0));
block controller=roundrectangle("$0.06\\left( 1 + \\frac{1}{s}\\right)$", (0.45,-0.25));
block sum1=circle("", (0.15,0), mindiameter=0.3cm);
block junction1=circle("", (0.75,0), fillpen=currentpen);

draw(delay);
draw(system);
draw(controller);
draw(sum1);
draw(junction1);

add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    
    block(0,0)--Label("$u$", align=N)--Arrow--sum1--Arrow--delay--Arrow--
      system--junction1--Label("$y$", align=N)--Arrow--block(1,0);
    
    junction1--Down--Left--Arrow--controller--Left--Up--
      Label("$-$", position=3, align=ESE)--Arrow--sum1;
});
```

## Algorithm Flowchart Example

```asy
size(200,300);
import flowchart;

block start = roundrectangle("Start", (0,3));
block input = parallelogram("Read $n$", (0,2));
block process = rectangle("$sum = 0$", (0,1));
block decision = diamond("$i < n$?", (0,0));
block compute = rectangle("$sum += i$", (-2,-1));
block output = parallelogram("Print $sum$", (0,-2));
block end = roundrectangle("End", (0,-3));

draw(start);
draw(input);
draw(process);
draw(decision);
draw(compute);
draw(output);
draw(end);

add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    start--Arrow--input--Arrow--process--Arrow--decision;
    decision--Label("No", align=E)--Arrow--output--Arrow--end;
    decision--Label("Yes", align=W)--Arrow--compute--Up--Arrow--process;
});
```

## Tips for Flowcharts

1. Use `mindiameter` for circles to ensure consistent size
2. Use `fillpen=invisible` for transparent blocks
3. The `blockconnector` operator `--` handles automatic routing
4. Labels on connections use `Label("text", align=Direction)`
5. Orthogonal routing with `Up`, `Down`, `Left`, `Right`

## Aesthetic Best Practices

### Keep Blocks Minimal

**Flowchart blocks should contain only keywords** — brief labels of 1-3 words maximum. This ensures readability and prevents blocks from becoming oversized or text from overflowing.

**Good example:**
```asy
block init = rectangle("Init", (0,0));
block process = rectangle("Process", (0,-2));
block check = diamond("Valid?", (0,-4));
```

**Bad example (too much text in blocks):**
```asy
// AVOID: Blocks with long descriptions
block bad = rectangle("Initialize all variables and set default values", (0,0));
```

### Handle Detailed Explanations Separately

When a step requires detailed explanation that won't fit cleanly in a block:

1. **Use a keyword in the block** — keep the diagram clean
2. **Add a separate legend or annotation area** — place detailed explanations in a text box or table outside the main flowchart

```asy
size(400,300);
import flowchart;

// Main flowchart with minimal keywords
block start = roundrectangle("Start", (0,0));
block load = rectangle("Load Data", (0,-2));
block validate = diamond("Valid?", (0,-4));
block process = rectangle("Process", (0,-6));
block end = roundrectangle("End", (0,-8));

draw(start); draw(load); draw(validate); draw(process); draw(end);

add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    start--Arrow--load--Arrow--validate;
    validate--Label("Yes")--Arrow--process--Arrow--end;
    validate--Label("No", align=E)--Arrow--block(2,-4);
});

// Separate legend/annotation area on the right
label("\textbf{Legend:}", (4,0), W);
label("Load Data: Read CSV file", (4,-0.8), W, fontsize(9pt));
label("Process: Filter, transform, save", (4,-1.6), W, fontsize(9pt));
```

### Spacing and Alignment

- Maintain consistent spacing between blocks (typically 1.5-2x block height)
- Align related blocks horizontally or vertically for visual flow
- Use `minblockwidth` and `minblockheight` to enforce uniform block sizes

// Template: Flowchart
// Use this as a starting point for flowchart diagrams

size(10cm, 0);
import flowchart;

// Define blocks
block start = roundrectangle("Start", (0, 3));
block input = parallelogram("Input", (0, 2));
block process = rectangle("Process", (0, 1));
block decision = diamond("Decision?", (0, 0));
block output = parallelogram("Output", (2, 0));
block end = roundrectangle("End", (0, -2));

// Draw blocks
draw(start, fillpen=lightgreen);
draw(input, fillpen=lightyellow);
draw(process, fillpen=lightblue);
draw(decision, fillpen=lightcyan);
draw(output, fillpen=lightyellow);
draw(end, fillpen=lightred);

// Connect blocks
add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    
    start--Arrow--input--Arrow--process--Arrow--decision;
    decision--Label("Yes", align=E)--Arrow--output;
    decision--Label("No", align=W)--Arrow--end;
    output--Arrow--end;
});

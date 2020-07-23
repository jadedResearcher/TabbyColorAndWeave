import 'dart:html';

import 'scripts/Fabric.dart';
import 'scripts/Util.dart';

List<Pattern> patterns = [];
Fabric fabric;
void main() {
  Element output = querySelector('#output');
  Element controls = querySelector('#controls');
  initPatterns();
  patternLinks();
  fabric = new Fabric(1000,800);
   //fabric.debug();
   fabric.renderToParent(output,controls);
  // Util.test();

}

void patternLinks() {
    Element  navbar = querySelector('#navbar');
    for(Pattern p in patterns) {
        AnchorElement anchor = new AnchorElement()..text = p.name..classes.add("navbar-item");
        navbar.append(anchor);
        anchor.onClick.listen((Event e) {
            fabric.syncPatternToWeft(p.weftPattern);
            fabric.syncPatternToWarp(p.warpPattern);

        });
    }

}

void initPatterns() {
    patterns.add(new Pattern("Houndstooth", "1,1,0,0", "1,1,0,0"));
    patterns.add(new Pattern("Log Cabin", "1,0,1,0,1,0,0,1,0,1,0", "1,0,1,0,1,0,0,1,0,1,0"));
    patterns.add(new Pattern("Horizontal Stripes", "1,0,1,0", "1,0,1,0"));
    patterns.add(new Pattern("Vertical Stripes", "1,0,1,0", "0,1,0,1"));
    patterns.add(new Pattern("Interleave", "1,1,0", "1,1,0"));
    patterns.add(new Pattern("Bars", "1,0", "1,1,0"));
    patterns.add(new Pattern("Vines", "0,1,0", "1"));
    patterns.add(new Pattern("Foxes", "1,1,9,9,9,1", "1,9,9,1"));
    patterns.add(new Pattern("Stars", "10,10,1,1,1,10", "10,1,1,10"));
    patterns.add(new Pattern("Ladders", "1,0,0,0,0,2,0,2,0,0,0,0,1,0", "1"));
    patterns.add(new Pattern("T-Bar", "1,0,0,1,0,1,0", "1,1,0,0,1,1,0,0"));
    patterns.add(new Pattern("Boxes", "1,1,2,2,3,3,4,4,5,5", "1,1,2,2,3,3,4,4,5,5"));
    patterns.add(new Pattern("Plaid", "0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1", "0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1"));

}

class Pattern {
    String name;
    String warpPattern;
    String weftPattern;
    Pattern(this.name, this.warpPattern, this.weftPattern);
}

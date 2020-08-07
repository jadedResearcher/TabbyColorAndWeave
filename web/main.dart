import 'dart:html';

import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';

import 'scripts/Fabric.dart';
import 'scripts/Util.dart';
import 'scripts/WeftObject.dart';

List<Pattern> patterns = [];
Fabric fabric;
void main() {
  Element output = querySelector('#output');
  Element controls = querySelector('#controls');
  Element stats = querySelector('#stats');
  Element warpingGuide = querySelector("#warpingGuide");

  initPatterns();
  patternLinks();
  fabric = new Fabric(1200,1000);
   //fabric.debug();
   fabric.renderToParent(output,controls,stats, warpingGuide);
   //Util.test();
  //testWeftObject();

}

void testWeftObject() {
    WeftObject first = WeftObject(new Colour(), 0, [0,0,1]);
    print(first.pickupPattern);
    for(int i = 0; i <10; i++) {
        print("is pick $i 1? ${first.pickIs1(i)}");
    }
}

void patternLinks() {
    Element  navbar = querySelector('#navbar');
    for(Pattern p in patterns) {
        AnchorElement anchor = new AnchorElement()..text = p.name..classes.add("navbar-item");
        navbar.append(anchor);
        anchor.onClick.listen((Event e) {
            fabric.syncPatternToWarp(p.warpPattern);
            fabric.syncPatternToWeft(p.weftPattern);
            if(p.pickupPattern != null) fabric.syncPickupToWeft(p.pickupPattern);

        });
    }

}

void initPatterns() {
    patterns.add(new RandomPattern());

    patterns.add(new Pattern("Houndstooth", "1,1,0,0", "1,1,0,0"));
    patterns.add(new Pattern("Log Cabin", "1,0,1,0,1,0,0,1,0,1,0", "1,0,1,0,1,0,0,1,0,1,0"));
    patterns.add(new Pattern("Horizontal Stripes", "1,0,1,0", "1,0,1,0"));
    patterns.add(new Pattern("Vertical Stripes", "1,0,1,0", "0,1,0,1"));
    patterns.add(new Pattern("Interleave", "1,1,0", "1,1,0"));
    patterns.add(new Pattern("2/1 Twill", "0", "1","0,0,1\n1,0,0\n0,1,0"));
    patterns.add(new Pattern("2/1 Twill 2", "0", "1","0,0,1\n1,0,0\n0,1,0\n0,0,1\n1,0,0\n0,1,0\n0,0,1\n1,0,0\n0,1,0\n0,0,1\n1,0,0\n0,1,0\n1,1,0\n0,1,1\n1,0,1\n1,1,0\n0,1,1\n1,0,1\n1,1,0\n0,1,1\n1,0,1\n1,1,0\n0,1,1\n1,0,1"));
    patterns.add(new Pattern("Foxes", "1,1,9,9,9,1", "1,9,9,1"));
    patterns.add(new Pattern("WindowBox Pickup", "6,6,6,7", "0,0,7,0,0,7","0,1\n1,0\n0,1,0,0\n1,0\n0,1\n1,1,1,0"));
    patterns.add(new Pattern("T-Bar", "1,0,0,1,0,1,0", "1,1,0,0,1,1,0,0"));
    patterns.add(new Pattern("Plaid","0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1","0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"));

}

class Pattern {
    String name;
    String warpPattern;
    String weftPattern;
    String pickupPattern = "0,1\n1,0";

    Pattern(this.name, this.warpPattern, this.weftPattern, [this.pickupPattern = "0,1\n1,0"]);
}

//every time you ask for warp/weft its different
class RandomPattern extends Pattern {
    Random rand = new Random();

    RandomPattern():super("Random", null,null);
    String savedWarpPattern;

    @override
    String get warpPattern {
        String ret = "";
        int patternSize = rand.nextIntRange(1,20);
        for(int i = 0; i< patternSize; i++) {
            ret = "${rand.nextBool()?"0":"1"},$ret";
        }
        savedWarpPattern = ret.substring(0,ret.length-1);
        return savedWarpPattern;
    }

    @override
    String get weftPattern {
        if(rand.nextDouble() < .5 && savedWarpPattern != null) {
            return savedWarpPattern;
        }
        savedWarpPattern = null;
        String ret = "";
        int patternSize = rand.nextIntRange(1,20);
        for(int i = 0; i< patternSize; i++) {
            ret = "${rand.nextBool()?"0":"1"},$ret";
        }
        return ret.substring(0,ret.length-1);
    }


}

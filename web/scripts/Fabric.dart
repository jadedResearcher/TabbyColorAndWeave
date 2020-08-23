
import 'package:CommonLib/Colours.dart';
import 'FabricView.dart';
import 'WarpObject.dart';
import 'WeftObject.dart';
//todo toggles for balanced wrave, slightly warp facing snd slightly weft facinh
class Fabric {
    FabricView view;
    int height;
    int width;
    int warpBuffer = WarpObject.WIDTH*4 ;
    int weftBuffer = WeftObject.WIDTH*6;


    //String warpPatternStart = "1,0,1,0,1,0,0,1,0,1,0";
   // String weftPatternStart = "1,0,1,0,1,0,0,1,0,1,0";
    String warpPatternStart = "1,1,0,0";
    String weftPatternStart = "1,1,0,0";
    String pickupPatternStart = "0,1\n1,0";

    List<WarpObject> warp = new List<WarpObject>();
    List<WeftObject> weft = new List<WeftObject>();
    List<Colour> colors = new List<Colour>();

    Fabric(this.height, this.width) {
        view = new FabricView(this);
    }

    void initColors() {
        colors.add(new Colour(200,200,200));
        colors.add(new Colour(50,50,50));
        colors.add(new Colour(181,44,44));
        colors.add(new Colour(131,2,2));
        colors.add(new Colour(31,132,31));
        colors.add(new Colour(0,0,0));
        colors.add(new Colour(255,255,255));
        colors.add(new Colour(255,204,204));
        colors.add(new Colour(255,138,200));
        colors.add(new Colour(250,133,0));
        colors.add(new Colour(245,210,112));
        colors.add(new Colour(212,105,245));
    }

    String exportWarpPattern() {
        List<int> pattern = <int>[];
        for(WarpObject w in warp) {
            pattern.add(colors.indexOf(w.color));
        }
        return pattern.join(",");
    }

    String exportWeftPattern() {
        List<int> pattern = <int>[];
        for(WeftObject w in weft) {
            pattern.add(colors.indexOf(w.color));
        }
        return pattern.join(",");
    }

    String exportColorPattern() {
        List<String> pattern = <String>[];
        for(Colour color in colors) {
            pattern.add(color.toStyleString());
        }
        return pattern.join(",");
    }




}
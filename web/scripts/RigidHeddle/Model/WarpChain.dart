import 'package:CommonLib/Colours.dart';

import '../View/WarpChainView.dart';
import 'Heddle.dart';

class WarpChain {
    WarpChainView view;
    Colour color;
    //in order.
    List<WarpThread> threads = new List<WarpThread>();
     WarpChain(int numberThreads, Colour this.color) {
         initWarpChain(numberThreads, color);
    }

     void initWarpChain(int numberThreads, Colour color) {
        for(int i =0; i<numberThreads; i++) {
            threads.add(new WarpThread(color));
        }
    }

}

class WarpThread {
    ThreadView view;
    Colour color;
    List<Section> heddleSections = new List<Section>();

    WarpThread(Colour this.color);
}
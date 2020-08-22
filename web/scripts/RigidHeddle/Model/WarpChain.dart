import 'package:CommonLib/Colours.dart';

class WarpChain {
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
    Colour color;
    //position 0 is which hole/slot you're going into in the first heddle, position 1 is the same for the second and so on.
    List<int> heddle_indices = new List<int>();

    WarpThread(Colour this.color);
}
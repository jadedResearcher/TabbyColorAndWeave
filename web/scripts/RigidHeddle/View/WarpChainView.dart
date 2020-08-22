import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Utility.dart';

import '../Model/Heddle.dart';
import '../Model/WarpChain.dart';

/*

    should render a set of rectangles for this.
    if one is clicked, should let the loom know its selected.
 */
 class WarpChainView{
     WarpChain chain;
     Element parent;
     int startX;
     int y;
     WarpChainView(WarpChain this.chain, Element this.parent, int this.startX, this.y) {
        chain.view = this;
     }

     //returns the last position rendered, since warp chains are in a row
     int renderChain(callThread) {
        final SvgElement element = new SvgElement.tag("g")..classes.add("warpChain");
        element.text = "TODO: warp chain of color ${chain.color.toStyleString()} and threadcount ${chain.threads.length}";
        parent.append(element);
        int x = startX;
        for(WarpThread thread in chain.threads) {
            x+= 10;
            new ThreadView(thread, element,x,y, callThread)..renderThread();
        }
        return x;
    }


}

class ThreadView {
     WarpThread thread;
     Element parent;
     int x;
     int y;
     //if i am selected, call this function to let whoever cares know
     Lambda<WarpThread> callThread;
     ThreadView(this.thread, this.parent, int this.x, this.y, this.callThread) {
        thread.view = this;
     }

     void renderThreadSource() {
         RectElement rect = new RectElement();
         rect.attributes["width"] = "8";
         rect.attributes["height"] = "20";
         rect.attributes["x"] = "$x";
         rect.attributes["y"] = "$y";
         rect.attributes["fill"] = thread.color.toStyleString();
         rect.attributes["stroke"] = "#000000";
         parent.append(rect);
     }

     //todo how to make sure the lines stay synced to what they are touching?
     void renderThreadPath() {
         PathElement path = PathElement();
         String pathString = "M$x,$y";
         path.attributes["stroke"] = thread.color.toStyleString();
         path.attributes["stroke-width"] = "1";

         for(Section section in thread.heddleSections) {
             pathString = "${pathString} L${section.view.threadX},${section.view.threadY}";
         }
         path.attributes["d"] = pathString;
         parent.append(path);

     }

     void renderThread() {
         renderThreadSource();
         renderThreadPath();
     }
}

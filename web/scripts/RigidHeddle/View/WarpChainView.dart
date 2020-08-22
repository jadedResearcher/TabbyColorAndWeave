import 'dart:html';
import 'dart:svg';

import '../Model/WarpChain.dart';

 class WarpChainView{
     WarpChain chain;
     Element parent;
     int startX;
     int y;
     WarpChainView(WarpChain this.chain, Element this.parent, int this.startX, this.y);

     //returns the last position rendered, since warp chains are in a row
     int renderChain() {
        final SvgElement element = new SvgElement.tag("g")..classes.add("warpChain");
        element.text = "TODO: warp chain of color ${chain.color.toStyleString()} and threadcount ${chain.threads.length}";
        parent.append(element);
        int x = startX;
        for(WarpThread thread in chain.threads) {
            x+= 7;
            new ThreadView(thread, element,x,y)..renderThread();
        }
        return x;
    }


}

class ThreadView {
     WarpThread thread;
     Element parent;
     int x;
     int y;
     ThreadView(this.thread, this.parent, int this.x, this.y);

     void renderThread() {
         RectElement rect = new RectElement();
         rect.attributes["width"] = "5";
         rect.attributes["height"] = "10";
         rect.attributes["x"] = "$x";
         rect.attributes["y"] = "$y";
         rect.attributes["fill"] = thread.color.toStyleString();
         rect.attributes["stroke"] = "#000000";
         parent.append(rect);
     }
}

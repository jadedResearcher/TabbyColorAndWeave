import 'dart:html';
import 'dart:svg';

import '../Model/Heddle.dart';

 class HeddleView{
     Heddle heddle;
     Element parent;
     int y;

     HeddleView(Heddle this.heddle, Element this.parent, this.y);

     void renderHeddle() {
        final SvgElement element = new SvgElement.tag("g")..classes.add("heddle");
        element.text = "TODO: heddle of length ${heddle.holesAndSlots.length}";
        parent.append(element);
        int x = 10;
        for(Section section in heddle.holesAndSlots) {
            x+= 7;
            if(section is Hole) {
                new HoleView(section, element,x,y)..render();
            }else {
                new SlotView(section, element,x,y)..render();
            }
        }
    }
}

//should be two rectangles, one big and  grey, one small and in the middle and white.
class HoleView {
     Hole hole;
     Element parent;
     int x;
     int y;
     HoleView(this.hole, this.parent, this.x, this.y);

     void render() {
         int height = 50;
         int width = 10;
         RectElement rectContainer = new RectElement();
         rectContainer.attributes["width"] = "$width";
         rectContainer.attributes["height"] = "$height";
         rectContainer.attributes["x"] = "$x";
         rectContainer.attributes["y"] = "$y";
         rectContainer.attributes["fill"] = "#eee";
         rectContainer.attributes["stroke"] = "#000000";
         parent.append(rectContainer);

         RectElement rectHole = new RectElement();
         rectHole.attributes["width"] = "5";
         rectHole.attributes["height"] = "10";
         rectHole.attributes["x"] = "${x+width/4}";
         rectHole.attributes["y"] = "${y+height/2}";
         rectHole.attributes["fill"] = "#fff";
         rectHole.attributes["stroke"] = "#000000";
         parent.append(rectHole);
     }
}

//should be a rectangle as tall as the big hole rectangle, but all white (represents space between heddles)
class SlotView {
     Slot slot;
     Element parent;
     int x;
     int y;

     SlotView(this.slot, this.parent, this.x, this.y);

     void render() {
         int height = 50;
         RectElement rectContainer = new RectElement();
         rectContainer.attributes["width"] = "7";
         rectContainer.attributes["height"] = "$height";
         rectContainer.attributes["x"] = "$x";
         rectContainer.attributes["y"] = "$y";
         rectContainer.attributes["fill"] = "#fff";
         rectContainer.attributes["stroke"] = "#000000";
     }
}
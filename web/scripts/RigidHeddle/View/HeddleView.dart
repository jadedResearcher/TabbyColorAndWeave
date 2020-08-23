import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Utility.dart';

import '../Model/Heddle.dart';

 class HeddleView{
     Heddle heddle;
     Element parent;
     int y;
     Lambda<Section> callback;

     HeddleView(Heddle this.heddle, Element this.parent, this.y, this.callback) {
        heddle.view = this;
     }

     void renderHeddle() {
        final SvgElement element = new SvgElement.tag("g")..classes.add("heddle");
        element.text = "TODO: heddle of length ${heddle.holesAndSlots.length}";
        parent.append(element);
        int x = 10;
        int holewidth = 20;
        int slotwidth = 14;
        for(Section section in heddle.holesAndSlots) {
            if(section is Hole) {
                new HoleView(section, element,x,y, holewidth, callback)..render();
                x+= holewidth;
            }else {
                new SlotView(section, element,x,y, slotwidth, callback)..render();
                x+= slotwidth;
            }
        }
    }
}

abstract class SectionView {
     Section section;
    Element parent;
     Lambda<Section> callback;
     int x;
    int get threadX => x + (width/2).round();
    int holeY;
     int y;
     int get threadY => holeY;

     int width;
     SectionView(this.section, this.parent, this.x, this.y, this.width, this.callback) {
        section.view = this;
     }

}

//should be two rectangles, one big and  grey, one small and in the middle and white.
class HoleView extends SectionView {
  HoleView(Section section, Element parent, int x, int y, int width, callback) : super(section, parent, x, y, width,callback);
     void render() {
         int height = 100;
         RectElement rectContainer = new RectElement();

         rectContainer.attributes["width"] = "$width";
         rectContainer.attributes["height"] = "$height";
         rectContainer.attributes["x"] = "$x";
         rectContainer.attributes["y"] = "$y";
         rectContainer.attributes["fill"] = "#eee";
         rectContainer.attributes["stroke"] = "#000000";
         parent.append(rectContainer);
         rectContainer.onClick.listen((Event e) {
             callback(section);
         });

         RectElement rectHole = new RectElement();
         rectHole.attributes["width"] = "5";
         rectHole.attributes["height"] = "10";
         rectHole.attributes["x"] = "${x+width/4}";
         holeY = y +(height/3).round();
         rectHole.attributes["y"] = "${y+height/3}";
         rectHole.attributes["fill"] = "#fff";
         rectHole.attributes["stroke"] = "#000000";
         parent.append(rectHole);
         rectHole.onClick.listen((Event e) {
             callback(section);
         });
     }
}

//should be a rectangle as tall as the big hole rectangle, but all white (represents space between heddles)
class SlotView extends SectionView{
  SlotView(Section section, Element parent, int x, int y, int width, callback) : super(section, parent, x, y, width, callback);

     void render() {
         int height = 100;
         RectElement rectContainer = new RectElement();

         rectContainer.attributes["width"] = "$width";
         rectContainer.attributes["height"] = "$height";
         rectContainer.attributes["x"] = "$x";
         holeY = y +(50/3).round();

         rectContainer.attributes["y"] = "$y";
         rectContainer.attributes["fill"] = "#fff";
         rectContainer.attributes["stroke"] = "#000000";
         parent.append(rectContainer);
         rectContainer.onClick.listen((Event e) {
             callback(section);
         });
     }
}
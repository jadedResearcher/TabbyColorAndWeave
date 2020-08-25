import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';
import 'package:CommonLib/Utility.dart';

import '../Model/Heddle.dart';
import '../Model/Pick.dart';
import '../Model/WarpThread.dart';

class ThreadView {
     WarpThread thread;
     Element parent;
     int x;
     bool selected = false;
     RectElement rect;
     PathElement path;
     PathElement guidePath;
     int y;
     TextElement text;
     //if i am selected, call this function to let whoever cares know
     Lambda<WarpThread> callThread;
     ThreadView(this.thread, this.parent, int this.x, this.y, this.callThread) {
        thread.view = this;
     }

     void renderThreadSource() {
         rect = new RectElement();
         rect.attributes["width"] = "8";
         rect.attributes["height"] = "20";
         rect.attributes["x"] = "$x";
         rect.attributes["y"] = "$y";
         rect.attributes["fill"] = thread.color.toStyleString();
         rect.attributes["stroke"] = thread.guideColor.toStyleString();
         Colour invert = new Colour(255-thread.color.red, 255-thread.color.green, 255-thread.color.blue);
         parent.append(rect);
         rect.onClick.listen((Event e) {
             selected = !selected;
             if(!selected) {
                 rect.attributes["stroke-width"] = "1";
                 rect.attributes["stroke"] = "#000000";
             }else {
                 rect.attributes["stroke-width"] = "4";
                 rect.attributes["stroke"] = invert.toStyleString();
             }
             callThread(thread);
         });

         text = new TextElement()..text = "${thread.index}"..classes.add("threadLabel");
         text.attributes["x"] = "${x}";
         text.attributes["y"] = "${y+40}";
         parent.append(text);
     }

     void unselect() {
         selected = false;
         rect.attributes["stroke-width"] = "1";
         rect.attributes["stroke"] = thread.guideColor.toStyleString();

     }



     //todo how to make sure the lines stay synced to what they are touching?
     void renderThreadPath() {
         if(path == null) {

             guidePath = new PathElement();
             parent.append(guidePath);
             path = new PathElement();
             parent.append(path);
         }
         String pathString = "M${x+4},$y";
         path.attributes["stroke"] = thread.color.toStyleString();
         path.attributes["stroke-width"] = "1";
         int wiggle = -1*((x % 40) /10).ceil()+3 ;
         for(Section section in thread.heddleSections) {
             pathString = "${pathString} L${section.view.threadX - wiggle},${section.view.threadY+3} M${section.view.threadX - wiggle},${section.view.threadY+3}";
         }
         pathString = "$pathString Z";
         path.attributes["d"] = pathString;

         guidePath.attributes["stroke"] = thread.guideColor.toStyleString();
         guidePath.attributes["stroke-width"] = "3";
         guidePath.attributes["d"] = pathString;

         path.onMouseOver.listen((Event e) {
             path.attributes["stroke"] = thread.guideColor.toStyleString();
         });

         path.onMouseLeave.listen((Event e) {
             path.attributes["stroke"] = thread.color.toStyleString();
         });

         guidePath.onMouseOver.listen((Event e) {
             path.attributes["stroke"] = thread.guideColor.toStyleString();
         });

         guidePath.onMouseLeave.listen((Event e) {
             path.attributes["stroke"] = thread.color.toStyleString();
         });

     }

     void renderThread() {
         renderThreadSource();
         renderThreadPath();
     }

     void teardown() {
        path.remove();
        rect.remove();
        guidePath.remove();
        text.remove();
     }
}

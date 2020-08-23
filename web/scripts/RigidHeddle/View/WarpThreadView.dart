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
     int y;
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
         rect.attributes["stroke"] = "#000000";
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
     }

     void unselect() {
         selected = false;
         rect.attributes["stroke-width"] = "1";
         rect.attributes["stroke"] = "#000000";

     }



     //todo how to make sure the lines stay synced to what they are touching?
     void renderThreadPath() {
         if(path == null) {
             path = new PathElement();
         }
         String pathString = "M${x+4},$y";
         path.attributes["stroke"] = thread.color.toStyleString();
         path.attributes["stroke-width"] = "2";
         int wiggle = -1*((x % 40) /10).ceil()+3 ;
         for(Section section in thread.heddleSections) {
             pathString = "${pathString} L${section.view.threadX - wiggle},${section.view.threadY+3} M${section.view.threadX - wiggle},${section.view.threadY+3}";
         }
         pathString = "$pathString Z";
         path.attributes["d"] = pathString;
         parent.append(path);

     }

     void renderThread() {
         renderThreadSource();
         renderThreadPath();
     }
}
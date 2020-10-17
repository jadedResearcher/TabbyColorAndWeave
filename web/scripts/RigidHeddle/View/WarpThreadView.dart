import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';
import 'package:CommonLib/Utility.dart';

import '../../WarpObject.dart';
import '../Model/Heddle.dart';
import '../Model/Pick.dart';
import '../Model/WarpThread.dart';

class ThreadView {
     WarpThread thread;
     Element parent;
     int x;
     Action changeCallback;
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

     void renderThreadGuide(CanvasElement canvas, int x) {
         if(thread.heddleSections.isEmpty) return;
         Colour inverse = new Colour(255-thread.color.red, 255-thread.color.green, 255-thread.color.blue);
         canvas.context2D.fillStyle = inverse.toStyleString();
         canvas.context2D.strokeRect(x,0,WarpObject.WIDTH,WarpObject.WIDTH);
         canvas.context2D.strokeRect(x,WarpObject.WIDTH,WarpObject.WIDTH,WarpObject.WIDTH);
         canvas.context2D.strokeRect(x+1,WarpObject.WIDTH*2,WarpObject.WIDTH,WarpObject.WIDTH);
         if(thread.heddleSections.length > 0 && thread.heddleSections[0] is Hole) {//first shed
             canvas.context2D.fillRect(x+1,0,WarpObject.WIDTH,WarpObject.WIDTH);
         }else if(thread.heddleSections.length > 1 && thread.heddleSections[1] is Hole) {//2nd shed
             canvas.context2D.fillRect(x+1,WarpObject.WIDTH,WarpObject.WIDTH,WarpObject.WIDTH);
         }else { //third shed
             canvas.context2D.fillRect(x+1,WarpObject.WIDTH*2,WarpObject.WIDTH,WarpObject.WIDTH);
         }
     }

     void renderThreadSource() {
         if(rect != null) {
             rect.remove();
             text.remove();
         }
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
         if(thread.obfuscate) path.attributes["opacity"] = "0.2";
         int wiggle = -1*((x % 40) /10).ceil()+3 ;
         for(Section section in thread.heddleSections) {
             pathString = "${pathString} L${section.view.threadX - wiggle},${section.view.threadY+3} M${section.view.threadX - wiggle},${section.view.threadY+3}";
         }
         pathString = "$pathString Z";
         path.attributes["d"] = pathString;

         guidePath.attributes["stroke"] = thread.guideColor.toStyleString();
         guidePath.attributes["stroke-width"] = "3";
         guidePath.attributes["d"] = pathString;

         if(thread.obfuscate) guidePath.attributes["opacity"] = "0.2";


         path.onMouseOver.listen((Event e) {
            focus();
         });


         path.onMouseLeave.listen((Event e) {
             unfocus();
         });

         guidePath.onMouseOver.listen((Event e) {
             focus();
         });

         guidePath.onMouseLeave.listen((Event e) {
             unfocus();
         });

     }

     void focus() {
         path.attributes["stroke"] = thread.guideColor.toStyleString();
         guidePath.attributes["stroke-width"] = "6";
         guidePath.attributes["opacity"] = "1.0";
         path.attributes["opacity"] = "1.0";

     }

     void unfocus() {
         path.attributes["stroke"] = thread.color.toStyleString();
         guidePath.attributes["stroke-width"] = "3";
         if(thread.obfuscate) {
             guidePath.attributes["opacity"] = "0.2";
             path.attributes["opacity"] = "0.2";
         }

     }

     void renderThread() {
         teardown();
         renderThreadSource();
         renderThreadPath();
     }

     void teardown() {
         if(path != null) {
             path.remove();
             rect.remove();
             guidePath.remove();
             text.remove();
         }
     }
}

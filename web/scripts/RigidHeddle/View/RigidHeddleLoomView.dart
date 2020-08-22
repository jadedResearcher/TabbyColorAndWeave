import 'dart:html';
import 'dart:svg';

import '../Model/Heddle.dart';
import '../Model/RigidHeddleLoom.dart';
import '../Model/WarpChain.dart';
import 'HeddleView.dart';
import 'WarpChainView.dart';

 class RigidHeddleLoomView {
     Element parent;
     RigidHeddleLoom loom;
     RigidHeddleLoomView(this.loom, this.parent);
     int heddlesX;
     int heddlesY;
     SvgElement heddleContainer;
     bool draggingHeddles = false;

     void renderLoom() {
        final SvgElement loomElement = SvgElement.tag("svg")..classes.add("loom");
        loomElement.attributes["width"] = "1200";
        loomElement.attributes["height"] = "300";
        parent.append(loomElement);
        heddleContainer = SvgElement.tag("g")..classes.add("heddles");
        loomElement.append(heddleContainer);
        int y = 125;
        for(Heddle heddle in loom.heddles) {
            new HeddleView(heddle, heddleContainer, y ).renderHeddle();
            y+= -100;
        }

        final SvgElement warpContainer = SvgElement.tag("g")..classes.add("warpChains");
        loomElement.append(warpContainer);
        int x = 0;
        for(WarpChain chain in loom.warpChains) {
            x = new WarpChainView(chain, warpContainer,x, 275).renderChain();
        }

        setupControls();
        handleMove(150, 0);


    }

    void setupControls() {

         heddleContainer.onMouseDown.listen((Event e) {
             draggingHeddles = true;
         });

         window.onMouseUp.listen((Event e) {
             draggingHeddles = false;
         });

         window.onMouseMove.listen((MouseEvent e) {
             if(draggingHeddles) handleMove((e.offset.x).ceil(), (e.offset.y).ceil());
         });
    }

     void handleMove(int newX, int newY) {
         heddlesX = newX;
         heddlesY = newY;
         heddleContainer.attributes["transform"] = "translate($newX,$newY)";
     }
}
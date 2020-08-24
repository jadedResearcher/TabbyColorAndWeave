import 'dart:html';
import 'dart:svg';

import '../../Fabric.dart';
import '../../FabricRenderer.dart';
import '../Model/Heddle.dart';
import '../Model/RigidHeddleLoom.dart';
import '../Model/WarpThread.dart';
import 'HeddleView.dart';
import 'WarpThreadView.dart';

 class RigidHeddleLoomView {
     Element parent;
     RigidHeddleLoom loom;
     RigidHeddleLoomView(this.loom, this.parent);
     int heddlesX;
     int heddlesY;
     FabricRenderer renderer;
     SvgElement heddleContainer;
     bool draggingHeddles = false;
     WarpThread selectedThread;
     int height = 400;
     Element instructions;
     void renderLoom() {
         instructions = new DivElement()..text = "Instructions:"..classes.add("instructions");
         setInstructions();
         parent.append(instructions);
        final SvgElement loomElement = SvgElement.tag("svg")..classes.add("loom");
        loomElement.attributes["width"] = "1200";
        loomElement.attributes["height"] = "$height";
        parent.append(loomElement);
        heddleContainer = SvgElement.tag("g")..classes.add("heddles");
        loomElement.append(heddleContainer);
        int y = 125;
        for(Heddle heddle in loom.heddles) {
            new HeddleView(heddle, heddleContainer, y,pickHeddleSection).renderHeddle();
            y+= -125;
        }

        final SvgElement warpContainer = SvgElement.tag("g")..classes.add("warpChains");
        loomElement.append(warpContainer);
        int x = 0;
        for(WarpThread warpThread in loom.allThreads) {
            new ThreadView(warpThread, warpContainer, x, height - 25,pickThread).renderThread();
            x+=11;
        }
        renderControls();
        renderFabric();
    }

    void renderControls() {
         DivElement container = new DivElement();
         parent.append(container);
        ButtonElement clearButton = new ButtonElement()..text = "Clear All Threading";
         container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            for(WarpThread thread in loom.allThreads) {
                thread.heddleSections.clear();
                thread.view.renderThreadPath();
            }
        });

        ButtonElement updateButton = new ButtonElement()..text = "Update Fabric From Loom";
         container.append(updateButton);
        updateButton.onClick.listen((Event e) {
            renderFabric();
        });

    }


    void renderFabric() {
         if(renderer == null) {
             Fabric fabric = loom.exportLoomToFabric(null);
             renderer = new FabricRenderer(fabric);
             renderer.renderToParent(parent);
         }else {
             loom.exportLoomToFabric(renderer.fabric);
             renderer.update();
         }
    }

    void setInstructions() {
         if(selectedThread != null) {
             instructions.text = "Instructions: Now that a thread is selected, you can click a hole or slot in any heddle to thread it. You can click multiple holes or slots.   You can click the thread again (or a new thread) to deselect it.   ";
         }else {
             instructions.text = "Instructions: Click a colored thread box below to select it and begin Threading Mode.";
         }
    }

    void pickThread(WarpThread thread) {
         if(selectedThread == thread) {
             selectedThread = null;
         }else {
             if(selectedThread != null) selectedThread.view.unselect();
             selectedThread = thread;
             thread.heddleSections.clear();
             thread.view.renderThreadPath();
         }
         setInstructions();
     }

     void clearPickedThread() {
         selectedThread = null;
        setInstructions();
     }

     void pickHeddleSection(Section section) {
         if(selectedThread != null) {
            selectedThread.heddleSections.add(section);
            selectedThread.view.renderThreadPath();
         }
     }

    void setupControls() {

         heddleContainer.onMouseDown.listen((Event e) {
             draggingHeddles = true;
         });

         window.onMouseUp.listen((Event e) {
             if(draggingHeddles) {
                 //todo either disable this feature or figure out hwo to do a transform but make the paths re-render too (they don't like the tranform)
             }
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
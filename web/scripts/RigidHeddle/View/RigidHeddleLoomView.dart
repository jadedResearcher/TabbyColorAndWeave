import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Colours.dart';

import '../../Fabric.dart';
import '../../FabricRenderer.dart';
import '../Model/Heddle.dart';
import '../Model/Pick.dart';
import '../Model/RigidHeddleLoom.dart';
import '../Model/WarpThread.dart';
import 'HeddleView.dart';
import 'PickView.dart';
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
     Element fabricContainer;
     Element pickContainer;
     int height = 400;
     Element instructions;
     void renderLoom() {
         instructions = new DivElement()..text = "Instructions:"..classes.add("instructions");
         setInstructions();
         parent.append(instructions);
         DivElement container = new DivElement()..classes.add("loom");
         parent.append(container);
        final SvgElement loomElement = SvgElement.tag("svg");
        loomElement.attributes["width"] = "2000";
        loomElement.attributes["height"] = "$height";
        container.append(loomElement);
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
            new ThreadView(warpThread, warpContainer, x, height - 50,pickThread).renderThread();
            x+=20;
        }
        renderControls();
        renderFabric();
        renderPicks();
    }

    void renderControls() {
         DivElement container = new DivElement();

         parent.append(container);
         renderWarpColorControls(container);
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

        TableElement table = new TableElement();
        container.append(table);
         TableRowElement row = new Element.tr();
        table.append(row);
        pickContainer = new TableCellElement()..style.verticalAlign="top";
        row.append(pickContainer);
        fabricContainer = new TableCellElement();
        row.append(fabricContainer);
    }

    void renderWarpColorControls(Element container) {
         //"set thread x to this color and for X ones after"
        DivElement div = new DivElement()..classes.add('colorControls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Set thread ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "and the next";
        NumberInputElement number2 = new NumberInputElement()..value = "${loom.allThreads.length}";
        LabelElement label3 = new LabelElement()..text = "threads to ";
        InputElement color = new InputElement()..type="color";
        ButtonElement button = new ButtonElement()..text = "Set";

        div.append(label);
        div.append(number);
        div.append(label2);
        div.append(number2);
        div.append(label3);
        div.append(color);
        div.append(button);

        button.onClick.listen((Event e) {
            int startIndex = int.parse(number.value);
            int howMany = int.parse(number2.value);
            for(int i = startIndex; i< startIndex + howMany; i++) {
                WarpThread thread = loom.allThreads[i];
                Colour newColor = Colour.fromStyleString(color.value);
                thread.color.setFrom(newColor);
                thread.view.renderThread();
            }
        });

    }

    void renderPicks() {
         pickContainer.text = "";
        HeadingElement heading = new HeadingElement.h2()..text = "Picks";
        pickContainer.append(heading);
        for(Pick pick in loom.picks) {
            new PickView(pick, pickContainer)..render(removePick);
        }

         ButtonElement addButton = new ButtonElement()..text = "Add Pick";
         pickContainer.append(addButton);
         addButton.onClick.listen((Event e) {
             loom.picks.add(loom.picks.last.copy(loom.picks.length));
             renderPicks();
         });

    }

    void removePick(Pick pick) {
         loom.picks.remove(pick);
         renderPicks();
    }


    void renderFabric() {
         if(renderer == null) {
             Fabric fabric = loom.exportLoomToFabric(null);
             renderer = new FabricRenderer(fabric);
             renderer.renderToParent(fabricContainer);
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
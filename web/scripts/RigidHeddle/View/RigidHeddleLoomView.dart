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
    SvgElement warpContainer;
    WarpThread selectedThread;
    Element fabricContainer;
    Element pickContainer;
    Element justPicksContainer;

    int height = 400;
    int threadSeparationDistance = 20;
    Element instructions;
    void renderLoom() {
        instructions = new DivElement()..text = "Instructions:"..classes.add("instructions");
        setInstructions();
        parent.append(instructions);
        DivElement container = new DivElement()..classes.add("loom");
        parent.append(container);
        final SvgElement loomElement = SvgElement.tag("svg");
        loomElement.attributes["width"] = "5000";
        loomElement.attributes["height"] = "$height";
        container.append(loomElement);
        heddleContainer = SvgElement.tag("g")..classes.add("heddles");
        loomElement.append(heddleContainer);
        int y = 125;
        for(Heddle heddle in loom.heddles) {
            new HeddleView(heddle, heddleContainer, y,pickHeddleSection).renderHeddle();
            y+= -125;
        }

        warpContainer = SvgElement.tag("g")..classes.add("warpChains");
        loomElement.append(warpContainer);
        int x = 0;
        for(WarpThread warpThread in loom.allThreads) {
            new ThreadView(warpThread, warpContainer, x, height - 50,pickThread).renderThread();
            x+=threadSeparationDistance;
        }
        renderControls();
        renderPicksAndFabricContainers(parent);
        renderFabric();
        renderPicks();
    }

    void renderControls() {
        DivElement container = new DivElement()..classes.add("controlsHolder");
        parent.append(container);
        renderThreadControls(container);
        renderPickControls(container);
    }

    void renderPickControls(Element container) {
        DivElement pickControls = new DivElement()..classes.add("pickControls")..innerHtml = "<b>Pick Controls</b>";
        container.append(pickControls);
        renderPickColorControls(pickControls);
        renderCopyPickColorPatternControls(pickControls);
        renderCopyPickControls(pickControls);
        renderClearPickControls(pickControls);
    }

    void renderThreadControls(Element container) {
        DivElement threadControls = new DivElement()..classes.add("threadControls")..innerHtml = "<b>Thread Controls</b>";
        container.append(threadControls);
        renderWarpColorControls(threadControls);
        renderCopyWarpColorPatternControls(threadControls);
        renderThreadCountControls(threadControls);
        renderClearThreadControls(threadControls);
    }

    void renderClearThreadControls(DivElement container) {
        ButtonElement clearButton = new ButtonElement()..text = "Clear All Threading";
        container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            for(WarpThread thread in loom.allThreads) {
                thread.heddleSections.clear();
                thread.view.renderThreadPath();
            }
        });
    }

    void renderClearPickControls(DivElement container) {
        ButtonElement clearButton = new ButtonElement()..text = "Clear All But One Picks";
        container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            Pick savedPick = loom.picks.first;
            loom.picks.clear();
            loom.picks.add(savedPick);
            renderPicks();
        });
    }

    void renderPicksAndFabricContainers(Element container) {
        TableElement table = new TableElement();
        container.append(table);
        TableRowElement row = new Element.tr();
        table.append(row);
        pickContainer = new TableCellElement()..style.verticalAlign="top";
        row.append(pickContainer);
        fabricContainer = new TableCellElement()..style.verticalAlign="top";
        row.append(fabricContainer);
    }

    void renderCopyPickControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Copy picks ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "through";
        NumberInputElement number2 = new NumberInputElement()..value = "2";
        LabelElement label3 = new LabelElement()..text = ",";
        NumberInputElement number3 = new NumberInputElement()..value = "3";
        LabelElement label4 = new LabelElement()..text = "times, and then put them at the end.";

        ButtonElement button = new ButtonElement()..text = "Set";
        div.append(label);
        div.append(number);
        div.append(label2);
        div.append(number2);
        div.append(label3);
        div.append(number3);
        div.append(label4);
        div.append(button);

        button.onClick.listen((Event e) {
            int startIndex = int.parse(number.value);
            int endIndex = int.parse(number2.value);
            int numberRepetitions = int.parse(number3.value);
            List<Pick> newPicks = loom.copyPicks(startIndex, endIndex, numberRepetitions);
            for(Pick pick in newPicks) {
                new PickView(pick, justPicksContainer)..render(removePick, renderFabric);
            }
            renderFabric();
        });
    }

    //"repeat color x-y, z times, starting at w" (not possible for threading)
    void renderCopyWarpColorPatternControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Copy thread colors ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "through";
        NumberInputElement number2 = new NumberInputElement()..value = "4";
        LabelElement label3 = new LabelElement()..text = ",";
        NumberInputElement number3 = new NumberInputElement()..value = "10";
        LabelElement label4 = new LabelElement()..text = "times, starting at";
        NumberInputElement number4 = new NumberInputElement()..value = "5";


        ButtonElement button = new ButtonElement()..text = "Set";
        div.append(label);
        div.append(number);
        div.append(label2);
        div.append(number2);
        div.append(label3);
        div.append(number3);
        div.append(label4);
        div.append(number4);
        div.append(button);

        button.onClick.listen((Event e) {
            int startIndex = int.parse(number.value);
            int endIndex = int.parse(number2.value);
            int numberRepetitions = int.parse(number3.value);
            int repsStartIndex = int.parse(number4.value);
            List<WarpThread> dirtyThreads = loom.copyThreadColors(startIndex, endIndex, numberRepetitions, repsStartIndex);
            for(WarpThread thread in dirtyThreads) {
                thread.view.renderThreadSource();
            }
            renderFabric();
        });
    }

    //"repeat color x-y, z times, starting at w" (not possible for threads)
    void renderCopyPickColorPatternControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Copy pick colors ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "through";
        NumberInputElement number2 = new NumberInputElement()..value = "4";
        LabelElement label3 = new LabelElement()..text = ",";
        NumberInputElement number3 = new NumberInputElement()..value = "10";
        LabelElement label4 = new LabelElement()..text = "times, starting at";
        NumberInputElement number4 = new NumberInputElement()..value = "5";


        ButtonElement button = new ButtonElement()..text = "Set";
        div.append(label);
        div.append(number);
        div.append(label2);
        div.append(number2);
        div.append(label3);
        div.append(number3);
        div.append(label4);
        div.append(number4);
        div.append(button);

        button.onClick.listen((Event e) {
            int startIndex = int.parse(number.value);
            int endIndex = int.parse(number2.value);
            int numberRepetitions = int.parse(number3.value);
            int repsStartIndex = int.parse(number4.value);
            List<Pick> dirtyPicks = loom.copyPickColors(startIndex, endIndex, numberRepetitions, repsStartIndex);
            for(Pick pick in dirtyPicks) {
                pick.view.syncColor();
            }
            renderFabric();
        });
    }

    void renderWarpColorControls(Element container) {
        //"set thread x to this color and for X ones after"
        DivElement div = new DivElement()..classes.add('controls');
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
            for(int i = startIndex; i<= startIndex + howMany; i++) {
                if(i < loom.allThreads.length) {
                    WarpThread thread = loom.allThreads[i];
                    Colour newColor = Colour.fromStyleString(color.value);
                    thread.color.setFrom(newColor);
                    thread.view.renderThreadSource();
                }
            }
            renderFabric();
        });
    }

    void renderPickColorControls(Element container) {
        //"set thread x to this color and for X ones after"
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Set pick ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "and the next";
        NumberInputElement number2 = new NumberInputElement()..value = "${loom.picks.length}";
        LabelElement label3 = new LabelElement()..text = "picks to ";
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
            for(int i = startIndex; i<= startIndex + howMany; i++) {
                if(i < loom.picks.length) {
                    Pick pick = loom.picks[i];
                    Colour newColor = Colour.fromStyleString(color.value);
                    pick.color.setFrom(newColor);
                    pick.view.syncColor();
                }
            }
            renderFabric();
        });


    }

    void renderThreadCountControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "# of threads";
        NumberInputElement number = new NumberInputElement()..value="4";
        ButtonElement button = new ButtonElement()..text = "Set";
        div.append(label);
        div.append(number);
        div.append(button);
        button.onClick.listen((Event e) {
            int threadCount = int.parse(number.value);
            int oldCount = loom.allThreads.length;
            int newThreadCount = threadCount -oldCount;
            if(newThreadCount > 0) { //add
                Colour color;
                int lastX = 0;
                if(loom.allThreads.isNotEmpty) {
                    WarpThread lastThread = loom.allThreads.last;
                    color = new Colour.from(lastThread.color);
                    lastX = lastThread.view.x;
                }else {
                    color = new Colour(200,0,0);
                }
                for(int i = 0; i< newThreadCount; i++) {
                    WarpThread warpThread = new WarpThread( color,i+oldCount);
                    lastX += threadSeparationDistance;
                    loom.allThreads.add(warpThread);
                    new ThreadView(warpThread, warpContainer, lastX, height - 50,pickThread).renderThread();
                }
            }else if (newThreadCount < 0) { //remove
                newThreadCount = newThreadCount.abs();
                int length = loom.allThreads.length;
                List<WarpThread> toRemove = new List<WarpThread>();
                for(int i = 1; i<= newThreadCount; i++) {
                    toRemove.add(loom.allThreads[length - i]);
                }
                for(WarpThread thread in toRemove){
                    thread.view.teardown();
                    loom.allThreads.remove(thread);
                }

            }
            renderFabric();
        });
    }

    void renderPicks() {
        pickContainer.text = "";
        HeadingElement heading = new HeadingElement.h2()..text = "Picks";
        pickContainer.append(heading);
        //so the pattern adder can not bury the button
        justPicksContainer = new DivElement();
        pickContainer.append(justPicksContainer);
        for(Pick pick in loom.picks) {
            new PickView(pick, justPicksContainer)..render(removePick, renderFabric);
        }

        ButtonElement addButton = new ButtonElement()..text = "Add Pick";
        pickContainer.append(addButton);
        addButton.onClick.listen((Event e) {
            loom.picks.add(loom.picks.last.copy(loom.picks.length));
            renderPicks();
            renderFabric();
        });

    }

    void removePick(Pick pick) {
        if(loom.picks.length > 1) {
            loom.picks.remove(pick);
            renderFabric();
            renderPicks();
        }else {
            window.alert("Cannot remove last pick!");
        }
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
            renderFabric();
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
            renderFabric();
        }
    }



    void handleMove(int newX, int newY) {
        heddlesX = newX;
        heddlesY = newY;
        heddleContainer.attributes["transform"] = "translate($newX,$newY)";
    }
}
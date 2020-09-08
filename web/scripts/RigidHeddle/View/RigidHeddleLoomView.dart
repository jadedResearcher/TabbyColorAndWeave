import 'dart:convert';
import 'dart:html';
import 'dart:svg';

import 'package:CommonLib/Colours.dart';
import 'package:ImageLib/Encoding.dart';
import 'package:LoaderLib/Loader.dart';

import '../../Fabric.dart';
import '../../FabricRenderer.dart';
import '../../WarpObject.dart';
import '../Model/Heddle.dart';
import '../Model/Pick.dart';
import '../Model/RigidHeddleLoom.dart';
import '../Model/WarpThread.dart';
import 'HeddleView.dart';
import 'PickView.dart';
import 'WarpThreadView.dart';
class RigidHeddleLoomView {
    Element me;
    Element parent;
    CanvasElement guide;
    DivElement archiveUploaderHolder;
    RigidHeddleLoom loom;
    Element archiveSaveButton;
    RigidHeddleLoomView(this.loom);
    Element archiveControls;
    int heddlesX;
    int heddlesY;
    FabricRenderer renderer;
    SvgElement heddleContainer;
    bool draggingHeddles = false;
    SvgElement warpContainer;
    static String fileKey = "COLORANDWEAVE/rigidHeddle.txt";

    WarpThread selectedThread;
    Element fabricContainer;
    Element pickContainer;
    Element justPicksContainer;

    int height = 400;
    int threadSeparationDistance = 20;
    Element instructions;
    void renderLoom(Element tmp) {
        if(tmp != null) {
            parent = tmp;
        }else if(me != null) {
            me.remove();
        }
        me = new DivElement();
        parent.append(me);

        DivElement container = new DivElement()..classes.add("loom");
        me.append(container);
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
        instructions = new DivElement()..text = "Instructions:"..classes.add("instructions");
        me.append(instructions);
        setInstructions();

        int x = 0;
        for(WarpThread warpThread in loom.allThreads) {
            new ThreadView(warpThread, warpContainer, x, height - 50,pickThread).renderThread();
            x+=threadSeparationDistance;
        }

        renderPicksAndFabricContainers(me);
        renderFabric();
        renderPicks();
        renderControls();
    }

    void handleLoadingFromImage(Element doop) {
        if (archiveUploaderHolder == null) {
            archiveUploaderHolder = new DivElement()..classes.add("archiveUploaderHolder");
            doop.append(archiveUploaderHolder);
            Element uploadElement = FileFormat.loadButton(
                ArchivePng.format, syncLoomToImage,
                caption: "Load RigidHeddleSim Setup From Image");
            doop.append(uploadElement);
        }
    }

    void handleLoadingColorFromImage(Element doop) {
        Element uploadElement = FileFormat.loadButton(
            ArchivePng.format, syncColorToImage,
            caption: "Load Color Palette From Image");
        doop.append(uploadElement);
    }

    void handleLoadingPicksFromImage(Element doop) {
        Element uploadElement = FileFormat.loadButton(
            ArchivePng.format, syncPicksToImage,
            caption: "Load Picks From Image");
        doop.append(uploadElement);
    }

    void syncLoomToImage(ArchivePng png, String fileName) async {
        String rawJSON = await png.getFile(fileKey);
        loadFromSerialization(jsonDecode(rawJSON));
        renderer = null;
        archiveUploaderHolder = null;
        renderLoom(null);
    }

    void syncColorToImage(ArchivePng png, String fileName) async {
        String rawJSON = await png.getFile(fileKey);
        loadColorFromSerialization(jsonDecode(rawJSON));
        renderer = null;
        archiveUploaderHolder = null;
        renderLoom(null);
    }

    void syncPicksToImage(ArchivePng png, String fileName) async {
        String rawJSON = await png.getFile(fileKey);
        loadPicksFromSerialization(jsonDecode(rawJSON));
        renderer = null;
        archiveUploaderHolder = null;
        renderLoom(null);
    }

    void renderControls() {
        DivElement container = new DivElement()..classes.add("controlsHolder");
        me.append(container);
        renderThreadControls(container);
        renderPickControls(container);
        renderColorReplaceControls(container);
        renderArchiveControls(container);

    }

    void renderArchiveControls(Element container) {
        archiveControls = new DivElement()..classes.add("archiveControls")..innerHtml = "<b>Archive Controls</b>";
        container.append(archiveControls);
        makeDownloadImage();
        handleLoadingFromImage(archiveControls);
        handleLoadingColorFromImage(archiveControls);
        handleLoadingPicksFromImage(archiveControls);
    }

    void makeDownloadImage() async {
        if(renderer == null || renderer.canvas == null) return;
        if (archiveSaveButton != null) {
            archiveSaveButton.remove();
            archiveSaveButton = null;
        }


        ArchivePng png = new ArchivePng.fromCanvas(renderer.canvas);
        await png.archive.setFile(fileKey, jsonEncode(loom.getSerialization()));

        if (archiveSaveButton != null) {
            archiveSaveButton.remove();
            archiveSaveButton = null;
        }
        archiveSaveButton = FileFormat.saveButton(ArchivePng.format, () async => png,
            filename: () => "RigidHeddleSimulator.png", caption: "Download Pattern");
        archiveControls.append(archiveSaveButton);

    }

    void renderPickControls(Element container) {
        DivElement pickControls = new DivElement()..classes.add("pickControls")..innerHtml = "<b>Pick Controls</b>";
        container.append(pickControls);
        renderPickColorControls(pickControls);
        renderCopyPickColorPatternControls(pickControls);
        renderCopyPickControls(pickControls);
        renderReverseCopyPickControls(pickControls);
        renderBulkPickRemovalControls(pickControls);
        renderSyncPickColorControls(pickControls);
        renderClearPickControls(pickControls);
        renderSyncPickFromThreadControls(pickControls);
        renderPickColorReplaceControls(pickControls);
    }

    void renderThreadControls(Element container) {
        DivElement threadControls = new DivElement()..classes.add("threadControls")..innerHtml = "<b>Warp Controls</b>";
        container.append(threadControls);
        renderWarpColorControls(threadControls);
        renderCopyWarpColorPatternControls(threadControls);
        renderThreadCountControls(threadControls);
        renderThreadColorReplaceControls(threadControls);
        renderSyncThreadColorControls(threadControls);
        renderClearThreadControls(threadControls);
    }

    void renderThreadColorReplaceControls(DivElement container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label1 = new LabelElement()..text = "Change threads of color:";
        InputElement colorPicker1 = new InputElement()..type="color";
        LabelElement label2 = new LabelElement()..text = "to";
        InputElement colorPicker2 = new InputElement()..type="color";
        div.append(label1);
        div.append(colorPicker1);
        div.append(label2);
        div.append(colorPicker2);


        ButtonElement clearButton = new ButtonElement()..text = "Set";
        div.append(clearButton);
        clearButton.onClick.listen((Event e) {
            List<WarpThread> dirtyThreads = loom.replaceThreadColors(Colour.fromStyleString(colorPicker1.value), Colour.fromStyleString(colorPicker2.value));
            for(WarpThread thread in dirtyThreads) {
                thread.view.renderThreadSource();
            }
            renderFabric();
        });
    }

    void renderPickColorReplaceControls(DivElement container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label1 = new LabelElement()..text = "Change picks of color:";
        InputElement colorPicker1 = new InputElement()..type="color";
        LabelElement label2 = new LabelElement()..text = "to";
        InputElement colorPicker2 = new InputElement()..type="color";
        div.append(label1);
        div.append(colorPicker1);
        div.append(label2);
        div.append(colorPicker2);
        ButtonElement clearButton = new ButtonElement()..text = "Set";
        div.append(clearButton);
        clearButton.onClick.listen((Event e) {
            List<Pick> dirtyPicks = loom.replacePickColors(Colour.fromStyleString(colorPicker1.value), Colour.fromStyleString(colorPicker2.value));
            for(Pick pick in dirtyPicks) {
                pick.view.syncColor();
            }
            renderFabric();
        });
    }

    void renderColorReplaceControls(DivElement container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label1 = new LabelElement()..text = "Change everything of color:";
        InputElement colorPicker1 = new InputElement()..type="color";
        LabelElement label2 = new LabelElement()..text = "to";
        InputElement colorPicker2 = new InputElement()..type="color";
        div.append(label1);
        div.append(colorPicker1);
        div.append(label2);
        div.append(colorPicker2);


        ButtonElement clearButton = new ButtonElement()..text = "Set";
        div.append(clearButton);
        clearButton.onClick.listen((Event e) {
            List<Pick> dirtyPicks = loom.replacePickColors(Colour.fromStyleString(colorPicker1.value), Colour.fromStyleString(colorPicker2.value));
            List<WarpThread> dirtyThreads = loom.replaceThreadColors(Colour.fromStyleString(colorPicker1.value), Colour.fromStyleString(colorPicker2.value));

            for(Pick pick in dirtyPicks) {
                pick.view.syncColor();
            }

            for(WarpThread thread in dirtyThreads) {
                thread.view.renderThreadSource();
            }
            renderFabric();
        });
    }

    void renderSyncThreadColorControls(DivElement container) {
        ButtonElement clearButton = new ButtonElement()..text = "Sync Color From Picks";
        container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            int index = 0;
            for(WarpThread thread in loom.allThreads) {
                thread.color.setFrom(loom.picks[index%loom.picks.length].color);
                thread.view.renderThread();
                index ++;
            }
            renderFabric();
        });
    }

    void renderSyncPickFromThreadControls(DivElement container) {
        ButtonElement clearButton = new ButtonElement()..text = "Sync Pick From Warp";
        container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            loom.replicateThreadsInPicksDouble();
            renderPicks();
            renderFabric();
        });
    }

    void renderSyncPickColorControls(DivElement container) {
        ButtonElement clearButton = new ButtonElement()..text = "Sync Color From Warp";
        container.append(clearButton);
        clearButton.onClick.listen((Event e) {
            int index = 0;
            for(Pick pick in loom.picks) {
                pick.color.setFrom(loom.allThreads[index%loom.allThreads.length].color);
                index ++;
            }
            renderPicks();
            renderFabric();
        });
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
        LabelElement label4 = new LabelElement()..text = "times.";

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

    void renderReverseCopyPickControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Reverse And Copy picks ";
        NumberInputElement number = new NumberInputElement()..value="0";
        LabelElement label2 = new LabelElement()..text = "through";
        NumberInputElement number2 = new NumberInputElement()..value = "2";
        LabelElement label3 = new LabelElement()..text = ",";
        NumberInputElement number3 = new NumberInputElement()..value = "3";
        LabelElement label4 = new LabelElement()..text = "times.";

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
            List<Pick> newPicks = loom.copyPicksReverse(startIndex, endIndex, numberRepetitions);
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

    void renderBulkPickRemovalControls(Element container) {
        DivElement div = new DivElement()..classes.add('controls');
        container.append(div);
        LabelElement label = new LabelElement()..text = "Remove any picks past pick:";
        NumberInputElement number = new NumberInputElement()..value="3";
        ButtonElement button = new ButtonElement()..text = "Set";
        div.append(label);
        div.append(number);
        div.append(button);
        button.onClick.listen((Event e) {
            int pickCount = int.parse(number.value);
            loom.picks.removeRange(pickCount, loom.picks.length);
            renderPicks();
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
                    WarpThread warpThread = new WarpThread(Colour.from(color),i+oldCount);
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
        int index = 0;
        for(Pick pick in loom.picks) {
            pick.index = index;
            new PickView(pick, justPicksContainer)..render(removePick, renderFabric);
            index ++;
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

    void  loadFromSerialization(Map<String, dynamic > serialization) {
        loom.loadFromSerialization(serialization);
    }

    void  loadColorFromSerialization(Map<String, dynamic > serialization) {
        loom.loadColorFromSerialization(serialization);
    }

    void  loadPicksFromSerialization(Map<String, dynamic > serialization) {
        loom.loadPicksFromSerialization(serialization);
    }

    void renderGuide() {
        guide = new CanvasElement(height: WarpObject.WIDTH*3, width: RigidHeddleLoom.WIDTH);
        guide.context2D.fillRect(guide.width,guide.height,0,0);
        int x = renderer.warpBuffer;
        for(WarpThread thread in loom.allThreads) {
            thread.view.renderThreadGuide(guide, x);
            x+= WarpObject.WIDTH;
        }
    }


    void renderFabric() {
        if(renderer == null) {
            Fabric fabric = loom.exportLoomToFabric(null);
            renderer = new FabricRenderer(fabric);
            renderGuide();
            renderer.renderToParent(fabricContainer,guide);
        }else {
            loom.exportLoomToFabric(renderer.fabric);
            renderGuide();
            renderer.update(guide);
        }
        CanvasElement tmp = renderer.canvas;
        tmp.context2D.font = "bold 24px nunito";
        tmp.context2D.fillStyle = "#ffffff";
        tmp.context2D.fillText("RigidHeddleSim", tmp.width-200, tmp.height-2);
        tmp.context2D.fillStyle = "#000000";
        tmp.context2D.fillText("RigidHeddleSim", tmp.width-203, tmp.height-2);
        makeDownloadImage();
    }

    void setInstructions() {
        if(instructions == null) return;
        if(selectedThread != null) {
            instructions.text = "Instructions: Now that a thread is selected, you can click a hole or slot in any heddle to thread it. You can click multiple holes or slots.   You can click the thread again (or a new thread) to deselect it.   ";
        }else {
            instructions.text = "Instructions: Click a colored thread box above to select it and begin Threading Mode. (You only need to thread/pick one repetition of your pattern, it will repeat.)";
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
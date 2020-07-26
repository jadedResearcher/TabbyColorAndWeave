import 'dart:html';

import 'package:CommonLib/Colours.dart';
import 'package:LoaderLib/Loader.dart';
import "dart:math" as Math;
import 'Util.dart';
import 'WarpObject.dart';
import 'WeftObject.dart';
import "package:ImageLib/Encoding.dart";
//todo toggles for balanced wrave, slightly warp facing snd slightly weft facinh
class Fabric {
    int height;
    int width;
    Element control;
    Element stats;
    Element warpPatternLength;
    Element weftPatternLength;
    Element colorStats;
    //Element warpLengthDiv;
    //Element weftLengthDiv;
    TextAreaElement warpText;
    TextAreaElement weftText;
    Element output;
    DivElement archiveUploaderHolder;
    Element archiveSaveButton;
    List<InputElement> colorPickers = <InputElement>[];
    static String fileKeyWarp = "COLORANDWEAVE/warp.txt";
    static String fileKeyWeft = "COLORANDWEAVE/weft.txt";
    static String fileKeyColors = "COLORANDWEAVE/colors.txt";

    CanvasElement canvas;
    CanvasElement warpingGuideCanvas;
    //String warpPatternStart = "1,0,1,0,1,0,0,1,0,1,0";
   // String weftPatternStart = "1,0,1,0,1,0,0,1,0,1,0";
    String warpPatternStart = "1,1,0,0";
    String weftPatternStart = "1,1,0,0";

    Element parent;
    List<WarpObject> warp = new List<WarpObject>();
    List<WeftObject> weft = new List<WeftObject>();
    List<Colour> colors = new List<Colour>();

    Fabric(this.height, this.width) {
        canvas = new CanvasElement(width: width, height: height)..classes.add("fabric");
        warpingGuideCanvas = new CanvasElement(width: width, height: 200)..classes.add("fabric");

    }

    void initColors() {
        colors.add(new Colour(200,200,200));
        colors.add(new Colour(50,50,50));
        colors.add(new Colour(181,44,44));
        colors.add(new Colour(131,2,2));
        colors.add(new Colour(31,132,31));
        colors.add(new Colour(0,0,0));
        colors.add(new Colour(255,255,255));
        colors.add(new Colour(255,204,204));
        colors.add(new Colour(255,138,200));
        colors.add(new Colour(250,133,0));
        colors.add(new Colour(245,210,112));
        colors.add(new Colour(212,105,245));
    }

    //TODO maybe buffer this
    void renderToParent(Element parent, Element controls, Element stats, Element warpingGuide) {
        output = parent;
        control = controls;
        this.stats = stats;
        parent.append(canvas);
        warpingGuide.append(warpingGuideCanvas);
        initColors();
        for(int i = WarpObject.WIDTH*4; i< width-WarpObject.WIDTH*4; i+= WarpObject.WIDTH) {
            warp.add(new WarpObject(colors[0], i, i%2==0));
        }

        for(int i = WeftObject.WIDTH*6; i< height-WeftObject.WIDTH*4; i+= WeftObject.WIDTH) {
            weft.add(new WeftObject(colors[0], i, i%2==0));
        }
        syncPatternToWarp(warpPatternStart);
        syncPatternToWeft(weftPatternStart);
        /* not actually possible
        warpLengthDiv = new DivElement()..text = "Warp Pattern Length ${exportWarpPattern().split(",").length}";
        output.append(warpLengthDiv);
        weftLengthDiv = new DivElement()..text = "Weft Pattern Length ${exportWeftPattern().split(",").length}";
        output.append(weftLengthDiv);
        */
        renderWarpTextArea(controls);
        renderWeftTextArea(controls);
        renderColorPickers(controls);
        _renderFabric();
    }

    void handleStats() {
        initStatHolders();
        String warpPatternFull = exportWarpPattern();
        String weftPatternFull = exportWeftPattern();

        String warpPatternNoRep = Util.getTiniestWeavingPattern(warpPatternFull);
        String weftPatternNoRep = Util.getTiniestWeavingPattern(weftPatternFull);

        warpPatternLength.text = "Warp Pattern Length: ${Util.getTiniestWeavingPatternLength(warpPatternFull)} (${warpPatternNoRep})";
        weftPatternLength.text = "Weft Pattern Length: ${Util.getTiniestWeavingPatternLength(weftPatternFull)} (${weftPatternNoRep}";
        colorStats.setInnerHtml("<h2>Colors used per Repetition:</h2>");
        for(Colour c in colors) {
            DivElement container = new DivElement()..classes.add("colorStatContainer");
            colorStats.append(container);
            DivElement colorBox = new DivElement()..classes.add("colorBox")..style.backgroundColor=c.toStyleString();
            container.append(colorBox);
            DivElement stat = new DivElement()..text = ": ${Util.numTimesIntIsInPattern(warpPatternNoRep, colors.indexOf(c))} warp ends, ${Util.numTimesIntIsInPattern(weftPatternNoRep, colors.indexOf(c))} weft ends"..classes.add("colorStat");
            container.append(stat);
        }
    }


    void initStatHolders() {
        print("hello world???");
       if(warpPatternLength == null) {
           stats.setInnerHtml("<h1>Stats:</h1>");
          warpPatternLength = new DivElement()..classes.add("patternLength");
          stats.append(warpPatternLength);
      }

      if(weftPatternLength == null) {
          weftPatternLength = new DivElement()..classes.add("patternLength");
          stats.append(weftPatternLength);
      }

      if(colorStats == null) {
          colorStats = new DivElement()..classes.add("colorStats");
          stats.append(colorStats);
      }
    }



    void _renderFabric() {
        handleStats();
        warp.forEach((WarpObject w) => w.renderSelf(canvas));
        weft.forEach((WeftObject w) => w.renderSelf(canvas));
        renderWarpingGuide();
        makeDownloadImage(control);

    }

    void renderWarpingGuide() {
        int length = Util.getTiniestWeavingPatternLength(exportWarpPattern());
        CanvasElement buffer = new CanvasElement(width: width, height: 200);
        length = Math.min(length*4, warp.length);
        for(int i = 0; i<length; i++) {
            warp[i].renderSelf(buffer);
        }

        warpingGuideCanvas.context2D.clearRect(0,0,warpingGuideCanvas.width, warpingGuideCanvas.height);
        warpingGuideCanvas.context2D.drawImageScaled(buffer, -100,0,warpingGuideCanvas.width*5, warpingGuideCanvas.height*5);

    }

    void renderColorPickers(Element parent) {
        for(Colour color in colors) {
            DivElement div = new DivElement()..classes.add("color-parent");
            parent.append(div);
            LabelElement label = new LabelElement()..text = "Color ${colors.indexOf(color)}"..classes.add("color-label");
            div.append(label);
            InputElement input = new InputElement()..type = "color";
            colorPickers.add(input);
            input.value = color.toStyleString();
            div.append(input);
            input.onInput.listen((Event e) {
                Colour newColor = Colour.fromStyleString(input.value);
                color.setFrom(newColor);
                _renderFabric();
            });
        }
    }

    void renderWarpTextArea(Element parent) {
        DivElement element = new DivElement();
        parent.append(element);
        //TODO find a way to compress it to the smallest unrepeatable area
        LabelElement label = new LabelElement()..text = "Warp Pattern";
        element.append(label);
        warpText = new TextAreaElement()..text = warpPatternStart;
        warpText.onInput.listen((Event e) {
            syncPatternToWarp(warpText.value);
        });

        element.append(warpText);
    }

    void renderWeftTextArea(Element parent) {
        DivElement element = new DivElement();
        parent.append(element);
        LabelElement label = new LabelElement()..text = "Weft Pattern";
        element.append(label);
        weftText = new TextAreaElement()..text = weftPatternStart;
        weftText.onInput.listen((Event e) {
            syncPatternToWeft(weftText.value);
        });
        element.append(weftText);

    }

    void handleLoadingFromImage() {
        if(archiveUploaderHolder == null) {
            archiveUploaderHolder = new DivElement();
            control.append(archiveUploaderHolder);
            DivElement instructions = new DivElement()..setInnerHtml("You can save your pattern to a thumbnail file you can download, then upload it here to edit." )..style.marginBottom="30px";;
            archiveUploaderHolder.append(instructions);
            Element uploadElement = FileFormat.loadButton(ArchivePng.format, syncFabricToImage,caption: "Load Colour and Weave From Image");
            control.append(uploadElement);
        }

    }

    void syncFabricToImage(ArchivePng png, String fileName) async {
        print("JR here, trying to sync from $fileName");
        String warpPattern = await png.getFile(fileKeyWarp);
        String weftPattern = await png.getFile(fileKeyWeft);
        String colorPattern = await png.getFile(fileKeyColors);
        print("I got three patterns: $warpPattern, $weftPattern, $colorPattern");
        warpText.value =warpPattern;
        weftText.value =weftPattern;
        syncPatternToWarp(warpPattern);
        syncPatternToWeft(weftPattern);
        syncPatternToColors(colorPattern);


    }

    void makeDownloadImage(Element parent) async{
        if(archiveSaveButton != null) {
            archiveSaveButton.remove();
            archiveSaveButton = null;
        }
        int thumbnail_width = 500;

        CanvasElement thumbnail = new CanvasElement(width: thumbnail_width, height: thumbnail_width);
        thumbnail.context2D.drawImageScaled(canvas,0,0,thumbnail_width,thumbnail_width);
        ArchivePng png = new ArchivePng.fromCanvas(thumbnail);
        await png.archive.setFile(fileKeyWarp, exportWarpPattern());
        await png.archive.setFile(fileKeyWeft, exportWeftPattern());
        await png.archive.setFile(fileKeyColors, exportColorPattern());

        if(archiveSaveButton != null) {
            archiveSaveButton.remove();
            archiveSaveButton = null;
        }
        archiveSaveButton = FileFormat.saveButton(ArchivePng.format, ()=> png, filename: ()=>"JRColorWeaveMaker.png", caption: "Download Pattern");

        parent.append(archiveSaveButton);
        handleLoadingFromImage();

    }


    String exportWarpPattern() {
        List<int> pattern = <int>[];
        for(WarpObject w in warp) {
            pattern.add(colors.indexOf(w.color));
        }
        return pattern.join(",");
    }

    String exportWeftPattern() {
        List<int> pattern = <int>[];
        for(WeftObject w in weft) {
            pattern.add(colors.indexOf(w.color));
        }
        return pattern.join(",");
    }

    String exportColorPattern() {
        List<String> pattern = <String>[];
        for(Colour color in colors) {
            pattern.add(color.toStyleString());
        }
        return pattern.join(",");
    }

    void syncPatternToWarp(String pattern) {
        if(warpText != null) warpText.value = pattern;
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        print("parsed pattern is $parsedPattern");
        int index = 0;
        for(WarpObject w in warp) {
            //mod makes it so that it'll just repeat the pattern over and over
            w.color = colors[parsedPattern[index % parsedPattern.length]];
            index++;
        }
        _renderFabric();

    }

    void syncPatternToColors(String pattern) {
        List<String> parsedPattern = pattern.split(",");
        print("parsed pattern is $parsedPattern");
        int index = 0;
        for(String c in parsedPattern) {
            Colour color = new Colour.fromStyleString(c);
            colors[index].setFrom(color);
            colorPickers[index].value = c;

            index ++;
        }
        _renderFabric();
    }

    void syncPatternToWeft(String pattern) {
        if(weftText != null) weftText.value = pattern;
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        print("parsed pattern is $parsedPattern");
        int index = 0;
        for(WeftObject w in weft) {
            //mod makes it so that it'll just repeat the pattern over and over
            w.color = colors[parsedPattern[index % parsedPattern.length]];
            index++;
        }
        _renderFabric();

    }

    void debug(){
        canvas.context2D.setFillColorRgb(255,0,0);
        canvas.context2D.fillRect(0,0,width,height);
    }
}
import 'dart:html';

import 'package:CommonLib/Colours.dart';
import 'package:LoaderLib/Loader.dart';
import "dart:math" as Math;
import 'FabricRenderer.dart';
import 'Util.dart';
import 'WarpObject.dart';
import 'WeftObject.dart';
import "package:ImageLib/Encoding.dart";
import 'Fabric.dart';

/*
    Takes care of rendering controls for the v1 WeavingSim, and has an embedded fabricRenderer (which can be used stand alone)
 */
class FabricView {
  FabricRenderer fabricRenderer;
  Element control;
  Element stats;
  InputElement warpLength;

  Element warpPatternLength;
  Element weftPatternLength;
  Element colorStats;

  //Element warpLengthDiv;
  //Element weftLengthDiv;
  TextAreaElement warpText;
  Element parent;
  TextAreaElement weftText;
  RangeInputElement weftSizeElement;
  LabelElement weftSizeLabel;
  TextAreaElement pickupText;
  Element output;
  DivElement archiveUploaderHolder;
  Element archiveSaveButton;
  List<InputElement> colorPickers = <InputElement>[];
  Fabric fabric;

  String get warpPatternStart => fabric.warpPatternStart;

  String get weftPatternStart => fabric.weftPatternStart;

  String get pickupPatternStart => fabric.pickupPatternStart;

  int get width => fabric.width;

  int get height => fabric.height;

  int get warpBuffer => fabric.warpBuffer;

  int get weftBuffer => fabric.weftBuffer;

  List<Colour> get colors => fabric.colors;

  List<WarpObject> get warp => fabric.warp;

  List<WeftObject> get weft => fabric.weft;

  static String fileKeyWarp = "COLORANDWEAVE/warp.txt";
  static String fileKeyWeft = "COLORANDWEAVE/weft.txt";
  static String fileKeyColors = "COLORANDWEAVE/colors.txt";
  static String fileKeyWidth = "COLORANDWEAVE/width.txt";
  static String fileKeyPickup = "COLORANDWEAVE/pickup.txt";
  static String fileKeyWeftWidth = "COLORANDWEAVE/weftWidth.txt";

  CanvasElement warpingGuideCanvas;

  FabricView(Fabric this.fabric) {
    fabricRenderer = new FabricRenderer(fabric);
    warpingGuideCanvas = new CanvasElement(width: width, height: 200)
      ..classes.add("fabric");
  }

  //TODO maybe buffer this
  void renderToParent(
      Element parent, Element controls, Element stats, Element warpingGuide) {
    output = parent;
    control = controls;
    this.stats = stats;
    fabricRenderer.renderToParent(parent);
    renderWarpConfig();
    renderWarpTextArea(controls);
    renderWeftTextArea(controls);
    renderPickupTextArea(controls);
    renderColorPickers(controls);
    _renderFabric();
  }

  void renderWarpConfig() {
    DivElement div = new DivElement();
    control.append(div);
    LabelElement label = new LabelElement()..text = "# Ends in Warp:";
    div.append(label);
    warpLength = new InputElement()..type = "number";
    warpLength.value = "${warp.length}";
    div.append(warpLength);
    warpLength.onChange.listen((Event e) {
      fabricRenderer.numEndsToRender = int.parse(warpLength.value);
      _renderFabric();
    });
  }

  void handleStats() {
    initStatHolders();
    String warpPatternFull = fabric.exportWarpPattern();
    String weftPatternFull = fabric.exportWeftPattern();

    String warpPatternNoRep = Util.getTiniestWeavingPattern(warpPatternFull);
    String weftPatternNoRep = Util.getTiniestWeavingPattern(weftPatternFull);

    warpPatternLength.text =
        "Warp Pattern Length: ${Util.getTiniestWeavingPatternLength(warpPatternFull)} (${warpPatternNoRep})";
    weftPatternLength.text =
        "Weft Pattern Length: ${Util.getTiniestWeavingPatternLength(weftPatternFull)} (${weftPatternNoRep}";
    colorStats.setInnerHtml("<h2>Colors used per Repetition:</h2>");
    for (Colour c in colors) {
      DivElement container = new DivElement()
        ..classes.add("colorStatContainer");
      colorStats.append(container);
      DivElement colorBox = new DivElement()
        ..classes.add("colorBox")
        ..style.backgroundColor = c.toStyleString();
      container.append(colorBox);
      DivElement stat = new DivElement()
        ..text =
            ": ${Util.numTimesIntIsInPattern(warpPatternNoRep, colors.indexOf(c))} warp ends, ${Util.numTimesIntIsInPattern(weftPatternNoRep, colors.indexOf(c))} weft ends"
        ..classes.add("colorStat");
      container.append(stat);
    }
  }

  void initStatHolders() {
    print("hello world???");
    if (warpPatternLength == null) {
      stats.setInnerHtml("<h1>Stats:</h1>");
      warpPatternLength = new DivElement()..classes.add("patternLength");
      stats.append(warpPatternLength);
    }

    if (weftPatternLength == null) {
      weftPatternLength = new DivElement()..classes.add("patternLength");
      stats.append(weftPatternLength);
    }

    if (colorStats == null) {
      colorStats = new DivElement()..classes.add("colorStats");
      stats.append(colorStats);
    }
  }

  void renderWarpingGuide() {
    int length =
        Util.getTiniestWeavingPatternLength(fabric.exportWarpPattern());
    CanvasElement buffer = new CanvasElement(width: width, height: 200);
    length = Math.min(length * 10, warp.length);
    for (int i = 0; i < length; i++) {
      warp[i].renderSelf(buffer);
    }

    warpingGuideCanvas.context2D
        .clearRect(0, 0, warpingGuideCanvas.width, warpingGuideCanvas.height);
    warpingGuideCanvas.context2D.drawImageScaled(buffer, -100, 0,
        warpingGuideCanvas.width * 5, warpingGuideCanvas.height * 5);
  }

  void renderColorPickers(Element parent) {
    for (Colour color in colors) {
      DivElement div = new DivElement()..classes.add("color-parent");
      parent.append(div);
      LabelElement label = new LabelElement()
        ..text = "Color ${colors.indexOf(color)}"
        ..classes.add("color-label");
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

  void renderPickupTextArea(Element parent) {
    DivElement element = new DivElement();
    parent.append(element);
    LabelElement label = new LabelElement()
      ..text =
          "Weaving Pattern 0 is 'weft goes under warp', 1 is 'weft goes over warp' (default value is plain weave)";
    element.append(label);
    pickupText = new TextAreaElement()..text = pickupPatternStart;
    pickupText.rows = 10;
    pickupText.onInput.listen((Event e) {
      syncPickupToWeft(pickupText.value);
    });

    element.append(pickupText);
  }

  void renderWarpTextArea(Element parent) {
    DivElement element = new DivElement();
    parent.append(element);
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
    weftSizeLabel = new LabelElement()
      ..text = "Weft Size Compared To Warp: 100%";
    weftSizeElement = new InputElement()
      ..type = "range"
      ..min = "20"
      ..max = "300"
      ..value = "${100 * WeftObject.WIDTH / WarpObject.WIDTH}";
    weftSizeElement.step = "20";
    element.append(weftSizeLabel);
    element.append(weftSizeElement);
    syncWeftSizeLabel();
    weftSizeElement.onChange.listen((Event e) {
      print(
          "JR NOTE:WarpObject.WIDTH is ${WarpObject.WIDTH} and value is ${double.parse(weftSizeElement.value) / 100} so weft should become ${(WarpObject.WIDTH * double.parse(weftSizeElement.value)).round()}  ");
      WeftObject.WIDTH =
          (WarpObject.WIDTH * double.parse(weftSizeElement.value) / 100)
              .round();
      syncWeftSizeLabel();
      syncPatternToWeft(weftText.value);
    });
  }

  void syncPatternToWarp(String pattern) {
    if (warpText != null) warpText.value = pattern;
    fabricRenderer.syncPatternToWarp(pattern, false);
    _renderFabric();
  }

  void syncPatternToColors(String pattern) {
    List<String> parsedPattern = pattern.split(",");
    fabricRenderer.syncPatternToColors(pattern, false);
    int index = 0;
    for (String c in parsedPattern) {
      colorPickers[index].value = c;
      index++;
    }
    _renderFabric();
  }

  void syncPickupToWeft(String pattern) {
    if (pickupText != null) pickupText.value = pattern;
    fabricRenderer.syncPickupToWeft(pattern, false);
    _renderFabric();
  }

  void syncPatternToWeft(String pattern) {
    if (weftText != null) weftText.value = pattern;
    fabricRenderer.syncPatternToWeft(pattern, false);
    _renderFabric();
  }

  void syncFabricToImage(ArchivePng png, String fileName) async {
    print("JR here, trying to sync from $fileName");
    String warpPattern = await png.getFile(fileKeyWarp);
    String weftPattern = await png.getFile(fileKeyWeft);
    String colorPattern = await png.getFile(fileKeyColors);
    String number = await png.getFile(fileKeyWidth);
    if (number != null) fabricRenderer.numEndsToRender = int.parse(number);
    String val = await png.getFile(fileKeyPickup);
    if (val != null && val.isNotEmpty) {
      pickupText.value = val;
    } else {
      pickupText.value = pickupPatternStart;
    }

    String weftWidth = await png.getFile(fileKeyWeftWidth);
    if (weftWidth != null && weftWidth.isNotEmpty) {
      WeftObject.WIDTH = int.parse(weftWidth);
    } else {
      WeftObject.WIDTH = WarpObject.WIDTH;
    }

    print("I got three patterns: $warpPattern, $weftPattern, $colorPattern");
    warpText.value = warpPattern;
    weftText.value = weftPattern;
    syncPatternToWarp(warpPattern);
    syncPatternToWeft(weftPattern);
    syncPickupToWeft(pickupText.value);
    syncPatternToColors(colorPattern);
    syncWeftSizeLabel();
  }

  void makeDownloadImage(Element parent) async {
    if (archiveSaveButton != null) {
      archiveSaveButton.remove();
      archiveSaveButton = null;
    }
    int thumbnail_width = 500;

    CanvasElement thumbnail =
        new CanvasElement(width: thumbnail_width, height: thumbnail_width);
    thumbnail.context2D.drawImageScaled(
        fabricRenderer.canvas, 0, 0, thumbnail_width, thumbnail_width);
    ArchivePng png = new ArchivePng.fromCanvas(thumbnail);
    await png.archive.setFile(fileKeyWarp, fabric.exportWarpPattern());
    await png.archive.setFile(fileKeyWeft, fabric.exportWeftPattern());
    await png.archive.setFile(fileKeyColors, fabric.exportColorPattern());
    await png.archive
        .setFile(fileKeyWidth, "${fabricRenderer.numEndsToRender}");
    await png.archive.setFile(fileKeyPickup, "${pickupText.value}");
    await png.archive.setFile(fileKeyWeftWidth, "${WeftObject.WIDTH}");

    if (archiveSaveButton != null) {
      archiveSaveButton.remove();
      archiveSaveButton = null;
    }
    archiveSaveButton = FileFormat.saveButton(ArchivePng.format, () async => png,
        filename: () => "JRColorWeaveMaker.png", caption: "Download Pattern");

    parent.append(archiveSaveButton);
    handleLoadingFromImage();
  }

  void syncWeftSizeLabel() {
    weftSizeLabel.text =
        "Weft Size Compared To Warp: ${(WeftObject.WIDTH / WarpObject.WIDTH) * 100}%";
  }

  void handleLoadingFromImage() {
    if (archiveUploaderHolder == null) {
      archiveUploaderHolder = new DivElement();
      control.append(archiveUploaderHolder);
      DivElement instructions = new DivElement()
        ..setInnerHtml(
            "You can save your pattern to a thumbnail file you can download, then upload it here to edit.")
        ..style.marginBottom = "30px";
      ;
      archiveUploaderHolder.append(instructions);
      Element uploadElement = FileFormat.loadButton(
          ArchivePng.format, syncFabricToImage,
          caption: "Load Colour and Weave From Image");
      control.append(uploadElement);
    }
  }

  void _renderFabric() {
    handleStats();
    fabricRenderer.renderFabric();
    renderWarpingGuide();
    makeDownloadImage(control);
  }
}

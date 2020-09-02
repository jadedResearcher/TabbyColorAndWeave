import 'dart:html';

import 'package:CommonLib/Colours.dart';

import 'Fabric.dart';
import 'WarpObject.dart';
import 'WeftObject.dart';

class FabricRenderer {
    Element output;
    Fabric fabric;
    CanvasElement canvas;
    CanvasElement bufferCanvas;
    int get width => fabric.width;
    int get height => fabric.height;
    int get warpBuffer => fabric.warpBuffer;
    int get weftBuffer => fabric.weftBuffer;
    List<Colour> get colors => fabric.colors;
    List<WarpObject> get warp => fabric.warp;
    List<WeftObject> get weft => fabric.weft;
    int numEndsToRender = (12.5*16).floor();


    FabricRenderer(Fabric this.fabric) {
        canvas = new CanvasElement(width: width, height: height)..classes.add("fabric");
        bufferCanvas = new CanvasElement(width: width, height: height);
    }

    void renderToParent(Element parent) {
        output = parent;
        parent.append(canvas);
        fabric.initColors();
        for(int i = warpBuffer; i< width-WarpObject.WIDTH*4; i+= WarpObject.WIDTH) {
            warp.add(new WarpObject(colors[0], i, i%2==0));
        }

        for(int i = weftBuffer; i< height-WeftObject.WIDTH*4; i+= WeftObject.WIDTH) {
            weft.add(new WeftObject(colors[0], i, i%2==0 ? WeftObject.TWOSHAFTdown: WeftObject.TWOSHAFTUP));
        }
        syncPatternToWarp(fabric.warpPatternStart, true);
        syncPatternToWeft(fabric.weftPatternStart, true);
        syncPickupToWeft(fabric.pickupPatternStart, true);
        renderFabric();
    }

    void update() {
        syncPatternToWarp(fabric.warpPatternStart, true);
        syncPatternToWeft(fabric.weftPatternStart, true);
        syncPickupToWeft(fabric.pickupPatternStart, true);
        renderFabric();
    }

    void renderFabric() {
        bufferCanvas.context2D.clearRect(0,0,canvas.width, canvas.height);
        bufferCanvas.width = numEndsToRender*WarpObject.WIDTH+warpBuffer;
        warp.forEach((WarpObject w) => w.renderSelf(bufferCanvas));
        weft.forEach((WeftObject w) => w.renderSelf(bufferCanvas));
        //render only the number of ends we want.
        canvas.context2D.clearRect(0,0,canvas.width, canvas.height);
        canvas.context2D.drawImage(bufferCanvas, 0,0);

    }

    void syncPatternToWarp(String pattern, bool render) {
        if(pattern.isEmpty) return;
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        int index = 0;
        for(WarpObject w in warp) {
            //mod makes it so that it'll just repeat the pattern over and over
            w.color = colors[parsedPattern[index % parsedPattern.length]];
            index++;
        }
        if(render) renderFabric();

    }

    void syncPatternToColors(String pattern, bool render) {
        List<String> parsedPattern = pattern.split(",");
        int index = 0;
        for(String c in parsedPattern) {
            Colour color = new Colour.fromStyleString(c);
            colors[index].setFrom(color);

            index ++;
        }
        if(render) renderFabric();
    }


    void syncPickupToWeft(String pattern, bool render) {
        if(pattern.isEmpty) return;
        List<String> line = pattern.split("\n");
        int lineNum = 0;
        for(WeftObject w in weft) {
            String pattern = line[lineNum % line.length];
            w.pickupPattern = new List<int>.from(pattern.split(",").map((String s) => int.parse(s)));
            lineNum ++;
        }
        if(render) renderFabric();
    }

    void syncPatternToWeft(String pattern, bool render) {
        if(pattern.isEmpty) return;
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        int index = 0;
        for(WeftObject w in weft) {
            //mod makes it so that it'll just repeat the pattern over and over
            w.color = colors[parsedPattern[index % parsedPattern.length]];
            index++;
        }
        if(render) renderFabric();
    }
}
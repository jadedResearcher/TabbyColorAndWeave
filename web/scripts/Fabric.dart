import 'dart:html';

import 'package:CommonLib/Colours.dart';

import 'WarpObject.dart';
import 'WeftObject.dart';

class Fabric {
    int height;
    int width;
    CanvasElement canvas;
    String warpPatternStart = "1,1,0,0";
    String weftPatternStart = "1,1,0,0";
    Element parent;
    List<WarpObject> warp = new List<WarpObject>();
    List<WeftObject> weft = new List<WeftObject>();
    List<Colour> colors = new List<Colour>();

    Fabric(this.height, this.width) {
        canvas = new CanvasElement(width: width, height: height)..classes.add("fabric");
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
    void renderToParent(Element parent, Element controls) {
        parent.append(canvas);
        initColors();
        for(int i = WarpObject.WIDTH*4; i< width-WarpObject.WIDTH*4; i+= WarpObject.WIDTH) {
            warp.add(new WarpObject(colors[0], i));
        }

        for(int i = WeftObject.WIDTH*4; i< width-WeftObject.WIDTH*4; i+= WeftObject.WIDTH) {
            weft.add(new WeftObject(colors[0], i, i%2==0));
        }
        syncPatternToWarp(warpPatternStart);
        syncPatternToWeft(weftPatternStart);
        renderWarpTextArea(controls);
        renderWeftTextArea(controls);
        renderColorPickers(controls);
        _renderFabric();
    }

    void _renderFabric() {
        warp.forEach((WarpObject w) => w.renderSelf(canvas));
        weft.forEach((WeftObject w) => w.renderSelf(canvas));

    }

    void renderColorPickers(Element parent) {
        for(Colour color in colors) {
            DivElement div = new DivElement()..classes.add("color-parent");
            parent.append(div);
            LabelElement label = new LabelElement()..text = "Color ${colors.indexOf(color)}"..classes.add("color-label");
            div.append(label);
            InputElement input = new InputElement()..type = "color";
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
        TextAreaElement area = new TextAreaElement()..text = warpPatternStart;
        area.onInput.listen((Event e) {
            syncPatternToWarp(area.value);
        });
        element.append(area);
    }

    void renderWeftTextArea(Element parent) {
        DivElement element = new DivElement();
        parent.append(element);
        LabelElement label = new LabelElement()..text = "Weft Pattern";
        element.append(label);
        TextAreaElement area = new TextAreaElement()..text = weftPatternStart;
        area.onInput.listen((Event e) {
            syncPatternToWeft(area.value);
        });
        element.append(area);

    }

    void syncPatternToWarp(String pattern) {
        print("trying to sync pattern to warp");
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        print("pattern is $pattern");
        int index = 0;
        for(WarpObject w in warp) {
            print("index is $index, which means i wanna grab parsed pattern ${index % parsedPattern.length}");
            //mod makes it so that it'll just repeat the pattern over and over
            w.color = colors[parsedPattern[index % parsedPattern.length]];
            index++;
        }
        _renderFabric();

    }

    void syncPatternToWeft(String pattern) {
        print("trying to sync pattern to weft");
        List<int> parsedPattern = new List.from(pattern.split(",").map((String s) => int.parse(s)));
        print("pattern is $pattern");
        int index = 0;
        for(WeftObject w in weft) {
            print("index is $index, which means i wanna grab parsed pattern ${index % parsedPattern.length}");
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
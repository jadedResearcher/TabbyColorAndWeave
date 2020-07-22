//a warp object is given an X value and a color
//it knows how, given a canvas, how to render a color stripe at the x value and a color picker absolutely positioned above it
import 'dart:html';
import "package:CommonLib/Colours.dart";

class WarpObject {
    static final WIDTH = 5;
    Colour color;
    int x;

    WarpObject(Colour this.color, int this.x);

    //assume the canvas you're given is the one on screen, thus any changes you make reflect there
    //if i need to buffer i'll give it the fabric instance instead
    void renderSelf(CanvasElement canvas) {
        canvas.context2D.fillStyle = color.toStyleString();
        canvas.context2D.fillRect(x,0,WIDTH,canvas.height);

    }
}
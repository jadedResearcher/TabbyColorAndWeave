//a warp object is given an X value and a color
//it knows how, given a canvas, how to render a color stripe at the x value and a color picker absolutely positioned above it
import 'dart:html';
import "package:CommonLib/Colours.dart";

class WeftObject {
    static final WIDTH = 5;
    Colour color;
    int y;
    //up shed vs down shed is offset
    bool up = false;

    WeftObject(Colour this.color, int this.y, bool this.up);

    //assume the canvas you're given is the one on screen, thus any changes you make reflect there
    //if i need to buffer i'll give it the fabric instance instead
    void renderSelf(CanvasElement canvas) {
        canvas.context2D.fillStyle = color.toStyleString();
        int startX = 0;
        if(up) {
            startX += WIDTH;
        }
        for(int i = startX; i< canvas.width-WeftObject.WIDTH; i+= (WeftObject.WIDTH*2)) {
            canvas.context2D.fillRect(i, y, WIDTH, WIDTH);
        }

    }
}
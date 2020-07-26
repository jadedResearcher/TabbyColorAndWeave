//a warp object is given an X value and a color
//it knows how, given a canvas, how to render a color stripe at the x value and a color picker absolutely positioned above it
import 'dart:html';
import "package:CommonLib/Colours.dart";

class WarpObject {
    static final WIDTH = 5;
    Colour color;
    int x;
    //is it hole, or is it slot.
    bool hole = true;

    WarpObject(Colour this.color, int this.x, bool this.hole);

    //assume the canvas you're given is the one on screen, thus any changes you make reflect there
    //if i need to buffer i'll give it the fabric instance instead
    void renderSelf(CanvasElement canvas) {
        canvas.context2D.fillStyle = color.toStyleString();
        canvas.context2D.fillRect(x,0,WIDTH,canvas.height);
        if(hole) {
            Colour inverse = new Colour(255-color.red, 255-color.green, 255-color.blue);
            canvas.context2D.fillStyle = inverse.toStyleString();
            canvas.context2D.fillRect(x+1,10,WIDTH-2,WIDTH-1);

        }

    }
}
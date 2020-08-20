//a warp object is given an X value and a color
//it knows how, given a canvas, how to render a color stripe at the x value and a color picker absolutely positioned above it
import 'dart:html';
import "package:CommonLib/Colours.dart";

class WeftObject {
    static int WIDTH = 5;
    Colour color;
    List<int> pickupPattern = TWOSHAFTdown;
    //zero means weft is not showing, 1 means it is. so 1,1,0 is a two weft float
    static List<int> TWOSHAFTUP = [0,1];
    static List<int> TWOSHAFTdown = [1,0];
    static List<int> NEUTRALTURNPICKUP =  [1,1,0];
    static List<int>  UPSLIDEPICKUP= [0,0,1];
    int y;

    WeftObject(Colour this.color, int this.y, this.pickupPattern);

    bool patternStartsWith0() {
        return !pickIs1(0);
    }

    bool pickIs1(int pickIndex) {
        return pickupPattern[pickIndex % (pickupPattern.length)] == 1;

    }

    //assume the canvas you're given is the one on screen, thus any changes you make reflect there
    //if i need to buffer i'll give it the fabric instance instead
    void renderSelf(CanvasElement canvas) {
        canvas.context2D.fillStyle = color.toStyleString();
        int currentX = 0;
        /*for(int i = startX; i< canvas.width-WeftObject.WIDTH; i+= (WeftObject.WIDTH*2)) {
            canvas.context2D.fillRect(i, y, WIDTH, WIDTH);
        }*/
        int pickNum = 0;
        while(currentX < canvas.width) {
            if(pickIs1(pickNum)) { //only render visible picks
                canvas.context2D.fillRect(currentX, y, WIDTH, WIDTH);
            }
            pickNum ++;
            currentX += WIDTH;
        }
    }
}
/*todo
we need a loom object that contains heddles and thread

we need a HeddleObject which has an ordered array of slots and holes, and a length for how many there should be.

We need a WarpChainObject that is a collection of warp threads .  each thread should have color, and then an array of indices in heddle order.

as an example [3, 4]. would be a thread going through a hole in the first heddle and the right slot in the second.


once data structure is in place, render it (without interactivity)

then, make it so clicking a thread clears out its heddle array and highlights it.

then, make it so that clicking a hole/slot in a heddle adds it to the heddle array at the index of the heddle you clicked.  if you click second heddle but there's nothing already in your array add the same index to every previous entry (pass thru)

there is a text box saying "repeat threads x-y z times, starting at w" and it will copy color and heddle
~~~
when its weaving time, you pick a weft color, then click arrows next to heddles to raise/lower them. each shed defaults all heddles to neutral (positions are 1, 0, -1)

then you click "throw pick" to select.

that updates the render of your fabric and adds a pick to a list.  any pick you can go back and edit.

each pick has a number.  on the fabric itself you can say "repeat picks x-y z times starting at pick w" it will insert the new picks at w, defaults to the current pick index.

there is also a button for "repeat pattern for rest of weaving"

canvas height is based on picks. in vert scroll, always at top (new picks go up).
 */
import 'Heddle.dart';
import 'WarpChain.dart';
import 'package:CommonLib/Colours.dart';

class RigidHeddleLoom{
    //single heddle is 2 sheds (plain weave only) , double heddle is 3 sheds, triple is 4, anything more than that is theoretical.
    List<Heddle> heddles = new List<Heddle>();
    //i prefer doing it by color
    List<WarpChain> warpChains = new List<WarpChain>();

    List<WarpThread> get allThreads{
        List<WarpThread> ret = new List<WarpThread>();
        return ret;
    }

    static RigidHeddleLoom testLoom() {
        RigidHeddleLoom ret = new RigidHeddleLoom();
        int numberThreads = 50;
        ret.heddles.add(new Heddle(0, numberThreads));
        ret.heddles.add(new Heddle(1, numberThreads));
        ret.warpChains.add(new WarpChain(numberThreads, new Colour(255,0,0)));
        ret.warpChains.add(new WarpChain(numberThreads, new Colour(0,255,0)));
        ret.twillDoubleThreading();
        return ret;
    }

    //basic twill
    void twillDoubleThreading() {

    }


}
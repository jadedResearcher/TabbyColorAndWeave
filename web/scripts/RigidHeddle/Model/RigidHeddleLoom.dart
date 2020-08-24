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
import '../../Fabric.dart';
import 'Heddle.dart';
import 'Pick.dart';
import 'WarpThread.dart';
import 'package:CommonLib/Colours.dart';

class RigidHeddleLoom{
    //single heddle is 2 sheds (plain weave only) , double heddle is 3 sheds, triple is 4, anything more than that is theoretical.
    List<Heddle> heddles = new List<Heddle>();
    //i prefer doing it by color
    List<Pick> picks = new List<Pick>();

    //each thread knows which section it is in for each heddle. so the loom knows what sheds exist by knowing what threads are in it and what heddles it has
    List<WarpThread> allThreads= new List<WarpThread>();


    Fabric exportLoomToFabric() {
        List<Colour> colors = collateAllColorsUsed();
        String warpPatternStart = exportThreadsToWarpString(colors);
        String weftPatternStart = exportPicksToWeftString(colors);
        String pickupPatternStart = exportPicksToPickupString();
        print("JR NOTE: pickup pattern is $pickupPatternStart");
        Fabric fabric = new Fabric(1200,1000);
        fabric.colors = colors;
        fabric.warpPatternStart = warpPatternStart;
        fabric.weftPatternStart = weftPatternStart;
        fabric.pickupPatternStart = pickupPatternStart;
        return fabric;
    }

    List<Colour> collateAllColorsUsed() {
        Set<Colour> colors = new Set<Colour>();
        for(WarpThread thread in allThreads) {
            colors.add(thread.color);
        }

        for(Pick pick in picks) {
            colors.add(pick.color);
        }
        return new List.from(colors);
    }

    String exportThreadsToWarpString(List<Colour> colors) {
        List<int> ret = new List<int>();
        for(WarpThread thread in allThreads) {
            ret.add(colors.indexOf(thread.color));
        }
        return ret.join(",");
    }

    String exportPicksToWeftString(List<Colour> colors) {
        List<int> ret = new List<int>();
        for(Pick pick in picks) {
            ret.add(colors.indexOf(pick.color));
        }
        return ret.join(",");
    }

    String exportPicksToPickupString() {
        String ret = "";
        for(Pick pick in picks) {
            if(ret.isEmpty) {
                ret = "${pick.pickToPickupPattern(allThreads)}";
            }else {
                ret = "$ret\n${pick.pickToPickupPattern(allThreads)}";
            }
        }
        return ret;
    }

    static RigidHeddleLoom testDoubleLoom() {
        RigidHeddleLoom ret = new RigidHeddleLoom();
        int numberThreads = 50;
        ret.heddles.add(new Heddle(0, numberThreads));
        ret.heddles.add(new Heddle(1, numberThreads));
        for(int i = 0; i< 30; i++) {
            ret.allThreads.add(new WarpThread( new Colour(200, 0, 0)));
            ret.allThreads.add(new WarpThread(new Colour(0, 200, 0)));
            ret.allThreads.add(new WarpThread(new Colour(0, 0, 200)));
            ret.allThreads.add(new WarpThread(new Colour(0, 200, 200)));
        }
        ret.basicDoubleThreading();
        Colour color = new Colour(0,0,0);


        Pick one = new Pick(color, [new HeddleState(ret.heddles[0],HeddleState.UP), new HeddleState(ret.heddles[1],HeddleState.NEUTRAL)]);
        Pick two = new Pick(color, [new HeddleState(ret.heddles[0],HeddleState.NEUTRAL), new HeddleState(ret.heddles[1],HeddleState.UP)]);
        Pick three = new Pick(color, [new HeddleState(ret.heddles[0],HeddleState.DOWN), new HeddleState(ret.heddles[1],HeddleState.DOWN)]);

        ret.picks.add(one);
        ret.picks.add(two);
        ret.picks.add(three);
        ret.picks.add(one);
        ret.picks.add(two);
        ret.picks.add(three);
        ret.picks.add(one);
        ret.picks.add(two);
        ret.picks.add(three);
        ret.picks.add(two);
        ret.picks.add(one);
        ret.picks.add(three);
        ret.picks.add(two);
        ret.picks.add(one);
        ret.picks.add(three);
        ret.picks.add(two);
        ret.picks.add(one);


        return ret;
    }


    static RigidHeddleLoom testTwill() {
        RigidHeddleLoom ret = new RigidHeddleLoom();
        int numberThreads = 50;
        ret.heddles.add(new Heddle(0, numberThreads));
        ret.heddles.add(new Heddle(1, numberThreads));
        for(int i = 0; i< 2; i++) {
            ret.allThreads.add(new WarpThread( new Colour(255, 0, 0)));
            ret.allThreads.add(new WarpThread(new Colour(0, 255, 0)));
            ret.allThreads.add(new WarpThread(new Colour(0, 0, 255)));
        }
        Colour color = new Colour(0,0,0);
        for(int i = 0; i<100; i++) {
            Pick up = new Pick(color, [new HeddleState(ret.heddles[0],HeddleState.UP), new HeddleState(ret.heddles[1],HeddleState.UP)]);
            Pick down = new Pick(color, [new HeddleState(ret.heddles[0],HeddleState.DOWN), new HeddleState(ret.heddles[1],HeddleState.DOWN)]);
            ret.picks.add(up);
            ret.picks.add(down);
        }
        ret.basicTwillThreading();
        return ret;
    }

    //its just single heddle, theres only two sheds
    void singleHeddleThreading() {
        List<WarpThread> threads = allThreads;
        int i = 0;
        for(WarpThread thread in threads) {
            if(i < heddles[0].holesAndSlots.length) {
                thread.heddleSections.add(heddles[0].holesAndSlots[i]);
            }else {
                break;
            }
            i++;
        }
    }

    //slot front hole, back hole (always lean same way)
    void basicTwillThreading() {
        if(heddles.length < 2) return singleHeddleThreading();
        List<WarpThread> threads = allThreads;
        int totalIndex = 0;
        int singleHeddleIndex = 0;
        for(WarpThread thread in threads) {
            Section firstHeddle = null;
            Section secondHeddle = null;
            if(singleHeddleIndex % 3 == 0) {
                threadThroughBothSlotsLeft(thread, (totalIndex/4).floor());
                singleHeddleIndex ++;
            }else if(singleHeddleIndex %3 ==1) {
                frontHoleToLeftSlot(thread, (totalIndex/4).floor());
                singleHeddleIndex ++;
            }else if(singleHeddleIndex %3 ==2) {
                frontSlotToLeftHole(thread, (totalIndex/4).floor());
                singleHeddleIndex ++;
            }

            if(firstHeddle != null && secondHeddle != null) {
                thread.heddleSections.add(firstHeddle);
                thread.heddleSections.add(secondHeddle);
            }
            totalIndex+=2;
        }
    }

    // slot hole, slot hole but for different heddles, and it matters if it leans left or right.
    void basicDoubleThreading() {
        if(heddles.length < 2) return singleHeddleThreading();
        List<WarpThread> threads = allThreads;
        int totalIndex = 0;
        int singleHeddleIndex = 0;
        for(WarpThread thread in threads) {
                Section firstHeddle = null;
                Section secondHeddle = null;
                if(singleHeddleIndex % 4 == 0) {
                    threadThroughBothSlotsLeft(thread, (totalIndex/4).floor());
                    singleHeddleIndex ++;
                }else if(singleHeddleIndex %4 ==1) {
                    frontHoleToLeftSlot(thread, (totalIndex/4).floor());
                    singleHeddleIndex ++;
                }else if(singleHeddleIndex %4 ==2) {
                    threadThroughBothSlotsLeft(thread, (totalIndex/4).floor());
                    singleHeddleIndex ++;
                }
                else if(singleHeddleIndex %4 ==3) {
                    frontSlotToLeftHole(thread, (totalIndex/4).floor());
                    singleHeddleIndex ++;
                }

                if(firstHeddle != null && secondHeddle != null) {
                    thread.heddleSections.add(firstHeddle);
                    thread.heddleSections.add(secondHeddle);
                }
                totalIndex+=2;
        }
    }

    bool threadSections(WarpThread thread, List<Section> sections) {
        //if ANY of the steps this thread must take are null, do nothing
        for(Section section in sections) {
            if(section == null) return false;
        }

        for(Section section in sections) {
            thread.heddleSections.add(section);
        }
        return true;
    }

    bool threadThroughBothSlotsLeft(WarpThread thread, int index) {
        Section firstHeddle =(heddles[0].getNextSlotToLeft(index));
        Section secondHeddle = (heddles[1].getNextSlotToLeft(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }

    bool threadThroughBothSlotsRight(WarpThread thread, int index) {
        Section firstHeddle =(heddles[0].getNextSlotToRight(index));
        Section secondHeddle = (heddles[1].getNextSlotToRight(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }

    bool frontHoleToRightSlot(WarpThread thread, int index) {
        Section firstHeddle = heddles[0].getNextHoleToRight(index);
        Section secondHeddle = (heddles[1].getNextSlotToRight(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }

    bool frontHoleToLeftSlot(WarpThread thread, int index) {
        Section firstHeddle =(heddles[0].getNextHoleToLeft(index));
        Section secondHeddle = (heddles[1].getNextSlotToLeft(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }

    bool frontSlotToRightHole(WarpThread thread, int index) {
        Section firstHeddle =(heddles[0].getNextSlotToRight(index));
        Section secondHeddle = (heddles[1].getNextHoleToRight(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }

    bool frontSlotToLeftHole(WarpThread thread, int index) {
        Section firstHeddle =(heddles[0].getNextSlotToLeft(index));
        Section secondHeddle = (heddles[1].getNextHoleToLeft(index));
        return threadSections(thread, [firstHeddle, secondHeddle]);
    }


}
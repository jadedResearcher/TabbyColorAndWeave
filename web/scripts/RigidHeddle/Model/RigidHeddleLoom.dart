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
import 'dart:html';

import '../../Fabric.dart';
import 'Heddle.dart';
import 'Pick.dart';
import 'WarpThread.dart';
import 'package:CommonLib/Colours.dart';

class RigidHeddleLoom{
    static int HEIGHT = 1200;
    static int WIDTH = 1000;
    //single heddle is 2 sheds (plain weave only) , double heddle is 3 sheds, triple is 4, anything more than that is theoretical.
    List<Heddle> heddles = new List<Heddle>();
    //i prefer doing it by color
    List<Pick> picks = new List<Pick>();

    //each thread knows which section it is in for each heddle. so the loom knows what sheds exist by knowing what threads are in it and what heddles it has
    List<WarpThread> allThreads= new List<WarpThread>();

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["heddles"] = heddles.map((Heddle s) => s.getSerialization()).toList();
        ret["picks"] = picks.map((Pick s) => s.getSerialization()).toList();
        ret["allThreads"] = allThreads.map((WarpThread s) => s.getSerialization()).toList();
        return ret;
    }
    void  loadFromSerialization(Map<String, dynamic > serialization) {
        heddles.clear();
        picks.clear();
        allThreads.clear();
        for(Map<String,dynamic> subserialization in serialization["heddles"]) {
            Heddle h = new Heddle.empty();
            h.loadFromSerialization(subserialization);
            heddles.add(h);
        }

        for(Map<String,dynamic> subserialization in serialization["picks"]) {
            Pick h = new Pick.empty();
            h.loadFromSerialization(subserialization, heddles);
            picks.add(h);
        }

        for(Map<String,dynamic> subserialization in serialization["allThreads"]) {
            WarpThread h = new WarpThread.empty();
            h.loadFromSerialization(subserialization, heddles);
            allThreads.add(h);
        }
    }
    //for each thread, design a pick that would make that thread be up.
    void replicateThreadsInPicksDouble() {
        //thread.isUpForPick(this)
        picks.clear();
        for(WarpThread thread in allThreads) {
            Colour color = new Colour(255-thread.color.red, 255-thread.color.green, 255-thread.color.blue);
            Pick pick = new Pick(picks.length, color, []);
            List<List<HeddleState>> potentials = HeddleState.allForDoubleHeddles(heddles);
            for(List<HeddleState> states in potentials) {
                pick.heddleStates = states;
                if(thread.isUpForPick(pick)) {
                    picks.add(pick);
                    break;
                }
            }
        }
    }

    void  loadPicksFromSerialization(Map<String, dynamic > serialization) {
        picks.clear();
        for(Map<String,dynamic> subserialization in serialization["picks"]) {
            Pick h = new Pick.empty();
            h.loadFromSerialization(subserialization, heddles);
            picks.add(h);
        }
    }

    //keep all structural elements as is, load only color
    void  loadColorFromSerialization(Map<String, dynamic > serialization) {

        int pickIndex = 0;
        int threadIndex = 0;
        List<Map<String,dynamic>> sourceDataPicks = new List.from(serialization["picks"]);
        List<Map<String,dynamic>> sourceDataThreads = new List.from(serialization["allThreads"]);

        for(Pick pick in picks) {
            pick.loadColorFromSerialization(sourceDataPicks[pickIndex % sourceDataPicks.length]);
            pickIndex ++;
        }

        for(WarpThread thread in allThreads) {
            thread.loadColorFromSerialization(sourceDataThreads[threadIndex % sourceDataThreads.length]);
            threadIndex ++;
        }

    }


    Fabric exportLoomToFabric(Fabric fabric) {
        List<Colour> colors = collateAllColorsUsed();
        String warpPatternStart = exportThreadsToWarpString(colors);
        String weftPatternStart = exportPicksToWeftString(colors);
        String pickupPatternStart = exportPicksToPickupString();
        if(fabric == null) {
            fabric = new Fabric(HEIGHT, WIDTH);
        }
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

    List<Pick> copyPicks(int startIndex, int endIndex, int numberRepetitions) {
        if(endIndex+1 > picks.length) endIndex = picks.length -1;
        List<Pick> patternPicks = picks.sublist(startIndex, endIndex+1);
        List<Pick> newPicks = new List<Pick>();
        int originalLength = picks.length;
        int index = 0;
        for(int i = 0; i<numberRepetitions; i++){
            for(Pick pattern in patternPicks) {
                Pick pick = pattern.copy(
                    originalLength + index);
                picks.add(pick);
                newPicks.add(pick);
                index ++;
            }

        }
        return newPicks;

    }

    List<Pick> copyPicksReverse(int startIndex, int endIndex, int numberRepetitions) {
        if(endIndex+1 > picks.length) endIndex = picks.length -1;
        List<Pick> patternPicks = picks.sublist(startIndex, endIndex+1);
        List<Pick> newPicks = new List<Pick>();
        int originalLength = picks.length;
        int index = 0;
        for(int i = 0; i<numberRepetitions; i++){
            for(Pick pattern in patternPicks) {
                Pick pick = pattern.copyReverse(
                    originalLength + index);
                picks.add(pick);
                newPicks.add(pick);
                index ++;
            }

        }
        return newPicks;

    }

    List<WarpThread> replaceThreadColors(Colour from, Colour to) {
        List<WarpThread> modifiedThreads = new List<WarpThread>();
        for(WarpThread thread in allThreads) {
            if(thread.color == from) {
                thread.color.setFrom(to);
                modifiedThreads.add(thread);
            }
        }
        return modifiedThreads;
    }

    List<Pick> replacePickColors(Colour from, Colour to) {
        List<Pick> modifiedPicks = new List<Pick>();
        for(Pick pick in picks) {
            if(pick.color == from) {
                pick.color.setFrom(to);
                modifiedPicks.add(pick);
            }
        }
        return modifiedPicks;
    }

    List<WarpThread> copyThreadColors(int startIndex, int endIndex, int numberRepetitions, int repsStartIndex) {
        if(endIndex+1 > allThreads.length) endIndex = allThreads.length -1;
        List<WarpThread> patternThreads = allThreads.sublist(startIndex, endIndex+1);
        List<Colour> patternColors = new List.from(patternThreads.map((WarpThread thread) =>thread.color));
        List<WarpThread> modifiedThreads = new List<WarpThread>();
        //each loop is a single new thread
        int index = 0; //important for thread modulo
        for(int i = repsStartIndex; i<numberRepetitions*patternThreads.length; i++) {
            if(i <allThreads.length) {
                WarpThread thread = allThreads[i];
                thread.copyColourFromSource(patternColors[index%patternColors.length]);
                modifiedThreads.add(thread);
                index ++;
            }
        }
        return modifiedThreads;
    }

    List<Pick> copyPickColors(int startIndex, int endIndex, int numberRepetitions, int repsStartIndex) {
        if(endIndex+1 > picks.length) endIndex = picks.length -1;
        List<Pick> patternPicks = picks.sublist(startIndex, endIndex+1);
        List<Pick> modifiedPicks = new List<Pick>();
        //each loop is a single new thread
        int index = 0; //important for pick modulo
        for(int i = repsStartIndex; i<numberRepetitions*patternPicks.length; i++) {
            if(i <picks.length) {
                Pick pick = picks[i];
                pick.copyColourFromSource(patternPicks[index%patternPicks.length]);
                modifiedPicks.add(pick);
                index ++;
            }
        }
        return modifiedPicks;
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

    static RigidHeddleLoom testSingleLoom() {
        RigidHeddleLoom ret = new RigidHeddleLoom();
        ret.heddles.add(new Heddle(0));
        ret.heddles.add(new Heddle(1));
        int numberthreads = 50;
        for(int i = 0; i< numberthreads; i++) {
            Colour color = new Colour(200,0,0);
            if(i > numberthreads/3 && i <= 2*numberthreads/3) {
                color = new Colour(0,200,0);
            }else if(i >= 2* numberthreads/3){
                color = new Colour(0,0,200);
            }
            ret.allThreads.add(new WarpThread( color,i));
        }
        ret.singleHeddleThreading();


        Pick one = new Pick(0,new Colour(0,0,0), [new HeddleState(ret.heddles[0],HeddleState.UP), new HeddleState(ret.heddles[1],HeddleState.NEUTRAL)]);
        Pick two = new Pick(1,new Colour(200,200,200), [new HeddleState(ret.heddles[0],HeddleState.DOWN), new HeddleState(ret.heddles[1],HeddleState.NEUTRAL)]);

        ret.picks.add(one);
        ret.picks.add(two);
        return ret;
    }

    static RigidHeddleLoom testDoubleLoom() {
        RigidHeddleLoom ret = new RigidHeddleLoom();
        int numberThreads = 80;
        ret.heddles.add(new Heddle(0));
        ret.heddles.add(new Heddle(1));
        for(int i = 0; i< numberThreads*2; i++) {
            ret.allThreads.add(new WarpThread( new Colour(200,0,0),i));
        }
        ret.basicDoubleThreading();


        Pick one = new Pick(0,new Colour(0,0,0), [new HeddleState(ret.heddles[0],HeddleState.UP), new HeddleState(ret.heddles[1],HeddleState.NEUTRAL)]);
        Pick two = new Pick(1,new Colour(0,0,0), [new HeddleState(ret.heddles[0],HeddleState.NEUTRAL), new HeddleState(ret.heddles[1],HeddleState.UP)]);
        Pick three = new Pick(2,new Colour(0,0,0), [new HeddleState(ret.heddles[0],HeddleState.DOWN), new HeddleState(ret.heddles[1],HeddleState.DOWN)]);

        ret.picks.add(one);
        ret.picks.add(two);
        ret.picks.add(three);

        return ret;
    }



    //its just single heddle, theres only two sheds
    void singleHeddleThreading() {
        List<WarpThread> threads = allThreads;
        int i = 0;
        int max = 2;
        for(WarpThread thread in threads) {
            if(i < heddles[0].holesAndSlots.length && i < max) {
                thread.heddleSections.add(heddles[0].holesAndSlots[i]);
            }else {
                break;
            }
            i++;
        }
    }
    // slot hole, slot hole but for different heddles, and it matters if it leans left or right.
    void basicDoubleThreading() {
        if(heddles.length < 2) return singleHeddleThreading();
        List<WarpThread> threads = allThreads;
        Heddle h1 = heddles[0];
        Heddle h2 = heddles[1];
        WarpThread one = threads[0];
        WarpThread two = threads[1];
        WarpThread three = threads[2];
        WarpThread four = threads[3];
        one.heddleSections.add(h1.holesAndSlots[1]);
        two.heddleSections.add(h1.holesAndSlots[1]);
        three.heddleSections.add(h1.holesAndSlots[2]);
        four.heddleSections.add(h1.holesAndSlots[3]);

        one.heddleSections.add(h2.holesAndSlots[1]);
        two.heddleSections.add(h2.holesAndSlots[2]);
        three.heddleSections.add(h2.holesAndSlots[3]);
        four.heddleSections.add(h2.holesAndSlots[3]);


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

}
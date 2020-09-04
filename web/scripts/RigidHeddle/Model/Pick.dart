/*
    A pick is a single horizontal weft thingy. It decides what heddles are in what positions and what color yarn is used.

    When its time to render the fabric each pick will get passed in all threads.
    Each thread knows what heddles they are tied to and how, so they will collaborate to turn a pick into a set of 1,0 things for the Fabric object to parse.
 */
import 'package:CommonLib/Colours.dart';

import '../View/PickView.dart';
import 'Heddle.dart';
import 'WarpThread.dart';

class Pick {
    Colour color = new Colour();
    int index;
    PickView view;
    List<HeddleState> heddleStates = new List<HeddleState>();
    Pick(int this.index, this.color, this.heddleStates);
    Pick.empty();

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["color"] = color.toStyleString();
        ret["index"] = index;
        ret["heddleStates"] = heddleStates.map((HeddleState s) => s.getSerialization()).toList();
        return ret;
    }

    void  loadFromSerialization(Map<String, dynamic > serialization, List<Heddle> possibleHeddles) {
        Colour tmpcolor = new Colour.fromStyleString(serialization["color"]);
        color.setFrom(tmpcolor);
        index = serialization["index"];
        heddleStates.clear();
        for(Map<String,dynamic> subserialization in serialization["heddleStates"]) {
            final HeddleState p = new HeddleState(null,null);
            p.loadFromSerialization(subserialization, possibleHeddles);
            heddleStates.add(p);
        }
    }

    void  loadColorFromSerialization(Map<String, dynamic > serialization) {
        Colour tmpcolor = new Colour.fromStyleString(serialization["color"]);
        color.setFrom(tmpcolor);
    }

    String pickToPickupPattern(List<WarpThread> threads) {
        List<int> ret = new List<int>();
        for(WarpThread thread in threads) {
            if(thread.heddleSections.isNotEmpty) {
                thread.isUpForPick(this) ? ret.add(1) : ret.add(0);
            }
        }
        return ret.join(",");
    }

    void copyColourFromSource(Pick source) {
        color.setFrom(Colour.fromStyleString(source.color.toStyleString()));
    }

    @override toString() {
        return "${this.color.toStyleString()}: $heddleStates";
    }

    Pick copy(index) {
        List<HeddleState> deepCopy = new List<HeddleState>();
        for(HeddleState hs in heddleStates) {
            deepCopy.add(new HeddleState(hs.heddle, hs.state));
        }
        return new Pick(index, Colour.fromStyleString(color.toStyleString()), deepCopy);
    }
}


class HeddleState {
    static const UP="UP";
    static const DOWN = "DOWN";
    static const NEUTRAL = "NEUTRAL";
    static const possibleStates = [UP, DOWN, NEUTRAL];
    Heddle heddle;
    String state;
    HeddleState(this.heddle, this.state);

    static List<List<HeddleState>> allForDoubleHeddles(List<Heddle> heddles) {
        List<List<HeddleState>> ret = new List<List<HeddleState>>();

        for(String state1 in possibleStates) {
            for(String state2 in possibleStates) {
                //for our purposes up up is not valid, we care about up neutral, neutral up, and down down.
                if(state1 != state2 || state1 == DOWN) {
                    ret.add([
                        new HeddleState(heddles[0], state1),
                        new HeddleState(heddles[1], state2)
                    ]);
                }
            }
        }
        return ret;
    }

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["heddleIndex"] = heddle.index;
        ret["state"] = state;
        return ret;
    }

    void loadFromSerializationFromHeddle(Map<String, dynamic > serialization, Heddle owner ) {
        state = serialization["state"];
        heddle = owner;
    }

    void  loadFromSerialization(Map<String, dynamic > serialization, List<Heddle> possibleHeddles) {
        state = serialization["state"];
        for(Heddle h in possibleHeddles) {
            if(h.index == serialization["heddleIndex"]) {
                heddle = h;
                break;
            }
        }
    }

        @override
    String toString() {
        return "${heddle.index}${state}";
    }
}
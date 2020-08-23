/*
    A pick is a single horizontal weft thingy. It decides what heddles are in what positions and what color yarn is used.

    When its time to render the fabric each pick will get passed in all threads.
    Each thread knows what heddles they are tied to and how, so they will collaborate to turn a pick into a set of 1,0 things for the Fabric object to parse.
 */
import 'package:CommonLib/Colours.dart';

import 'Heddle.dart';
import 'WarpChain.dart';

class Pick {
    Colour color;
    List<HeddleState> heddleStates = new List<HeddleState>();
    Pick(this.color, this.heddleStates);

    String pickToPickupPattern(List<WarpThread> threads) {
        List<int> ret = new List<int>();
        for(WarpThread thread in threads) {
            thread.isUpForPick(this) ? ret.add(1): ret.add(0);
        }
        return ret.join(",");
    }
}


class HeddleState {
    static const UP="UP";
    static const DOWN = "DOWN";
    static const NEUTRAL = "NEUTRAL";
    Heddle heddle;
    String state;
    HeddleState(this.heddle, this.state);
}
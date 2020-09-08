import 'package:CommonLib/Colours.dart';

import '../View/WarpThreadView.dart';
import 'Heddle.dart';
import 'Pick.dart';

class WarpThread {
    ThreadView view;
    Colour color = new Colour();
    //makes it easier to thread
    Colour guideColor = new Colour(0,0,0);
    int index;
    //one per heddle
    List<Section> heddleSections = new List<Section>();


    WarpThread(Colour this.color, int this.index);
    WarpThread.empty();

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["color"] = color.toStyleString();
        ret["guideColor"] = guideColor.toStyleString();
        ret["index"] = index;
        //yes its a repeat from heddle section but this can be used to get the data to get the already parsed heddleSection
        ret["heddleSections"] = heddleSections.map((Section s) => s.getSerialization()).toList();
        return ret;
    }

    void  loadFromSerialization(Map<String, dynamic > serialization, List<Heddle> possibleHeddles) {
        index = serialization["index"];
        Colour tmpcolor = new Colour.fromStyleString(serialization["color"]);
        color.setFrom(tmpcolor);

        Colour tmpcolor2= new Colour.fromStyleString(serialization["guideColor"]);
        guideColor.setFrom(tmpcolor2);

        heddleSections.clear();
        for(Map<String,dynamic> subserialization in serialization["heddleSections"]) {
            heddleSections.add(Section.findFromSerialization(subserialization, possibleHeddles));
        }
    }

    void  loadColorFromSerialization(Map<String, dynamic > serialization) {
        Colour tmpcolor = new Colour.fromStyleString(serialization["color"]);
        color.setFrom(tmpcolor);

        Colour tmpcolor2= new Colour.fromStyleString(serialization["guideColor"]);
        guideColor.setFrom(tmpcolor2);
    }



    //TODO warning this is only going to be tested for up to TWO HEDDLES because i don't have three yet to confirm with
    bool isUpForPick(Pick pick) {
        if(heddleSections.length == 1) return isUpForPickSingleHeddle(pick);
        if(heddleSections.length == 2) return isUpForPickDoubleHeddle(pick);
        return false;
    }

    @override
    String toString() {
        return "Thread $index ${color.toStyleString()}";
    }

    void copyColourFromSource(Colour source) {
        color.setFrom(Colour.fromStyleString(source.toStyleString()));
        //doing heddleSections is very very hard. have to guess which section to pick for the copy, don't do it, humans are better.
    }

    bool isUpForPickSingleHeddle(Pick pick) {
        Section section = heddleSections.first;
        bool hole = section is Hole;
        if(hole) {
            return pick.heddleStates[0].state == HeddleState.UP;
        }else {
            //i'm only up if the hole is down.
            return pick.heddleStates[0].state == HeddleState.DOWN;
        }
    }

    //this isn't just single x2 cuz neutral can matter here
    /*
    If my hole heddle is up, I'm *always* up.
    If my hole heddle is neutral, I'm up if the other heddle is down.
    If I have no hole heddle, I'm up if both heddles are down.

    if its none of those are true its down
    */
    bool isUpForPickDoubleHeddle(Pick pick) {
        Section firstHeddle = heddleSections.first;
        Section secondHeddle = heddleSections[1];

        bool h1IsHole = firstHeddle is Hole;
        bool h2IsHole = secondHeddle is Hole;

        String h1State = pick.heddleStates[0].state;
        String h2State = pick.heddleStates[1].state;

        if(eitherHoleIsUp(h1IsHole, h2IsHole, h1State, h2State)){
            return true;
        }else if (holeIsNeutralOtherIsDown(h1IsHole, h2IsHole, h1State, h2State)) {
            return true;
        }else if(oneHeddleIsDownAndASlotAndTheOtherNeutralOrDownAndSlotToo(h1IsHole, h2IsHole, h1State, h2State)) {
            return true;
        }
        return false;
    }

    bool eitherHoleIsUp(bool h1IsHole, bool h2IsHole, String h1State, String h2State) {
        if(h1IsHole) {
            return h1State == HeddleState.UP;
        }
        if(h2IsHole) {
            return h2State == HeddleState.UP;
        }
        return false;
    }

    //If my hole heddle is neutral, I'm up if the other heddle is down.
    bool holeIsNeutralOtherIsDown(bool h1IsHole, bool h2IsHole, String h1State, String h2State) {
        if(h1IsHole) {
            return h1State == HeddleState.NEUTRAL && h2State == HeddleState.DOWN;
        }
        if(h2IsHole) {
            return h2State == HeddleState.NEUTRAL && h1State == HeddleState.DOWN;
        }
        return false;
    }

    bool thereIsNoHoleAndBothAreDown(bool h1IsHole, bool h2IsHole, String h1State, String h2State) {
        if(!h1IsHole && !h2IsHole) {
            return h1State == HeddleState.DOWN && h2State == HeddleState.DOWN;
        }
        return false;
    }

    //its not just both are slot and down because of pickup etc.
    bool oneHeddleIsDownAndASlotAndTheOtherNeutralOrDownAndSlotToo(bool h1IsHole, bool h2IsHole, String h1State, String h2State) {
        if(!h1IsHole) {
            if(h1State == HeddleState.DOWN) {
                return (h2State == HeddleState.NEUTRAL || (!h2IsHole && h2State == HeddleState.DOWN));
            }
        }
        if(!h2IsHole) {
            if(h2State == HeddleState.DOWN) {
                return (h1State == HeddleState.NEUTRAL || (!h1IsHole && h1State == HeddleState.DOWN));
            }
        }
        return false;
    }

}
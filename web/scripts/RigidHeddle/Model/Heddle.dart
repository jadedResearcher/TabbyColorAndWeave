import '../View/HeddleView.dart';

class Heddle {
    HeddleView view;
    //which heddle am i?
    int index;
    List<Section> holesAndSlots = new List<Section>();
    Heddle(int this.index, int numberEnds) {
        initHeddle(numberEnds);
    }

    Heddle.empty();

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["index"] = index;
        ret["holesAndSlots"] = holesAndSlots.map((Section s) => s.getSerialization()).toList();
        return ret;
    }

    void  loadFromSerialization(Map<String, dynamic > serialization) {
        index = serialization["index"];
        holesAndSlots.clear();
        for(Map<String,dynamic> subserialization in serialization["holesAndSlots"]) {
            Section s;
            if(subserialization["type"] == Hole.TYPE) {
                s = new Hole(0,null);
            }else {
                s = new Slot(0,null);
            }
            s.loadFromSerializationWithHeddle(subserialization, this);
            holesAndSlots.add(s);
        }
    }

    void initHeddle(int numberEnds) {
        for(int i =0; i<numberEnds; i++) {
            if(i%2 == 0) {
                holesAndSlots.add(new Hole(i, this));
            }else {
                holesAndSlots.add(new Slot(i, this));
            }
        }
    }

    Section getNextSlotToRight(int index) {
        if(index < 1 +1 || index > holesAndSlots.length -1) return null;
        String debug = "Checked: ";

        for(int i = index; i< holesAndSlots.length; i++) {
            Section section = holesAndSlots[i];
            debug = "$debug  $section, ";
            if(section is Slot) {
                return section;
            }
        }
        print("JR NOTE: NO slot found right of $index, length was ${holesAndSlots.length} $debug");
    }

    Section getNextSlotToLeft(int index) {
        if(index < 1 || index > holesAndSlots.length-1) return null;
        String debug = "Checked: ";
        for(int i = index; i>= 0; i--) {
            Section section = holesAndSlots[i];
            debug = "$debug  $section, ";
            if(section is Slot) {
                return section;
            }
        }
        print("JR NOTE: NO slot found left of $index, length was ${holesAndSlots.length} $debug");
    }

    Section getNextHoleToRight(int index) {
        if(index < 1 || index > holesAndSlots.length -1) return null;
        String debug = "Checked: ";
        for(int i = index; i< holesAndSlots.length; i++) {
            Section section = holesAndSlots[i];
            debug = "$debug  $section, ";
            if(section is Hole) {
                return section;
            }
        }
        print("JR NOTE: NO hole found right of $index, length was ${holesAndSlots.length} $debug");
    }

    Section getNextHoleToLeft(int index) {
        if(index < 1 || index > holesAndSlots.length -1) return null;
        String debug = "Checked: ";
        for(int i = index; i>= 0; i+= -1) {
            Section section = holesAndSlots[i];
            debug = "$debug  $section, ";
            if(section is Hole) {
                return section;
            }
        }
        print("JR NOTE: NO hole found left of $index, length was ${holesAndSlots.length} $debug");

    }
}

//sections know what their unique identifier is, like heddle 1, section 5
abstract class Section {
    SectionView view;
    int index; //your index matters more than your place in the array, since pick will look here
    Heddle heddle;
    String type;
    Section(int this.index,  Heddle this.heddle);

    Map<String,dynamic > getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["type"] = type;
        ret["index"] = index;
        ret["heddleIndex"] = heddle.index;
        return ret;
    }

    void  loadFromSerializationWithHeddle(Map<String, dynamic > serialization, Heddle owner) {
        //type does'n tmatter here, it'll be used a layer above
        index = serialization["index"];
        heddle = owner;
    }



    //first figure out which heddle we're in, then find the right section
    static Section findFromSerialization(Map<String, dynamic > serialization, List<Heddle> possibleHeddles) {
        for(Heddle h in possibleHeddles) {
            print("WarpThreadDebug: Is it heddle $h? it's index is ${h.index} vs ${serialization["index"]}");
            if(serialization["heddleIndex"] == h.index) {
                print("WarpThreadDebug: it was");
                for(Section s in h.holesAndSlots) {
                    print("WarpThreadDebug: is it section $s? ${serialization["index"]} vs ${s.index}");
                    if(serialization["index"] == s.index) {
                        print("WarpThreadDebug: it was");
                        return s;
                    }
                }
            }
        }
        print("EMERGENCY!!! WarpThreadDebug:  No Section was found!!!");
    }

    @override
    String toString() {
        return "$type$index";
    }
}

class Hole extends Section {
    static const TYPE="H";
    @override
    String type = TYPE;
  Hole(int index, Heddle heddle) : super(index, heddle);



}

class Slot extends Section {
    static const TYPE="S";
    @override
    String type = TYPE;
    Slot(int index,  Heddle heddle) : super(index, heddle);

}
import '../View/HeddleView.dart';

class Heddle {
    HeddleView view;
    //which heddle am i?
    int index;
    List<Section> holesAndSlots = new List<Section>();
    Heddle(int this.index, int numberEnds) {
        initHeddle(numberEnds);
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
    int index;
    Heddle heddle;
    Section(int this.index,  Heddle this.heddle);
}

class Hole extends Section {
  Hole(int index, Heddle heddle) : super(index, heddle);

  @override
    String toString() {
        return "Hole$index";
  }

}

class Slot extends Section {
  Slot(int index,  Heddle heddle) : super(index, heddle);

  @override
  String toString() {
      return "Slot$index";
  }
}
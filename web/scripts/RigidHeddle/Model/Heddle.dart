class Heddle {
    //which heddle am i?
    int index;
    List<Section> holesAndSlots = new List<Section>();
    Heddle(int this.index, int numberEnds) {
        initHeddle(numberEnds);
    }

    void initHeddle(int numberEnds) {
        for(int i =0; i<numberEnds; i++) {
            if(i%2 == 0) {
                holesAndSlots.add(new Hole(i, index));
            }else {
                holesAndSlots.add(new Slot(i, index));
            }
        }
    }
}

//sections know what their unique identifier is, like heddle 1, section 5
abstract class Section {
    int index;
    int heddle_index;
    Section(int this.index, int this.heddle_index);
}

class Hole extends Section {
  Hole(int index, int heddle_index) : super(index, heddle_index);

}

class Slot extends Section {
  Slot(int index, int heddle_index) : super(index, heddle_index);
}
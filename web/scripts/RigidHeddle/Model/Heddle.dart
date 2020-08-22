class Heddle {
    List<Section> holesAndSlots = new List<Section>();
    Heddle(int numberEnds) {
        initHeddle(numberEnds);
    }

    void initHeddle(int numberEnds) {
        for(int i =0; i<numberEnds; i++) {
            if(i%2 == 0) {
                holesAndSlots.add(new Hole());
            }else {
                holesAndSlots.add(new Slot());
            }
        }
    }
}

abstract class Section {

}

class Hole extends Section {

}

class Slot extends Section {

}
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

}

class Slot extends Section {
  Slot(int index,  Heddle heddle) : super(index, heddle);
}
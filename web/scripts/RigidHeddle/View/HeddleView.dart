import 'dart:html';
import 'dart:svg';

import '../Model/Heddle.dart';

 class HeddleView{
     Heddle heddle;
     Element parent;

     HeddleView(Heddle this.heddle, Element this.parent);

     void renderHeddle() {
        final SvgElement element = new SvgElement.tag("g")..classes.add("heddle");
        element.text = "TODO: heddle of length ${heddle.holesAndSlots.length}";
        parent.append(element);
    }


}
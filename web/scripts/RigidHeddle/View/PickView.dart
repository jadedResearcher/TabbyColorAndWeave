import 'dart:html';

import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Utility.dart';

import '../Model/Pick.dart';

class PickView {
    Pick pick;
    Element parent;
    PickView(Pick this.pick, this.parent);

    void render(Lambda<Pick> removeCallback) {
        DivElement div = new DivElement()..classes.add("pick");
        parent.append(div);
        HeadingElement heading = new HeadingElement.h3()..text = "Pick ${pick.index}";
        div.append(heading);
        int index = 0;
        ButtonElement remove = new ButtonElement()..text = "x"..classes.add("x");
        div.append(remove);
        remove.onClick.listen((Event e) => removeCallback(pick));
        InputElement color = new InputElement()..type = "color"..value = pick.color.toStyleString()..style.display="block";
        div.append(color);
        color.onInput.listen((Event e) {
            Colour newColor = Colour.fromStyleString(color.value);
            pick.color.setFrom(newColor);
        });

        for(HeddleState heddleState in pick.heddleStates) {
            DivElement subcontainer = new DivElement();
            div.append(subcontainer);
            LabelElement label = new LabelElement()..text = "Heddle $index: ";
            SelectElement select = new SelectElement();
            for(String state in HeddleState.possibleStates) {
                OptionElement option = new OptionElement()..value = state..text = state..selected=heddleState.state == state;
                select.append(option);
            }
            select.onInput.listen((Event e) {
                heddleState.state = select.value;
            });
            subcontainer.append(label);
            subcontainer.append(select);
            index ++;
        }


    }
}
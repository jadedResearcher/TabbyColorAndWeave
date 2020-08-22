import 'dart:html';
import 'dart:svg';

import '../Model/Heddle.dart';
import '../Model/RigidHeddleLoom.dart';
import '../Model/WarpChain.dart';
import 'HeddleView.dart';
import 'WarpChainView.dart';

 class RigidHeddleLoomView {
     Element parent;
     RigidHeddleLoom loom;
     RigidHeddleLoomView(this.loom, this.parent);

     void renderLoom() {
        final SvgElement loomElement = SvgElement.tag("svg")..classes.add("loom");
        loomElement.attributes["width"] = "1000";
        loomElement.attributes["height"] = "500";
        parent.append(loomElement);
        final SvgElement heddleContainer = SvgElement.tag("g")..classes.add("heddles");
        loomElement.append(heddleContainer);
        for(Heddle heddle in loom.heddles) {
            new HeddleView(heddle, heddleContainer).renderHeddle();
        }

        final SvgElement warpContainer = SvgElement.tag("g")..classes.add("warpChains");
        loomElement.append(warpContainer);
        int x = 0;
        for(WarpChain chain in loom.warpChains) {
            x = new WarpChainView(chain, warpContainer,x, 450).renderChain();
        }


    }
}
import 'dart:html';

import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';

import 'scripts/Fabric.dart';
import 'scripts/RigidHeddle/Model/RigidHeddleLoom.dart';
import 'scripts/RigidHeddle/View/RigidHeddleLoomView.dart';
import 'scripts/Util.dart';
import 'scripts/WeftObject.dart';

List<Pattern> patterns = [];
Fabric fabric;
void main() {
    Element output = querySelector('#output');
    RigidHeddleLoomView view = new RigidHeddleLoomView(RigidHeddleLoom.testLoom(), output);
    view.renderLoom();

}


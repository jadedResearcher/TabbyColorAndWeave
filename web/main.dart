import 'dart:html';

import 'scripts/Fabric.dart';
import 'scripts/Util.dart';

void main() {
  Element output = querySelector('#output');
  Element controls = querySelector('#controls');

  Fabric fabric = new Fabric(800,800);
   //fabric.debug();
   fabric.renderToParent(output,controls);
  // Util.test();

}

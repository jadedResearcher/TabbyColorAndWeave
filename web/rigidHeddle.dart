import 'dart:html';

import 'package:LoaderLib/Loader.dart';

import 'scripts/Fabric.dart';
import 'scripts/RigidHeddle/Model/RigidHeddleLoom.dart';
import 'scripts/RigidHeddle/View/RigidHeddleLoomView.dart';

List<Pattern> patterns = [];
Fabric fabric;
Element output = querySelector('#output');
RigidHeddleLoomView view;
void main() {
    view = new RigidHeddleLoomView(RigidHeddleLoom.testSingleLoom());
    view.renderLoom(output);
    processTemplates();
}

void processTemplates() async {
    DivElement container = new DivElement()..classes.add("templates");
    HeadingElement header = new HeadingElement.h2()..text = "Templates";
    container.append(header);
    output.append(container);
    await getTemplates(container);
}

void getTemplates(Element container) async{
    String imageListSource = "http://farragofiction.com/RigidHeddleSim/Templates/list.php";
    Map<String,dynamic> results = await Loader.getResource(imageListSource,format: Formats.json );
    for(String folder in results["folders"].keys) {
        processFolder(container, folder, results);
    }
}

void processFolder(Element container, String folder,Map<String,dynamic>  results) {
    print("in folder $folder");
    DivElement folderContainer = new DivElement()..classes.add("folder");
    HeadingElement header = new HeadingElement.h3()..text = folder;
    folderContainer.append(header);

    container.append(folderContainer);
    for(String file in results["folders"][folder]["files"]) {
        if (file.contains("png")) {
            print("found file $file");
        }
    }
}

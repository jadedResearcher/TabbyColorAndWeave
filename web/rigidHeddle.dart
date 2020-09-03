import 'dart:html';

import 'package:ImageLib/Encoding.dart';
import 'package:LoaderLib/Loader.dart';

import 'scripts/Fabric.dart';
import 'scripts/RigidHeddle/Model/RigidHeddleLoom.dart';
import 'scripts/RigidHeddle/View/RigidHeddleLoomView.dart';
String templateSource = "http://farragofiction.com/RigidHeddleSim/Templates/";

List<Pattern> patterns = [];
Fabric fabric;
Element output = querySelector('#output');
RigidHeddleLoomView view;
void main() {
    view = new RigidHeddleLoomView(RigidHeddleLoom.testSingleLoom());
    view.renderLoom(output);
    try {
        processTemplates();
    }catch(error) {
        window.console.error("Error caught trying to process templates $error");
    }
}

void processTemplates() async {
    DivElement container = new DivElement()..classes.add("templates");
    HeadingElement header = new HeadingElement.h2()..text = "Templates";
    container.append(header);
    output.append(container);
    await getTemplates(container);
}

void getTemplates(Element container) async{
    final Map<String,dynamic> results = await Loader.getResource("$templateSource/list.php",format: Formats.json );
    for(String folder in results["folders"].keys) {
        processFolder(container, folder, results);
    }
}

void processFolder(Element container, String folder,Map<String,dynamic>  results) {
    DivElement folderContainer = new DivElement()..classes.add("folder");
    HeadingElement header = new HeadingElement.h3()..text = folder;
    folderContainer.append(header);

    container.append(folderContainer);
    for(String file in results["folders"][folder]["files"]) {
        if (file.contains("png")) {
            processfile(folderContainer, folder, file);
        }
    }
}

void processfile(Element container, String folder, String file) {
    ButtonElement button = new ButtonElement()..classes.add("file")..text = "${file.replaceAll(".png","")}";
    container.append(button);
    button.onClick.listen((Event e) {
        loadTemplate("$templateSource$folder/$file");
    });


}

void loadTemplate(String location) async {
    ArchivePng image = await Loader.getResource(location, format: ArchivePng.format);
    view.syncLoomToImage(image, location);
}

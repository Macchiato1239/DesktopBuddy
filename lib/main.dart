import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'library.dart';
import 'layer.dart';
import 'buttons.dart'; //implementing heap
import 'focus.dart';
import 'background.dart';

final Layer = LayerManager(); 
const overlayChannel = MethodChannel('overlay_window');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // Disable resizing
    await windowManager.setResizable(false);
  });

  //SWIFT TO DART LISTENER

  overlayChannel.setMethodCallHandler((call) async {

  switch (call.method) {

    case "ImportSuccess":
      final id = call.arguments["id"];
      Layer.importSuccess(
        id,
      );

      break;

    case "layerInfo":// for some reason the dragging sends info even when i havent done anything yet
      final args = Map<String, dynamic>.from(call.arguments);
      var passedId=args["id"];
      if (passedId==Layer.focusedLayer?.id) { //check if the info sent belongs to the focused layer or not, if not then ignore
      Layer.focusedWidth =
          (args["width"] as num).toDouble();

      Layer.focusedHeight =
          (args["height"] as num).toDouble();

      Layer.focusedX =
          (args["x"] as num).toDouble();

      Layer.focusedY =
          (args["y"] as num).toDouble();

      Layer.notifyListeners();
      }
      break;

  }

});

  runApp(MyApp());
}
//---------------------------------- 
//use final to prevent accidental reassigment

/// ## SECTION: SENDING MESSAGES TO SWIFT CHANNEL
Future<void> import() async {
  final id=Layer.reserveId();

  await overlayChannel.invokeMethod(
    "ImportImg",
    {"id": id},
  );
}

Future<void> builtinLayer(String URL, name) async {
  final id = Layer.reserveId(); 
  Layer.addBuiltInLayer(LayerData(
    id: id,
    name: name,
    )
  );
  await overlayChannel.invokeMethod(
    "ImportImg",
    {
      "id": id,
      "imageURL": URL, //ok might i have got this bit wrong
    },
  );
}

//Deleting targeted layers
Future<void> delete(int id) async {
  Layer.removeLayerById(id);

  await overlayChannel.invokeMethod(
    "destroyOverlay",
    {"id": id},
  );
}

Future<void> toggleVisibility(int id) async { // should save the state of the panel (hidden or not)
  //Layer.hideLayerById(id); will just change UI
  await overlayChannel.invokeMethod(
    "ToggleVisibility",
    {"id": id},
  );
}
//----------------------------------
//----------------------------------
/// ## SECTION: BUTTONS 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'WorkSans',
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Desktop Buddies!'),
          centerTitle: true,
        ),
        backgroundColor: const Color.fromARGB(255, 255, 247, 217),
        body: Stack(
          children:[
            Positioned( //Library shadow
              bottom:90,
              left: 30,
              child: ShadowDrop(200,400)
            ),
            //IMPORT BUTTON
            Positioned( //FocusSec shadow
              top:80,
              right: 290,
              child: ShadowDrop(250,210)
            ),
            Positioned( //LayerManager shadow
              bottom:90,
              right: 40,
              child: ShadowDrop(200,350)
            ),
            Positioned(
              top: 60,
              right:100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(30, 30),
                  backgroundColor: const Color.fromARGB(255, 255, 247, 217),
                  side: const BorderSide(
                    color: Color.fromARGB(220, 255, 191, 107),                // Border color
                    width: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: import,
                child: const Text(
                  'Import',
                    style: TextStyle(
                      color: Color.fromARGB(220, 255, 157, 29), // Sets the text color to blue
                    ),
                  ),
                ), // IT CNAJWOJNFIJOWAFIJOAFOIJW GO ANYWEHRE HHAHAHA
              ),
            Positioned(
              bottom:100,
              right:50,
              child: LayerList()
            ),
            Positioned(
              bottom:100,
              left:20,
              child:Library()
            ),
            Positioned(
              child: FocusSec(),
              top: 70,
              right: 300,
            ),
            //CREDITS
            Positioned(
              bottom: 10,
              left: 20,
              child: Text("Made by Leo",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              )
              ),
            ),
            //MEDIA
            Positioned(
              bottom: 10,
              right: 20,
              child: Container(
                width: 200,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularBorderlessButton(
                      text:"",
                      onPressed: Github,
                      width: 40,
                      height: 40,
                      pathfile: 'assets/icon/github.png'
                    ),
                    CircularBorderlessButton(
                      text:"",
                      onPressed: Instagram,
                      width: 40,
                      height: 40,
                      pathfile: 'assets/icon/insta.png'
                    ),
                    CircularBorderlessButton(
                      text:"",
                      onPressed: Portfolio,
                      width: 40,
                      height: 40,
                      pathfile: 'assets/icon/portfolio.png'
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Library Section


//List of layers
//AnimatedBuilder is responsible for updating
//each box is a button, each carries an Id
//When click on any box, do a check for the id and 

//i should prolly make a button inside a sizedBox-->clicking on that button can instantly 
//delete its parent and its associated frame, i should connect the frame with the item in the table
// on its creation
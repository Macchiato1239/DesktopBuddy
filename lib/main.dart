import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'library.dart';
import 'layer.dart';
import 'buttons.dart';
import 'background.dart';

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

  runApp(MyApp());
}
//---------------------------------- 


final Layer = LayerManager(); //use final to prevent accidental reassigment

/// ## SECTION: SENDING MESSAGES TO SWIFT CHANNEL
const overlayChannel = MethodChannel('overlay_window');
int nextId = 0;

Future<void> import() async {
  final id = nextId++;

  Layer.addLayer(
    LayerData(id, "Layer $id"),
  );

  await overlayChannel.invokeMethod(
    "ImportImg",
    {"index": id},
  );
}

Future<void> builtinLayer(String name) async {
  final id = nextId++;

  Layer.addLayer(LayerData(id, name));

  await overlayChannel.invokeMethod(
    "ImportImg",
    {
      "index": id,
      "imageName": name,
    },
  );
}

//Deleting targeted layers
Future<void> delete(int id) async {
  Layer.removeLayerById(id);

  await overlayChannel.invokeMethod(
    "destroyOverlay",
    {"index": id},
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
        body: Stack(
          children:[
            //IMPORT BUTTON
            Positioned(
              top: 60,
              right:50,
              child: ElevatedButton(
                onPressed: import,
                child: const Text('Import'), // IT CNAJWOJNFIJOWAFIJOAFOIJW GO ANYWEHRE HHAHAHA
              ),
            ),
            Positioned(
              top:100,
              right:50,
              child: LayerList()
            ),
            Positioned(
              top:100,
              left:20,
              child:Library()
            ),
            Positioned(
              top:20,
              left:30,
              child:CircularBorderlessButton(
                text:"",
                onPressed: ()=>Lighting,
                width: 35,
                height: 35,
                pathfile: 'assets/icon/sun.png'
              )
            ),
            Positioned(
              top:30,
              left:90,
              child:CircularBorderlessButton(
                text:"",
                onPressed: ()=>Mute,
                width: 35,
                height: 35,
                pathfile: 'assets/icon/volume.png'
              )
            ),

            //CREDITS
            Positioned(
              bottom: 10,
              left: 20,
              child: Text("Made by Leo",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              )
              ),
            ),
            //MEDIA
            Positioned(
              bottom: 10,
              right: 60,
              child: Container(
                width: 200,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Github clicked");
                      },
                      child: Text("Github"),
                    ),

                    GestureDetector(
                      onTap: () {
                        print("Discord clicked");
                      },
                      child: Text("Discord"),
                    ),

                    GestureDetector(
                      onTap: () {
                        print("Twitter clicked");
                      },
                      child: Text("Instagram")
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
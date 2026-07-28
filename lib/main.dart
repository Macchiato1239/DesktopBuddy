import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

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
class LayerData {
  final int id;
  final String name;

  LayerData(this.id, this.name);
}

class LayerManager extends ChangeNotifier {
  final List<LayerData> layers = [];

  void addLayer(LayerData layer) {
    layers.add(layer);
    notifyListeners();
  }

  void removeLayerById(int id) {
    layers.removeWhere((layer) => layer.id == id);
    notifyListeners();
  }
}

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
      home: Scaffold(
        appBar: AppBar(
          title: Text('Desktop Buddies!'),
          centerTitle: true,
        ),
        body: Stack(
          children: [ //IMPORT BUTTON
            Positioned(
              top: 20,
              left: 280,
              child: ElevatedButton(
                onPressed: import,
                child: const Text('Import'), // IT CNAJWOJNFIJOWAFIJOAFOIJW GO ANYWEHRE HHAHAHA
              ),
            ),
            Positioned(
              top:20,
              left: 500,
              child: LayerList()
            ),
            Positioned(
              top:0,
              left:10,
              child:Library()
            )
          ],
        ),
      ),
    );
  }
}
//Library Section

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 400,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(color: const Color.fromARGB(60, 0, 0, 0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text(
                "Library",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ElevatedButton(
                  onPressed: ()=>builtinLayer("TestIcon"),
                  child: const Text("Chud 1"),
                ),
                ElevatedButton(
                  onPressed: ()=>builtinLayer("flower"),
                  child: const Text("Chud 2"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//List of layers
//AnimatedBuilder is responsible for updating
//each box is a button, each carries an Id
//When click on any box, do a check for the id and 

class LayerList extends StatelessWidget {
  const LayerList({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Layer,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(width: 0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView.builder(
            itemCount: Layer.layers.length,
            itemBuilder: (context, index) {
              final layer = Layer.layers[index];

              return SizedBox(
                height: 40,
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(30, 30),
                      ),
                      onPressed: () => delete(layer.id),
                      child: const Text("-"),
                    ),
                    const SizedBox(width: 8),
                    Text(layer.name),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
//i should prolly make a button inside a sizedBox-->clicking on that button can instantly 
//delete its parent and its associated frame, i should connect the frame with the item in the table
// on its creation
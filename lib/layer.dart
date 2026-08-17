import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'main.dart';
import 'package:collection/collection.dart';
import 'focus.dart';

/// #THIS FILE CONTAINS THE CODE FOR THE LAYER MANAGER SECTION OF THE APP
class LayerData {
  final int id;
  int? displayNumber;
  String name;

  double x;
  double y;

  double width;
  double height;

  LayerData({
    required this.id,
    this.displayNumber,
    required this.name,

    this.x = 100,
    this.y = 100,
    this.width = 200,
    this.height = 200,
  });
}


enum LayerPropertyType {
  name,
  width,
  height,
  x,
  y,
}

class LayerManager extends ChangeNotifier {
  final List<LayerData> layers = [];
  int _nextId = 0 ;
  int _nextDisplayNumber = 1;
  final PriorityQueue<int> _freeDisplayNumbers = PriorityQueue<int>();
  void freeDisplayNumber(int displayNumber) {
  _freeDisplayNumbers.add(displayNumber);
  }
//FOCUSED layer property
  LayerData? focusedLayer;
  double? focusedWidth;
  double? focusedHeight;
  double? focusedX;
  double? focusedY;

  int reserveId() {
    return _nextId++;
  }
  int _getNextDisplayNumber() {
    if (_freeDisplayNumbers.isNotEmpty) {
      return _freeDisplayNumbers.removeFirst();
    }
    return _nextDisplayNumber++;
  }

  void importSuccess(int id) {

    final displayNumber = _getNextDisplayNumber();

    layers.add(
      LayerData(
        id: id,
        displayNumber: displayNumber,
        name: "Layer $displayNumber",
      ),
    );

    notifyListeners();
  }

  void addBuiltInLayer(LayerData layer) {
    layers.add(layer);
    notifyListeners();
  }

  void removeLayerById(int id) {
    final layer = layers.firstWhere(
      (layer) => layer.id == id,
    );

    // Release the display number
    if (layer.displayNumber!=null){
    _freeDisplayNumbers.add(layer.displayNumber!);
    }
    layers.remove(layer);

    notifyListeners();
  }
// Focus Section
  void focusLayer(int id) async{
    focusedLayer = layers.firstWhere(
      (layer) => layer.id == id,
    );
    await overlayChannel.invokeMethod(
    "displayInfo",
    {
      "id": id,
    }); //This function works for getting the id, but have to pass it to the focus section,
  }

void updateLayerInfo({
  required int id,
  required double width,
  required double height,
  required double x,
  required double y,
}) {
  final layer = layers.firstWhere(
    (layer) => layer.id == id,
  );

  layer.width = width;
  layer.height = height;
  layer.x = x;
  layer.y = y;

  notifyListeners();
}
}



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
            padding: EdgeInsets.zero,
            itemCount: Layer.layers.length,
            itemBuilder: (context, index) {
              final layer = Layer.layers[index];

              return GestureDetector( //This should send a request for the selected layer info to swift
                onTap: () {
                Layer.focusLayer(layer.id);
                },
                child: Container(
                  height: 40,
                  decoration:BoxDecoration(
                    color: Layer.focusedLayer?.id == layer.id
                    ? const Color.fromARGB(255, 199, 200, 200)
                    : const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(30, 30),
                        ),
                        onPressed: () => delete(layer.id),
                        child: const Text("-"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(30, 30),
                        ),
                        onPressed: () => toggleVisibility(layer.id),
                        child: const Text("X"),
                      ),
                      const SizedBox(width: 8),
                      Text(layer.name),
                    ],
                  ),
                )
              );
            },
          ),
        );
      },
    );
  }
}
//use final to prevent accidental reassigment

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'main.dart';
import 'package:collection/collection.dart';
/// #THIS FILE CONTAINS THE CODE FOR THE LAYER MANAGER SECTION OF THE APP


class LayerData {
  final int id;
  int? displayNumber;
  final String name;

  LayerData({
    required this.id,
    this.displayNumber,
    required this.name
  });
}


class LayerManager extends ChangeNotifier {
  final List<LayerData> layers = [];
  int _nextId = 0 ;
  int _nextDisplayNumber = 1;
  final PriorityQueue<int> _freeDisplayNumbers = PriorityQueue<int>();

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
}

//makes a focus constructor tmr, use it to change info of a layer (name, size, position, etc)
/*
class Focus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height:80,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5)
      ),
      child: Stack(
        children: [
          Positioned( //the layername
            top:5,
            left:5,
            child: LayerName() 
          ),
          Positioned( //the layer size
            left:5,
            top: 30,
            child: LayerSize()
          ),
          Positioned(
            left: 70,
            top: 30,
            child: LayerPosition()
          )
        ]
      )
    );
  }
}

class LayerName extends StatefulWidget {
  const LayerName({super.key});

  @override
  State<LayerName> createState() => _LayerNameState();
}

class _LayerNameState extends State<LayerName> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
      )
      child: 
    )
  }
}
*/
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
//use final to prevent accidental reassigment

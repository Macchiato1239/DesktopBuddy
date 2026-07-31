/// #THIS FILE CONTAINS THE CODE FOR THE LAYER MANAGER SECTION OF THE APP

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'main.dart';

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
//use final to prevent accidental reassigment

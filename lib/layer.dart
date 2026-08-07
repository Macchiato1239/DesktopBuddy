import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'main.dart';
import 'package:collection/collection.dart';

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

  LayerData? focusedLayer;

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
  void focusLayer(int id) {
    focusedLayer = layers.firstWhere(
      (layer) => layer.id == id,
    );

    notifyListeners();
  }

  void updateProperty(
    int id,
    LayerPropertyType property,
    String value,
  ) async{

    final layer = layers.firstWhere(
      (l) => l.id == id
    );

    switch(property){

      case LayerPropertyType.name:
        layer.name = value;
        break;

      case LayerPropertyType.width:
        layer.width = double.parse(value);
        break;

      case LayerPropertyType.height:
        layer.height = double.parse(value);
        break;

      case LayerPropertyType.x:
        layer.x = double.parse(value);
        break;

      case LayerPropertyType.y:
        layer.y = double.parse(value);
        break;
    }
    await overlayChannel.invokeMethod(
    "updateLayerProperty",
    {

      "id": id,

      "property": property,

      "value": value,

    });
    notifyListeners();
  }
}


/// ## FOCUS PANEL TO MODIFY INFO OF A SELECTED LAYER

class Focus extends StatelessWidget {
  const Focus({super.key});

  @override
  Widget build(BuildContext context) {
    final layer = Layer.focusedLayer;

    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
        ),
      ),
      child: Column(
        children: [

          LayerProperty(
            label: "Name",
            value: layer?.name ?? "",
            onUpdate: (value){
              if(layer == null) return;
               Layer.updateProperty(
                layer.id,
                LayerPropertyType.name,
                value,
              );

            },

          ),


          LayerProperty(
            label: "Width",
            value: layer == null
                ? ""
                : layer.width.toString(),
            onUpdate: (value){
              if(layer == null) return;
              Layer.updateProperty(
                layer.id,
                LayerPropertyType.width,
                value,
              );
            },
          ),

          LayerProperty(

            label: "Height",

            value: layer == null
                ? ""
                : layer.height.toString(),


            onUpdate: (value){

              if(layer == null) return;


              Layer.updateProperty(
                layer.id,
                LayerPropertyType.height,
                value,
              );

            },

          ),




          LayerProperty(

            label: "X",

            value: layer == null
                ? ""
                : layer.x.toString(),


            onUpdate: (value){

              if(layer == null) return;


              Layer.updateProperty(
                layer.id,
                LayerPropertyType.x,
                value,
              );

            },

          ),





          LayerProperty(

            label: "Y",

            value: layer == null
                ? ""
                : layer.y.toString(),


            onUpdate: (value){

              if(layer == null) return;


              Layer.updateProperty(
                layer.id,
                 LayerPropertyType.y,
                value,
              );

            },

          ),

        ],
      ),
    );
  }
}

//CONSTRUCTOR FOR width, height, x, y and name box
class LayerProperty extends StatefulWidget {

  final String label;
  final String value;

  final Function(String) onUpdate;


  const LayerProperty({
    super.key,
    required this.label,
    required this.value,
    required this.onUpdate,
  });


  @override
  State<LayerProperty> createState() => _LayerPropertyState();

}



class _LayerPropertyState extends State<LayerProperty> {

  bool editing = false;

  late TextEditingController controller;



  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.value,
    );
  }



  @override
  void didUpdateWidget(covariant LayerProperty oldWidget) {
    super.didUpdateWidget(oldWidget);


    if(oldWidget.value != widget.value){
      controller.text = widget.value;
    }
  }



  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {


    return SizedBox(

      height: 25,


      child: Row(

        children: [


          SizedBox(
            width: 60,
            child: Text(widget.label),
          ),



          GestureDetector(

            onDoubleTap: () {

              setState(() {
                editing = true;
              });

            },


            child: Container(

              width: 120,

              height: 20,


              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                ),
              ),


              child: editing

                  ? TextField(

                      controller: controller,

                      autofocus: true,


                      onSubmitted: (value){

                        widget.onUpdate(value);


                        setState(() {
                          editing = false;
                        });

                      },

                    )


                  : Padding(

                      padding:
                        const EdgeInsets.only(left:4),

                      child: Text(widget.value),

                    ),
            ),
          ),
        ],
      ),
    );
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

              return GestureDetector(
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

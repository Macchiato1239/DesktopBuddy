import 'package:flutter/material.dart';
import 'main.dart';
//SHOULD ERASE WHEN DELETED
/// 
//when does the focus sec get updated?
//1. Clicking on a new/different layer-->GestureDetector 
//-->Send id to swift, swift gets the layer and sends info back to dart
//2. Dragging
//Every drag actions trigger a function in swift, instantly sends id and info the dart, if id same as the one
//being display-->change-->else do nothing
//to reduce lag, i should prolly reduce the update speed to 30 fps
//3. Manually changing the property/inline editing
//-->sends the change to swift and change the value being displayed
//-->i can prolly just write one function that detects change in movement or size, if name then just keep it dart side
class FocusSec extends StatelessWidget {
  const FocusSec({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Layer,
      builder: (context, child) {

        return Container(
          width:250,
          height:210,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 247, 217),
            border: Border.all(color: const Color.fromARGB(220, 255, 191, 107),width: 2),
          ),
          child:
            Stack(
              children:[
                Positioned(
                  left: 10,
                  top: 10,
                  child: LayerProperty(
                    label: "Name",
                    value: Layer.focusedLayer?.name ?? "",
                    onUpdate: (value) {
                      final layer = Layer.focusedLayer;

                      if (layer == null) return;
                      final displayNumber = layer.displayNumber;

                      layer.name=value;
                      if (displayNumber!=null){
                        Layer.freeDisplayNumber(displayNumber);
                        layer.displayNumber=null; //cannot access due to the_
                        }
                      Layer.notifyListeners()
                      ; //should make it so that it counts as a removal from the id list
                    },
                  ),
                ),

                Positioned(
                  left:10,
                  top: 40,
                  child: LayerProperty(
                      label: "Width",
                      value:  Layer.focusedWidth?.toString() ?? "",
                      onUpdate: (value) {
                        final layer = Layer.focusedLayer;

                        if (layer == null) return;

                        modifyLayer(
                          id: layer.id,
                          property: "width",
                          change: value,
                        );
                      },
                    ),
                  ),

                  Positioned(
                    left:10, 
                    top: 70,
                    child: LayerProperty(
                      label: "Height",
                      value: Layer.focusedHeight?.toString() ?? "",
                      onUpdate: (value) {
                        final layer = Layer.focusedLayer;

                        if (layer == null) return;

                        modifyLayer(
                          id: layer.id,
                          property: "height",
                          change: value,
                        );
                      },
                    ),
                  ),


                  Positioned(
                    left:10,
                    top: 100,
                    child: LayerProperty(
                      label: "X",
                      value: Layer.focusedX?.toString() ?? "",
                      onUpdate: (value) {
                        final layer = Layer.focusedLayer;

                        if (layer == null) return;

                        modifyLayer(
                          id: layer.id,
                          property: "x",
                          change: value,
                        );
                      },
                    ),
                  ),


                  Positioned(
                    left: 10,
                    top: 130,
                    child:LayerProperty(
                      label: "Y",
                      value: Layer.focusedY?.toString() ?? "",
                      onUpdate: (value) {
                        final layer = Layer.focusedLayer;

                        if (layer == null) return;

                        modifyLayer(
                          id: layer.id,
                          property: "y",
                          change: value,
                        );
                      },
                    ),
                  ),
                ],
              )
          );
        },
      );
    }
  }


void modifyLayer({
  required int id,
  required String property,
  required String change, 
}) async{
    await overlayChannel.invokeMethod(
    "modifyProperty",
    {
      "id": id,
      "property": property,
      "change": change,
    },
  );
}


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
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(widget.label,
              style: TextStyle(
              color: Color.fromARGB(220, 255, 145, 0), 
              ),
            ),
          ),

          GestureDetector(
            onDoubleTap: () {
              setState(() {
                editing = true;
              });

            },
            child: Container(

              width: 150,
              height: 20,

              decoration: BoxDecoration( // i should prolly decorate this later
                    border: Border(
                      bottom: BorderSide(
                        color: const Color.fromARGB(220, 255, 191, 107),  // Border color
                        width: 2,          // Border thickness
                        style: BorderStyle.solid, // Border style (solid or none)
                      ),
                    ),
              ),

              child: editing
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      onSubmitted: (value){
                        widget.onUpdate(value); //on submit->Change the value of the focus layer
                        //send message to swift and modify the property of the layer

                        setState(() {
                          editing = false;
                        });
                      },
                    )

                  : Padding(
                      padding:
                        const EdgeInsets.only(left:4),
                      child: Text(widget.value,
                          style: TextStyle(
                          color: Color.fromARGB(220, 255, 157, 29), 
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'main.dart';
import 'layer.dart';
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

        return Column(
          children:[
              LayerProperty(
                label: "Name",
                value: Layer.focusedLayer?.name ?? "",
                onUpdate: (value){
                },

              ),

              LayerProperty(
                label: "Width",
                value:  Layer.focusedWidth?.toString() ?? "",
                onUpdate: (value){
                },
              ),

              LayerProperty(
                label: "Height",
                value: Layer.focusedHeight?.toString() ?? "",
                onUpdate: (value){
                },
              ),

              LayerProperty(
                label: "X",
                value: Layer.focusedX?.toString() ?? "",
                onUpdate: (value){
                },
              ),

              LayerProperty(
                label: "Y",
                value: Layer.focusedY?.toString() ?? "",
                onUpdate: (value){
                },
              ),
            ],
          );
        },
      );
    }
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
              height: 40,

              decoration: BoxDecoration( // i should prolly decorate this later
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

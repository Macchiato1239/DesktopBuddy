import 'package:flutter/material.dart';
//button builder
class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed; //the passed function

  final double width;
  final double height;

  final double top;
  final double left;

  final String pathfile;


  const CustomButton({
    super.key,

    this.text="",
    required this.onPressed,
    required this.pathfile,

    this.width = 60,
    this.height = 60, //default value if none is provided

    this.top = 0,
    this.left = 0,
  });



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          pathfile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


class CircularButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed; //the passed function

  final double width;
  final double height;

  final double top;
  final double left;

  final String pathfile;


  const CircularButton({
    super.key,

    this.text="",
    required this.onPressed,
    required this.pathfile,

    this.width = 60,
    this.height = 60, //default value if none is provided

    this.top = 0,
    this.left = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: Image.asset(
          pathfile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
//whenever creates a button, use CustomButton(text,func,width,height,top,left,pathfile)
void Lighting() {
  print("Dark");
}
// GLobal Audio Toggle
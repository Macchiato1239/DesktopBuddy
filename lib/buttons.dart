import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //open external websites
//button builder
class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed; //the passed function

  final double width;
  final double height;

  final String pathfile;


  const CustomButton({
    super.key,

    this.text="",
    required this.onPressed,
    required this.pathfile,

    this.width = 60,
    this.height = 60, //default value if none is provided


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

  final String pathfile;


  const CircularButton({
    super.key,

    this.text="",
    required this.onPressed,
    required this.pathfile,

    this.width = 60,
    this.height = 60, //default value if none is provided


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

class CircularBorderlessButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed; //the passed function

  final double width;
  final double height;

  final String pathfile;


  const CircularBorderlessButton({
    super.key,

    this.text="",
    required this.onPressed,
    required this.pathfile,

    this.width = 60,
    this.height = 60, //default value if none is provided
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
void Mute() {
  print("Mute");
}

void Github() async {
  final Uri url=Uri.parse("https://github.com/Macchiato1239");
    if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  } //Uri=unified resource identifier
}

void Instagram() async{
  final Uri url=Uri.parse("https://www.instagram.com/machiatto1239/");
    if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication, //externalApplication=client's default browser
  )) {
    throw Exception('Could not launch $url');
  } 
}

void Portfolio() async{
  print("Portfolio is still in development");
}
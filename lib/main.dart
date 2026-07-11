import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}
//----------------------------------
const overlayChannel = MethodChannel('overlay_window');

void showOverlay() async {
  await overlayChannel.invokeMethod('showOverlay');
}
//----------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
//----------------------------------
class _MyAppState extends State<MyApp> {
  String changingtext = 'Tung';

  void changeText() {
    setState(() {
      if (changingtext == 'Tung') {
        changingtext = 'Tung Tung';
      } else {
        changingtext = 'Tung Tung Sahur';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(changingtext),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: showOverlay,
                child: const Text('+'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
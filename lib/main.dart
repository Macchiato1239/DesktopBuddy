import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}
//----------------------------------
const overlayChannel = MethodChannel('overlay_window');
Future<void> showOverlay() async {
  await overlayChannel.invokeMethod('showOverlay');
}
Future<void> destroyOverlay() async {
  await overlayChannel.invokeMethod('destroyOverlay');
}
Future<void> import() async {
  await overlayChannel.invokeMethod('ImportImg');
}
//----------------------------------
//----------------------------------
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Master Window'),
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
            Positioned(
              top: 20,
              left: 100,
              child: ElevatedButton(
                onPressed: destroyOverlay,
                child: const Text('-'),
              ),
            ),
            Positioned(
              top: 20,
              left: 280,
              child: ElevatedButton(
                onPressed: import,
                child: const Text('Import'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ShadowDrop extends StatelessWidget {
  final int width;
  final int height;

  const ShadowDrop(this.width, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: const BoxDecoration(
        color: Color.fromARGB(220, 255, 170, 60),
      ),
    );
  }
}
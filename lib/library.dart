
/// # THIS FILE CONTAINS THE CODE FOR THE LIBRARY OF BUILT IN ASSETS, provided by Leo

import 'package:flutter/material.dart';
import 'main.dart';
class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 400,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(color: const Color.fromARGB(60, 0, 0, 0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text(
                "Library",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
              ),
            ),
          ),

          Expanded(
            child: Stack( // use stack instead for better positioning
              children: [
                Positioned(
                  left: 30,
                  top: 10,
                  child: ElevatedButton(
                    onPressed: () => builtinLayer("TestIcon"),
                    child: const Text("Chud 1"),
                  ),
                ),

                Positioned(
                  left: 30,
                  top: 70,
                  child: ElevatedButton(
                    onPressed: () => builtinLayer("flower"),
                    child: const Text("Chud 2"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

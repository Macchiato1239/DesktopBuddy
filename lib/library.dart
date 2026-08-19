
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
        color: const Color.fromARGB(255, 255, 247, 217),
        border: Border.all(color: const Color.fromARGB(220, 255, 191, 107), width:2),
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
                  left: 50,
                  top: 10,
                  child: ElevatedButton(
                      onPressed: () => builtinLayer("assets/PNGs/noob.png","noob"),
                      child: const Text(
                        "Noob",
                        style: TextStyle(
                          color: Color.fromARGB(220, 255, 145, 0),
                        ),
                      ), //lowkey should have used oop to organize my code
                      style: ElevatedButton.styleFrom(
                      minimumSize: const Size(110, 40),
                      backgroundColor: const Color.fromARGB(255, 255, 247, 217),
                      side: const BorderSide(
                        color: Color.fromARGB(220, 255, 191, 107),                // Border color
                        width: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 50,
                  top: 70,
                  child: ElevatedButton(
                    onPressed: () => builtinLayer("assets/Gif/doodle.gif","doodle"),
                    child: const Text(
                        "Doodle",
                        style: TextStyle(
                          color: Color.fromARGB(220, 255, 145, 0), 
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                      minimumSize: const Size(110, 40),
                      backgroundColor: const Color.fromARGB(255, 255, 247, 217),
                      side: const BorderSide(
                        color: Color.fromARGB(220, 255, 191, 107),                // Border color
                        width: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
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

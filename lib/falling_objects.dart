import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spectrum_chase/models/falling_object.dart';

class FallingObjectsPage extends StatefulWidget {
  @override
  _FallingObjectsPageState createState() => _FallingObjectsPageState();
}

const double objectSpeed = 7.0;

class _FallingObjectsPageState extends State<FallingObjectsPage> {
  double basketPosition = 0.0;
  double objectSize = 40.0;
  List<FallingObject> fallingObjects = [];
  int score = 0;
  Color selectedColor = Colors.red;
  bool gameOver = false;
  GlobalKey basketKey = GlobalKey();

  void resetGame() {
    setState(() {
      fallingObjects.clear();
      score = 0;
      basketPosition = 0.0;
    });
  }

  void startFallingObjects() {
    const duration = Duration(milliseconds: 800);
    Timer.periodic(duration, (timer) {
      generateFallingObject();
    });
    const updateDuration = Duration(milliseconds: 50);
    Timer.periodic(updateDuration, (timer) {
      updateObjectsPosition();
      detectCollisions();
    });
  }

  Color generateRandomColorFromList() {
    List<Color> predefinedColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    Random random = Random();
    return predefinedColors[random.nextInt(predefinedColors.length)];
  }

  void generateFallingObject() {
    setState(() {
      fallingObjects.add(
        FallingObject(
          opacity: 1,
          color: generateRandomColorFromList(),
          top: 0,
          left: getRandomPosition(),
        ),
      );
    });
  }

  double getRandomPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Random().nextDouble() * (screenWidth - objectSize);
  }

  void updateObjectsPosition() {
    setState(() {
      fallingObjects = fallingObjects
          .map((object) {
            return FallingObject(
              opacity: object.opacity,
              top: object.top + objectSpeed,
              color: object.color,
              left: object.left,
            );
          })
          .where((object) => object.top < MediaQuery.of(context).size.height)
          .toList();
    });
  }

  void detectCollisions() {
    final double sliderBottom = MediaQuery.of(context).size.height - 30;

    final basketBox = Rect.fromLTWH(
      basketPosition,
      sliderBottom,
      80,
      80,
    );

    for (int i = 0; i < fallingObjects.length; i++) {
      final objectBox = Rect.fromLTWH(
        fallingObjects[i].left,
        fallingObjects[i].top,
        objectSize,
        objectSize,
      );

      if (isBoxVisible(objectBox, sliderBottom) &&
          boxIntersect(basketBox, objectBox)) {
        if (selectedColor == fallingObjects[i].color) {
          score++;
        } else {
          resetGame();
          gameOver = true;
        }
      }
    }
  }

  bool boxIntersect(Rect a, Rect b) {
    return (a.left < b.right &&
        a.right > b.left &&
        a.top < b.bottom &&
        a.bottom > b.top);
  }

  bool isBoxVisible(Rect box, double sliderBottom) {
    return box.bottom > 0 && box.top < sliderBottom;
  }

  void moveBasket(double delta) {
    setState(() {
      basketPosition = (basketPosition + delta)
          .clamp(0.0, MediaQuery.of(context).size.width - 80);
    });
  }

  @override
  void initState() {
    super.initState();
    startFallingObjects();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: gameOver
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      gameOver = false;
                    });
                  },
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Game Over',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      Text(
                        'Try Again',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff171648), Color(0xff301585)])),
              child: Stack(
                children: [
                  ...fallingObjects.map((object) {
                    return Positioned(
                      top: object.top,
                      left: object.left,
                      child: Opacity(
                        opacity: object.opacity,
                        child: Container(
                          key: object.key,
                          width: objectSize,
                          height: objectSize,
                          decoration: BoxDecoration(color: object.color),
                          child: Center(
                            child: Image.asset('lib/assets/2938687.png'),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: AssetImage('lib/assets/4399411.png'),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$score',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: basketPosition,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        moveBasket(details.primaryDelta!);
                      },
                      child: Container(
                        key: basketKey,
                        width: 80,
                        height: 80,
                        color: Colors.transparent,
                        child: Image.asset(
                          'lib/assets/shopping-basket-icon-2048x1742-42o8ifn2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spectrum_chase/models/falling_object.dart';

void main() {
  runApp(MyApp());
}

const double objectSpeed = 5.0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Falling Objects Game'),
        ),
        body: FallingObjectsPage(),
      ),
    );
  }
}

class FallingObjectsPage extends StatefulWidget {
  @override
  _FallingObjectsPageState createState() => _FallingObjectsPageState();
}

class _FallingObjectsPageState extends State<FallingObjectsPage> {
  double basketPosition = 0.0;
  double objectSize = 50.0;
  List<FallingObject> fallingObjects = [];
  int score = 0;
  Color selectedColor = Colors.red;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    startFallingObjects();
  }

  @override
  Widget build(BuildContext context) {
    return gameOver ?
    Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
        child: GestureDetector(
          onTap: (){
            setState(() {
              gameOver = false;
            });
          },
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25
              ),),
              Text('Try Again',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24
                ),),
            ],
          ),
        ),
      ),
    ) :
    Stack(
      children: [
        Positioned(
          bottom: 10,
          left: basketPosition,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              moveBasket(details.primaryDelta!);
            },
            child: Container(
              width: 80,
              height: 20,
              color: Colors.blue,
            ),
          ),
        ),
        ...fallingObjects.map((object) {
          return Positioned(
            top: object.top,
            left: object.left,
            child: Opacity(
              opacity: object.opacity,
              child: PhysicalModel(
                color: object.color,
                elevation: 5,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Container(
                  width: objectSize,
                  height: objectSize,
                  decoration: BoxDecoration(
                      color: object.color, shape: BoxShape.circle),
                ),
              ),
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            'Score: $score',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

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
      20,
    );

    for (int i = 0; i < fallingObjects.length; i++) {
      final objectBox = Rect.fromLTWH(
        fallingObjects[i].left,
        fallingObjects[i].top,
        objectSize,
        objectSize,
      );

      // Check for collision using the refined conditions
      final collide = (objectBox.left < basketBox.right &&
          objectBox.right > basketBox.left &&
          objectBox.top < basketBox.bottom &&
          objectBox.bottom > basketBox.top);

      // Check for collision based on bounding boxes
      if (collide) {
        if (selectedColor == fallingObjects[i].color) {
          score++;
        }else{
          resetGame();
          gameOver = true;
        }
      }
    }
  }

  void moveBasket(double delta) {
    setState(() {
      basketPosition = (basketPosition + delta)
          .clamp(0.0, MediaQuery.of(context).size.width - 80);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_chase/models/falling_object.dart';

import 'game_over.dart';

class FallingObjectsPage extends StatefulWidget {
  @override
  _FallingObjectsPageState createState() => _FallingObjectsPageState();
}

double objectSpeed = 6.0;

class _FallingObjectsPageState extends State<FallingObjectsPage> {
  bool isPaused = false;
  double basketPosition = 0.0;
  double objectSize = 40.0;
  List<FallingObject> fallingObjects = [];
  int score = 0;
  Color selectedColor = Colors.red;
  bool gameOver = false;
  GlobalKey basketKey = GlobalKey();
  /// variables regarding audio ///
  late AudioPlayer advancedPlayer;
  late AudioPlayer effectsPlayer;
  String gameMusicString = "game_music.wav";
  String bonusMusicString = "bonus.wav";
  String completionMusicString = "completion.wav";

  void initPlayer() {
    advancedPlayer = AudioPlayer();
    effectsPlayer = AudioPlayer();
    advancedPlayer.play(AssetSource(gameMusicString),volume: .4);
    advancedPlayer.onPlayerStateChanged.listen(
          (it) {
            switch (it) {
          case PlayerState.playing:
            if(gameOver){
              advancedPlayer.stop();
            }
            break;
          case PlayerState.stopped:
            break;
          case PlayerState.completed:
            if(!gameOver){
              advancedPlayer.play(AssetSource(gameMusicString),volume: .4);
            }else{
              advancedPlayer.stop();
            }
            break;
          default:
            break;
        }
      },
    );
  }

  void increaseSpeed() {
    setState(() {
      objectSpeed += .1;
    });
  }

  void changeSelectedColor() {
    setState(() {
      selectedColor = generateRandomColorFromList();
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if(isPaused){
        advancedPlayer.stop();
      }else{
        advancedPlayer.play(AssetSource(gameMusicString),volume: .4);
      }
    });
  }

  void resetGame() {
    setState(() {
      changeSelectedColor();
      objectSpeed = 5;
      fallingObjects.clear();
      score = 0;
      basketPosition = (MediaQuery.of(context).size.width / 2) - 42.5;
      initPlayer();
    });
  }

  void startFallingObjects() {
    const duration = Duration(milliseconds: 800);
    Timer.periodic(duration, (timer) {
      if (!isPaused) {
        generateFallingObject();
      }
    });
    const updateDuration = Duration(milliseconds: 50);
    Timer.periodic(updateDuration, (timer) {
      if (!isPaused) {
        updateObjectsPosition();
        detectCollisions();
      }
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
          top: 80,
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
          try{effectsPlayer.play(AssetSource(bonusMusicString));}catch(e){}
          score++;
          if (score % 5 == 0) {
            increaseSpeed();
          }
        } else {
          try{effectsPlayer.play(AssetSource(completionMusicString));}catch(e){}
          isPaused = true;
          gameOver = true;
        }
      }
    }
  }

  bool boxIntersect(Rect objectBox, Rect sliderBottom) {
    return (objectBox.left < sliderBottom.right &&
        objectBox.right > sliderBottom.left &&
        objectBox.top - 80 < sliderBottom.bottom &&
        objectBox.bottom > sliderBottom.top);
  }

  bool isBoxVisible(Rect box, double sliderBottom) {
    return box.bottom > 0 && box.top < sliderBottom;
  }

  void moveBasket(double delta) {
    if (!isPaused) {
      setState(() {
        basketPosition = (basketPosition + delta)
            .clamp(0.0, MediaQuery.of(context).size.width - 80);
      });
    }
  }

  void gameOverFunction() {
    setState(() {
      resetGame();
      isPaused = false;
      gameOver = false;
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      basketPosition = (MediaQuery.of(context).size.width / 2) - 42.5;
      try{initPlayer();}catch(e){}
      startFallingObjects();
    });
  }

  @override
  void dispose() {
    advancedPlayer.stop();
    advancedPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return gameOver
        ? GameOver(
            gameOverFunction: gameOverFunction,
            score: score,
          )
        : Container(
            padding: const EdgeInsets.only(top: 38),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff171648), Color(0xff301585)])),
            child: Stack(
              children: [
                /// Falling Objects ///
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
                        decoration: BoxDecoration(
                            color: object.color,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4))),
                        child: Center(
                          child: Image.asset('lib/assets/2938687.png'),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                /// Score and top elements ///
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              togglePause();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$score',
                                style: GoogleFonts.raleway(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.white,
                                    fontSize: 39,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Score'.toUpperCase(),
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Catch',
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 13.76,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    width: objectSize / 1.5,
                                    height: objectSize / 1.5,
                                    decoration: BoxDecoration(
                                        color: selectedColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4))),
                                    child: Center(
                                      child:
                                          Image.asset('lib/assets/2938687.png'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),

                /// Basket ///
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
          );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_chase/models/falling_object.dart';
import 'package:spectrum_chase/pages/settings_page.dart';
import 'package:spectrum_chase/services/ads_service.dart';

import 'game_over.dart';

class FallingObjectsPage extends StatefulWidget {
  @override
  _FallingObjectsPageState createState() => _FallingObjectsPageState();
}

double objectSpeed = 5.5;

class _FallingObjectsPageState extends State<FallingObjectsPage> {
  bool showInstructions = false;
  bool showAd = false;
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
  AdsService adsService = AdsService();
  late FallingObject selectedFallingObject;

  void initPlayer() {
    advancedPlayer = AudioPlayer();
    effectsPlayer = AudioPlayer();
    advancedPlayer.play(AssetSource(gameMusicString),volume: musicVolume);
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
              advancedPlayer.play(AssetSource(gameMusicString),volume: musicVolume);
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
        advancedPlayer.play(AssetSource(gameMusicString),volume: musicVolume);
      }
    });
  }

  void resetGame() {
    setState(() {
      changeSelectedColor();
      objectSpeed = 5.5;
      fallingObjects.clear();
      score = 0;
      basketPosition = (MediaQuery.of(context).size.width / 2) - 42.5;
      initPlayer();
      showInstructionsFunction();
    });
  }

  void startFallingObjects() {
    Duration duration = Duration(milliseconds: objectSpeed > 8 ? 600 : 800);
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
              top: object.top + (objectSpeed > 8 ? objectSpeed/2 : objectSpeed),
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
          try{effectsPlayer.play(AssetSource(bonusMusicString),volume: effectsVolume);}catch(e){}
          score++;
          fallingObjects[i].opacity = 0;
          if (score % 5 == 0) {
            increaseSpeed();
          }
        } else {
          try{effectsPlayer.play(AssetSource(completionMusicString),volume: effectsVolume);}catch(e){}
          if(!showAd){
            showAdFunction();
            selectedFallingObject = fallingObjects[i];
          }
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

  showInstructionsFunction(){
    showInstructions = true;
    isPaused = true;
    setState(() {});
    Timer(const Duration(seconds: 1), () {
      setState(() {
        showInstructions = false;
        isPaused = false;
      });
    });
  }

  showAdFunction(){
    showAd = true;
    isPaused = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      adsService.createRewardedAd();
      showInstructionsFunction();
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

                /// Color to catch dialogue ///
                if (showInstructions)
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: 1.0,
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child:  Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Try to Catch',
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Container(
                                    width: 80,
                                    height: 80,
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
                        ),
                      ),
                    ),
                  ),

                /// show continue to watch ad and preserve score ///
                if (showAd)
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: 1.0,
                    child: Container(
                      color: Colors.black.withOpacity(0.75),
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Turn Defeat into Triumph\n\nWatch an ad to keep the score and continue',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        try{
                                          advancedPlayer.pause();
                                          adsService.showRewardedAd(
                                            doneFunction: (){
                                              setState(() {
                                                objectSpeed = 5.5;
                                                advancedPlayer.resume();
                                                fallingObjects.clear();
                                                isPaused = false;
                                                showAd = false;
                                              });
                                            }
                                          );
                                        }catch(e){
                                          print('error with ad: $e');
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [Color(0xffdf446b), Color(0xaadf446b)]),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Text(
                                            'Watch Ad',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context).textTheme.displayLarge,
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                    .size.width * .042,
                                                height: 1.23,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right:15.0,left: 15),
                                  child: GestureDetector(
                                    onTap: (){
                                      isPaused = true;
                                      gameOver = true;
                                      advancedPlayer.stop();
                                      showAd = false;
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [Color(0xffdf446b), Color(0xaadf446b)]),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Text(
                                            'Accept Defeat',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context).textTheme.displayLarge,
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                    .size.width * .042,
                                                height: 1.23,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

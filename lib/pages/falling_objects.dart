import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrum_chase/constants.dart';
import 'package:spectrum_chase/data/data_storage_service.dart';
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
  Color selectedColor = Colors.green;
  String selectedIcon = 'lib/assets/moon.png';
  bool gameOver = false;
  GlobalKey basketKey = GlobalKey();
  int protectionSecondsRemaining = 0;
  late Timer timer;

  /// variables regarding audio ///
  late AudioPlayer advancedPlayer;
  late AudioPlayer effectsPlayer;
  String gameMusicString = "game_music.mp3";
  String bonusMusicString = "bonus.wav";
  String completionMusicString = "completion.wav";
  AdsService adsService = AdsService();
  late FallingObject selectedFallingObject;

  void startTimerForProtection() {
    if (protectionSecondsRemaining > 0) {
      return;
    }
    protectionSecondsRemaining = 7;
    const oneSec = const Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        setState(() {
          if (protectionSecondsRemaining < 1) {
            timer.cancel();
          } else {
            protectionSecondsRemaining--;
          }
        });
      },
    );
  }

  void initPlayer() {
    advancedPlayer = AudioPlayer();
    effectsPlayer = AudioPlayer();
    advancedPlayer.play(AssetSource(gameMusicString), volume: musicVolume);
    advancedPlayer.onPlayerStateChanged.listen(
      (it) {
        switch (it) {
          case PlayerState.playing:
            if (gameOver) {
              advancedPlayer.stop();
            }
            break;
          case PlayerState.stopped:
            break;
          case PlayerState.completed:
            if (!gameOver) {
              advancedPlayer.play(AssetSource(gameMusicString),
                  volume: musicVolume);
            } else {
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
      if (Constants.selectedGameType == 'colors') {
        selectedColor = generateRandomColorFromList();
      } else {
        selectedColor = Colors.transparent;
        selectedIcon = generateRandomSunOrMoon();
      }
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        advancedPlayer.stop();
        Future.delayed(const Duration(seconds: 3), () {
          adsService.showInterstitialAd();
        });
      } else {
        advancedPlayer.play(AssetSource(gameMusicString), volume: musicVolume);
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
      Colors.green,
      Colors.red,
      Colors.deepPurpleAccent,
      Colors.brown,
      Colors.amber,
      Colors.blueGrey,
    ];

    Random random = Random();
    return predefinedColors[random.nextInt(predefinedColors.length)];
  }

  String generateRandomSunOrMoon() {
    List<String> predefinedStrings = [
      'lib/assets/moon.png',
      'lib/assets/sun.png'
    ];

    Random random = Random();
    return predefinedStrings[random.nextInt(predefinedStrings.length)];
  }

  void generateFallingObject() {
    setState(() {
      // Set the probability of generating a present
      bool isPresent = Random().nextInt(100) < 6;
      // Set the probability of generating a shield
      bool isShield = Random().nextInt(100) < 3;

      FallingObjectType objectType;

      if (isPresent) {
        objectType = FallingObjectType.PRESENT;
      } else if (isShield) {
        objectType = FallingObjectType.SHIELD;
      } else {
        objectType = FallingObjectType.NORMAL;
      }

      fallingObjects.add(
        FallingObject(
          opacity: 1,
          icon: Constants.selectedGameType == 'colors'
              ? 'lib/assets/2938687.png'
              : generateRandomSunOrMoon(),
          color: Constants.selectedGameType == 'colors'
              ? generateRandomColorFromList()
              : Colors.transparent,
          top: 80,
          left: getRandomPosition(),
          type: objectType,
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
              top: object.top +
                  (objectSpeed > 8 ? objectSpeed / 2 : objectSpeed),
              icon: object.icon,
              color: object.color,
              type: object.type,
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
        if(fallingObjects[i].type == FallingObjectType.SHIELD){
          startTimerForProtection();
          fallingObjects[i].opacity = 0;
        }else{
          /// For gaming colors ///
          if (Constants.selectedGameType == 'colors') {
            if (selectedColor == fallingObjects[i].color ||
                fallingObjects[i].type == FallingObjectType.PRESENT) {
              try {
                effectsPlayer.play(AssetSource(bonusMusicString),
                    volume: effectsVolume);
              } catch (e) {}
              if (fallingObjects[i].type == FallingObjectType.PRESENT) {
                score += 2;
              } else {
                score++;
              }
              fallingObjects[i].opacity = 0;
              if (score % 5 == 0) {
                objectSize += .1;
                increaseSpeed();
              }
            } else {
              if(protectionSecondsRemaining == 0){
                try {
                  effectsPlayer.play(AssetSource(completionMusicString),
                      volume: effectsVolume);
                } catch (e) {}
                if (!showAd) {
                  showAdFunction();
                  selectedFallingObject = fallingObjects[i];
                }
              }
            }
          }
          /// For Sun and moon game ///
          else {
            if (selectedIcon == fallingObjects[i].icon ||
                fallingObjects[i].type == FallingObjectType.PRESENT) {
              try {
                effectsPlayer.play(AssetSource(bonusMusicString),
                    volume: effectsVolume);
              } catch (e) {}
              if (fallingObjects[i].type == FallingObjectType.PRESENT) {
                score += 2;
              } else {
                score++;
              }
              fallingObjects[i].opacity = 0;
              if (score % 5 == 0) {
                increaseSpeed();
                objectSize += .1;
              }
            } else {
              if(protectionSecondsRemaining == 0){
                try {
                  effectsPlayer.play(AssetSource(completionMusicString),
                      volume: effectsVolume);
                } catch (e) {}
                if (!showAd) {
                  showAdFunction();
                  selectedFallingObject = fallingObjects[i];
                }
              }
            }
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

  showInstructionsFunction() {
    showInstructions = true;
    isPaused = true;
    setState(() {});
    Timer(const Duration(milliseconds: 1720), () {
      setState(() {
        showInstructions = false;
        isPaused = false;
      });
    });
  }

  showAdFunction() {
    showAd = true;
    isPaused = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    adsService.createBannerAd();
    adsService.createInterstitialAd();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        objectSpeed = 5.5;
        if (Constants.selectedGameType != 'colors') {
          selectedColor = Colors.transparent;
          selectedIcon = generateRandomSunOrMoon();
        }
      });
      showInstructionsFunction();
      basketPosition = (MediaQuery.of(context).size.width / 2) - 42.5;
      try {
        initPlayer();
      } catch (e) {}
      startFallingObjects();
    });
  }

  @override
  void dispose() {
    advancedPlayer.stop();
    advancedPlayer.dispose();
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        DataStorageManager dataStorageManager = DataStorageManager(prefs);
        Map userMapSaved = dataStorageManager.getMap('user_statistics');
        if (userMapSaved.isNotEmpty) {
          if (userMapSaved['score'] < score) {
            userMapSaved['score'] = score;
            dataStorageManager.setMap('user_statistics', userMapSaved);
          }
        }
        setState(() {});
      });
    } catch (e) {}
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
            decoration:
                BoxDecoration(gradient: Constants.selectedBackgroundColor),
            child: Stack(
              children: [
                /// Falling Objects ///
                ...fallingObjects.map((object) {
                  return Positioned(
                    top: object.top,
                    left: object.left,
                    child: Opacity(
                      opacity: object.opacity,
                      child: Transform.scale(
                        scale: object.type == FallingObjectType.PRESENT ? 2 : 1,
                        child: Container(
                          key: object.key,
                          width: objectSize,
                          height: objectSize,
                          decoration: BoxDecoration(
                              color: object.type == FallingObjectType.PRESENT
                                  || object.type == FallingObjectType.SHIELD
                                  ? Colors.transparent
                                  : object.color,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4))),
                          child: Center(
                            child: Image.asset(
                                object.type == FallingObjectType.PRESENT
                                    ? 'lib/assets/gift.png'
                                    : object.type == FallingObjectType.SHIELD?
                                    'lib/assets/sheild.png'
                                    : object.icon),
                          ),
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
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
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
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: Text(
                                    'Score'.toUpperCase(),
                                    style: GoogleFonts.raleway(
                                      color: Colors.white,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$score',
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 35,
                                      height: 1,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  protectionSecondsRemaining != 0 ?
                                  Padding(
                                    padding: const EdgeInsets.only(right:8.0),
                                    child: Column(
                                      children: [
                                        /// Shield elements top ///
                                        Padding(
                                          padding: const EdgeInsets.only(top: 18.0),
                                          child: Container(
                                              width: 35,
                                              height: 35,
                                              child: Image.asset('lib/assets/sheild.png')),
                                        ),
                                        Text(
                                          '$protectionSecondsRemaining',
                                          style: GoogleFonts.raleway(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge,
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ) : Container(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                              color: selectedColor,
                                              borderRadius: const BorderRadius.all(
                                                  Radius.circular(4))),
                                          child: Center(
                                            child:
                                            Constants.selectedGameType == 'colors'
                                                ? Image.asset(
                                                'lib/assets/2938687.png')
                                                : Image.asset(selectedIcon),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Catch',
                                        style: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .displayLarge,
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                ),

                /// Basket ///
                Positioned(
                  bottom: 10,
                  left: basketPosition,
                  child: Container(
                    key: basketKey,
                    width: 80,
                    height: 80,
                    color: Colors.transparent,
                    child: Image.asset(
                      Constants.selectedBasket,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// Controller ///
                Positioned(
                  right: 0,
                  left: 0,
                  top: MediaQuery.of(context).size.height * .15,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      moveBasket(details.primaryDelta!);
                    },
                    child: Container(color: Colors.transparent),
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
                          child: Padding(
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
                                      fontSize: 16,
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
                                          Constants.selectedGameType == 'colors'
                                              ? Image.asset(
                                                  'lib/assets/2938687.png')
                                              : Image.asset(selectedIcon),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Move the basket by moving your finger left and right on the screen',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
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
                      color: Colors.black.withOpacity(0.98),
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
                                    onTap: () {
                                      setState(() {
                                        try {
                                          advancedPlayer.pause();
                                          adsService.createRewardedAd(
                                              placementId: 'Rewarded_Android4',
                                              doneFunction: () {
                                            setState(() {
                                              objectSpeed = 5.5;
                                              advancedPlayer.resume();
                                              fallingObjects.clear();
                                              isPaused = false;
                                              showAd = false;
                                            });
                                          });
                                        } catch (e) {
                                          print('error with ad: $e');
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xffdf446b),
                                              Color(0xaadf446b)
                                            ]),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Text(
                                            'Watch Ad',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.raleway(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge,
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .042,
                                                height: 1.23,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, left: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      isPaused = true;
                                      gameOver = true;
                                      advancedPlayer.stop();
                                      showAd = false;
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xffdf446b),
                                              Color(0xaadf446b)
                                            ]),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Text(
                                            'Accept Defeat',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.raleway(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge,
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .042,
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

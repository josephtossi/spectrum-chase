import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrum_chase/constants.dart';
import 'package:spectrum_chase/data/data_storage_service.dart';
import 'package:spectrum_chase/pages/falling_objects.dart';
import 'package:spectrum_chase/pages/highest_scores_page.dart';
import 'package:spectrum_chase/pages/info_page.dart';
import 'package:spectrum_chase/pages/settings_page.dart';
import 'package:spectrum_chase/services/ads_service.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:visibility_detector/visibility_detector.dart';

// https://cloud.unity.com/home/organizations/18967854237258
// 5545987
// https://cloud.unity.com/home/organizations/18967854237258/projects/55e23a92-13ad-48d9-99e0-267605ae390c/monetization/overview

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AdsService _adsService = AdsService();
  List topUsersStatistics = [];
  Map userInfo = {};

  int generateRandomNumber(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double result = number / 1000.0;
      return '${result.toStringAsFixed(result % 1 == 0 ? 0 : 1)}K';
    } else {
      double result = number / 1000000.0;
      return '${result.toStringAsFixed(result % 1 == 0 ? 0 : 1)}M';
    }
  }

  getUserStatistics({required DataStorageManager dataStorageManager}) {
    setState(() {
      Map userMapSaved = dataStorageManager.getMap('user_statistics');
      if (userMapSaved.isNotEmpty) {
        userInfo = userMapSaved;
      } else {
        userInfo = {'userName': faker.internet.userName(), 'score': 0};
        dataStorageManager.setMap('user_statistics', userInfo);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        UnityAds.init(
          testMode: false,
          gameId: '5545987',
          onComplete: (){
            _adsService.createBannerAd();
            _adsService.createInterstitialAd();
          },
          onFailed: (error, message) => print('Initialization Failed: $error $message'),
        );
      } catch (e) {
        'Error init Ads $e';
      }

      /// get the attributes that the user have selected ///
      Constants.getSelectedAttributes();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      DataStorageManager dataStorageManager = DataStorageManager(prefs);

      /// Best Scores Logic ///
      List usersSaved = dataStorageManager.getList('top_users_statistics');
      if (usersSaved.isNotEmpty) {
        topUsersStatistics = usersSaved;
      } else {
        for (int i = 0; i < 20; i++) {
          topUsersStatistics.add({
            'userName': faker.internet.userName(),
            'score': generateRandomNumber(892, 9357)
          });
        }
        dataStorageManager.setList('top_users_statistics', topUsersStatistics);
      }
      topUsersStatistics.sort((a, b) => b['score'].compareTo(a['score']));

      /// Main User Logic ///
      Map userMapSaved = dataStorageManager.getMap('user_statistics');
      if (userMapSaved.isNotEmpty) {
        userInfo = userMapSaved;
      } else {
        userInfo = {'userName': faker.internet.userName(), 'score': 0};
        dataStorageManager.setMap('user_statistics', userInfo);
      }
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Constants.selectedBackgroundColor),
      child: Column(
        children: [
          /// Logo ///
          Expanded(
              flex: 2,
              child: Container(
                  color: Colors.transparent,
                  child: Center(
                      child: Image.asset(
                    'lib/assets/no-bg-logo.png',
                    fit: BoxFit.cover,
                  )))),

          /// Play ///
          Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FallingObjectsPage(),
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * .22,
                      left: MediaQuery.of(context).size.width * .22,
                      bottom: MediaQuery.of(context).size.width * .04),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xffdf446b), Color(0xff964ed8)]),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(17)),
                                // shape: BoxShape.circle,
                                gradient: Constants.selectedBackgroundColor),
                            child: Center(
                              child: Icon(Icons.play_arrow_rounded,
                                  color: const Color(0xfffefefe),
                                  size:
                                      MediaQuery.of(context).size.width * .33),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          /// Scores ///
          Expanded(
            flex: 1,
            child: Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width * .09),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Score',
                          // '${userInfo.isNotEmpty ? userInfo['userName'] : 'Your Best Score'}',
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * .033,
                              fontWeight: FontWeight.bold),
                        ),
                        VisibilityDetector(
                          key: const Key('user-score'),
                          onVisibilityChanged: (visibilityInfo) async {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100;
                            if (visiblePercentage > 0) {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              DataStorageManager dataStorageManager =
                                  DataStorageManager(prefs);
                              getUserStatistics(
                                  dataStorageManager: dataStorageManager);
                            }
                          },
                          child: Text(
                            formatNumber(
                                userInfo.isNotEmpty ? userInfo['score'] : 0),
                            style: GoogleFonts.raleway(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * .09,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Game Best Score',
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: const Color(0xffffffff),
                              fontSize:
                                  MediaQuery.of(context).size.width * .033,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatNumber(topUsersStatistics.isNotEmpty
                              ? topUsersStatistics.first['score']
                              : 0),
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * .09,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Settings ///
          Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              userInfo: userInfo,
                              highestScore: topUsersStatistics.isNotEmpty
                                  ? topUsersStatistics.first['score']
                                  : 0,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * .2,
                        width: MediaQuery.of(context).size.width * .2,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffdf446b), Color(0xff964ed8)]),
                        ),
                        child: Center(
                          child: Icon(Icons.settings,
                              color: const Color(0xfffefefe),
                              size: MediaQuery.of(context).size.width * .1),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HighestScoresPage(
                                userStatistics: userInfo,
                                topUsersStatistics: topUsersStatistics),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * .2,
                        width: MediaQuery.of(context).size.width * .2,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffdf446b), Color(0xff964ed8)]),
                        ),
                        child: Icon(Icons.leaderboard,
                            color: const Color(0xfffefefe),
                            size: MediaQuery.of(context).size.width * .1),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfoPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * .2,
                        width: MediaQuery.of(context).size.width * .2,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffdf446b), Color(0xff964ed8)]),
                        ),
                        child: Icon(Icons.info,
                            color: const Color(0xfffefefe),
                            size: MediaQuery.of(context).size.width * .1),
                      ),
                    ),
                  ],
                ),
              )),

          /// Unity Ads ///
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: UnityBannerAd(
              placementId: 'Banner_Android',
              onLoad: (placementId) => print('Banner loaded: $placementId'),
              onClick: (placementId) => print('Banner clicked: $placementId'),
              onShown: (placementId) => print('Banner shown: $placementId'),
              onFailed: (placementId, error, message) => print('Banner Ad $placementId failed: $error $message'),
            ),
          )
        ],
      ),
    );
  }
}

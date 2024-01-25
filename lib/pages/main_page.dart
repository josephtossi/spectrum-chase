import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrum_chase/data/data_storage_service.dart';
import 'package:spectrum_chase/pages/falling_objects.dart';
import 'package:spectrum_chase/pages/highest_scores_page.dart';
import 'package:spectrum_chase/pages/info_page.dart';
import 'package:spectrum_chase/pages/settings_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List topUsersStatistics = [];
  Map userInfo = {};
  /// variables for ads ///
  AdSize? _adSize;
  late Orientation _currentOrientation = Orientation.portrait;
  bool _isLoaded = false;
  AdManagerBannerAd? _inlineAdaptiveAd;
  static const _insets = 16.0;
  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  void _loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });
    _inlineAdaptiveAd = AdManagerBannerAd(
      adUnitId: 'ca-app-pub-6797834730215290/7911468356',
      sizes: [AdSize(width: (MediaQuery.of(context).size.width - (2 * _insets)).toInt(), height: 50)],
      request: AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) async {
          print('Inline adaptive banner loaded: ${ad.responseInfo}');
          AdManagerBannerAd bannerAd = (ad as AdManagerBannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            print('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

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
      try{
        MobileAds.instance.initialize();
      }catch(e){
        'Error init Ads $e';
      }
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
            'score': generateRandomNumber(230, 5000)
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
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _currentOrientation = MediaQuery.of(context).orientation;
      _loadAd();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _inlineAdaptiveAd != null &&
            _isLoaded &&
            _adSize != null) {
          return Align(
              child: Container(
                width: _adWidth,
                height: _adSize!.height.toDouble(),
                child: AdWidget(
                  ad: _inlineAdaptiveAd!,
                ),
              ));
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff171648), Color(0xff301585)])),
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
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff171648),
                                      Color(0xff301585)
                                    ])),
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
                              fontSize:
                              MediaQuery.of(context).size.width * .09,
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

          _getAdWidget()
        ],
      ),
    );
  }
}

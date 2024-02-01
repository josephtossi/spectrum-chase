import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:spectrum_chase/constants.dart';
import 'package:spectrum_chase/my_behavior.dart';
import 'package:spectrum_chase/services/ads_service.dart';

double musicVolume = 1;
double effectsVolume = 1;

class SettingsPage extends StatefulWidget {
  Map userInfo;
  int highestScore;

  SettingsPage({super.key, required this.userInfo, required this.highestScore});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// variables for ads ///
  AdsService _adsService = AdsService();
  AdSize? _adSize;
  late Orientation _currentOrientation = Orientation.portrait;
  bool _isLoaded = false;
  AdManagerBannerAd? _inlineAdaptiveAd;
  static const _insets = 16.0;
  bool showAd = false;
  Function onPressCallback = (){};

  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  void _loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });
    _inlineAdaptiveAd = AdManagerBannerAd(
      adUnitId: 'ca-app-pub-6797834730215290/7911468356',
      sizes: [
        AdSize(
            width: (MediaQuery.of(context).size.width - (2 * _insets)).toInt(),
            height: 50)
      ],
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

  showAdFunction({required Function function}) {
    showAd = true;
    onPressCallback = function;
    setState(() {});
  }

  @override
  void initState() {
    /// todo check if we must put an ad here ///
    // _adsService.createInterstitialAd();
    // Future.delayed(const Duration(seconds: 5), () {
    //   _adsService.showInterstitialAd();
    // });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _adsService.createRewardedAd();
    });
    super.initState();
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
    return Material(
      child: Container(
        padding: const EdgeInsets.only(top: 50),
        decoration: BoxDecoration(gradient: Constants.selectedBackgroundColor),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 28,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * .05,
                  )),
            ),
            Column(
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      color: const Color(0xffffffff),
                      fontSize: MediaQuery.of(context).size.width * .07,
                      fontWeight: FontWeight.bold),
                ),
                Flexible(
                    child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 28.0, left: 28),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Username',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${widget.userInfo['userName'] ?? ''}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      height: 1.7,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Score',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      formatNumber(
                                          widget.userInfo['score'] ?? 0),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          color: Colors.white,
                                          fontSize: 25,
                                          height: .8,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 35),
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
                                'You still need ${formatNumber((widget.highestScore - widget.userInfo['score'] ?? 0).toInt())} '
                                'to reach the highest score',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .042,
                                    height: 1.23,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// slider music ///
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Music Volume',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 20.0,
                          left: 20,
                        ),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0.0),
                          ),
                          child: Slider(
                            value: musicVolume.toDouble(),
                            min: 0,
                            max: 1,
                            activeColor: Colors.white,
                            inactiveColor: const Color(0xFF8D8E98),
                            onChanged: (double newValue) {
                              setState(() {
                                musicVolume = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      /// slider effects ///
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Effects Volume',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 20.0,
                          left: 20,
                        ),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0.0),
                          ),
                          child: Slider(
                            value: effectsVolume.toDouble(),
                            min: 0,
                            max: 1,
                            activeColor: Colors.white,
                            inactiveColor: const Color(0xFF8D8E98),
                            onChanged: (double newValue) {
                              setState(() {
                                effectsVolume = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      /// Colors ///
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 30),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose your background color',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 55,
                        margin: EdgeInsets.only(top: 20, right: 0, left: 27),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: Constants.backGroundColors
                              .map((backGroundGradient) {
                            return GestureDetector(
                              onTap: () {
                                showAdFunction(
                                  function: (){
                                    setState(() {
                                      Constants.selectedBackgroundColor =
                                          backGroundGradient;
                                      Constants.selectAttribute(
                                          attributeType: "selectedBackgroundColor",
                                          attributeValue: Constants.backGroundColors
                                              .indexOf(backGroundGradient));
                                      SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
                                        statusBarColor: Constants.selectedBackgroundColor.colors.last,
                                        systemNavigationBarColor: Constants.selectedBackgroundColor.colors.last,
                                        systemNavigationBarIconBrightness: Brightness.light,
                                      ));
                                    });
                                  }
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  gradient: backGroundGradient,
                                ),
                                width: (MediaQuery.of(context).size.width / 5),
                                child: Constants.selectedBackgroundColor ==
                                        backGroundGradient
                                    ? Icon(
                                        Icons.check,
                                        size:
                                            (MediaQuery.of(context).size.width /
                                                15),
                                        color: Colors.white,
                                      )
                                    : Container(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      /// Game type ///
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 30),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose your game type',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 55,
                        margin: EdgeInsets.only(top: 20, right: 0, left: 27),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: Constants.gameTypeList.map((type) {
                            return GestureDetector(
                              onTap: () {
                                showAdFunction(
                                    function: (){
                                      setState(() {
                                        Constants.selectedGameType = type;
                                        Constants.selectAttribute(
                                            attributeType: "selectedGameType",
                                            attributeValue: type);
                                      });
                                    }
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 6),
                                width: (MediaQuery.of(context).size.width / 5),
                                child: Stack(
                                  children: [
                                    type == 'colors'
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Constants
                                                            .selectedGameType ==
                                                        type
                                                    ? Colors.blueGrey
                                                    : Colors.black38,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4))),
                                            child: Center(
                                              child: Image.asset(
                                                  'lib/assets/2938687.png'),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Constants
                                                            .selectedGameType ==
                                                        type
                                                    ? Colors.blueGrey
                                                    : Colors.black38,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4))),
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'lib/assets/sun.png'),
                                                  )),
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'lib/assets/moon.png'),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ),
                                    Constants.selectedGameType == type
                                        ? Positioned(
                                            right: 5,
                                            bottom: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black38),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      /// baskets ///
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 28.0, left: 28, top: 30),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose your Basket',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, right: 27, left: 27),
                        child: Wrap(
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(7, (index) {
                            return GestureDetector(
                              onTap: () {
                                showAdFunction(
                                    function: (){
                                      setState(() {
                                        Constants.selectedBasket =
                                        'lib/assets/basket_${index + 1}.png';
                                        Constants.selectAttribute(
                                            attributeType: "selectedBasket",
                                            attributeValue:
                                            'lib/assets/basket_${index + 1}.png');
                                      });
                                    }
                                );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0x33df446b),
                                        Color(0x33964ed8)
                                      ]),
                                ),
                                width: (MediaQuery.of(context).size.width / 3) -
                                    22,
                                height:
                                    (MediaQuery.of(context).size.width / 3) -
                                        22,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'lib/assets/basket_${index + 1}.png',
                                        fit: BoxFit.scaleDown,
                                      ),
                                      Constants.selectedBasket ==
                                              'lib/assets/basket_${index + 1}.png'
                                          ? Center(
                                              child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  shape: BoxShape.circle),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ))
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                )),
                _getAdWidget()
              ],
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
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                height: MediaQuery.of(context).size.width * .25,
                                child: Image.asset('lib/assets/unlock.png')),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Text(
                                'Unlock Customization',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width * .044,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Enhance your gaming experience with a custom background, game type or basket! "
                                    "Watch a short ad to unlock these special features.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.alata(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width * .044,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    try {
                                      _adsService.showRewardedAd(
                                          doneFunction: () {
                                            setState(() {
                                              onPressCallback();
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
                                        'Cancel',
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
      ),
    );
  }
}

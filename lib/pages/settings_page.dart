import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  @override
  void initState() {
    _adsService.createInterstitialAd();
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
    Future.delayed(const Duration(seconds: 1), (){
      _adsService.showInterstitialAd();
    });
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
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff171648), Color(0xff301585)])),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 28,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios,color: Colors.white,
                    size: MediaQuery.of(context).size.width * .05,)),
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
                                            textStyle:
                                                Theme.of(context).textTheme.displayLarge,
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${widget.userInfo['userName'] ?? ''}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.raleway(
                                            height: 1.7,
                                            textStyle:
                                                Theme.of(context).textTheme.displayLarge,
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
                                            textStyle:
                                                Theme.of(context).textTheme.displayLarge,
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            formatNumber(widget.userInfo['score'] ?? 0),
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
                              padding:
                                  const EdgeInsets.only(right: 28.0, left: 28, top: 35),
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

                            /// slider music ///
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 28.0, left: 28, top: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Music Volume',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context).textTheme.displayLarge,
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.only(top: 10,right: 20.0, left: 20,),
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
                              padding:
                              const EdgeInsets.only(right: 28.0, left: 28, top: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Effects Volume',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context).textTheme.displayLarge,
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.only(top: 10,right: 20.0, left: 20,),
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
                        ],
                      ),
                    )),
                _getAdWidget()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

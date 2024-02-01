import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:spectrum_chase/constants.dart';
import 'package:spectrum_chase/services/ads_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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

  @override
  void initState() {
    _adsService.createInterstitialAd();
    Future.delayed(const Duration(seconds: 5), () {
      _adsService.showInterstitialAd();
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
                  'How to Play',
                  style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      color: const Color(0xffffffff),
                      fontSize: MediaQuery.of(context).size.width * .07,
                      fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Explanation ///
                        Padding(
                          padding: EdgeInsets.only(
                              right: 25.0,
                              top: MediaQuery.of(context).size.width * .25,
                              left: 25),
                          child: Column(
                            children: [
                              Column(
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
                                    padding: const EdgeInsets.only(
                                        top: 4.0, bottom: 20),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: Center(
                                        child: Image.asset(
                                            'lib/assets/2938687.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Your goal is to catch the specified color or object '
                                  'while they are falling but beware to avoid others\n\n'
                                  'You can customise your game play in the settings page \nChoose between 2 different game play types as well',
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.raleway(
                                      height: 1.5,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Basket Explanation ///
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Drag the basket right or left and try to catch the color',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      height: 1.5,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    Icons.swipe_left_alt,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    height:
                                        MediaQuery.of(context).size.width * .2,
                                    color: Colors.transparent,
                                    child: Image.asset(
                                      'lib/assets/basket_1.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.swipe_right_alt,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

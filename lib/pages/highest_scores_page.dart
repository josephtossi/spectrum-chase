import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_chase/constants.dart';
import 'package:spectrum_chase/my_behavior.dart';
import 'package:spectrum_chase/services/ads_service.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class HighestScoresPage extends StatefulWidget {
  List topUsersStatistics = [];
  Map userStatistics = {};

  HighestScoresPage(
      {super.key,
      required this.topUsersStatistics,
      required this.userStatistics});

  @override
  // ignore: library_private_types_in_public_api
  _HighestScoresPageState createState() => _HighestScoresPageState();
}

class _HighestScoresPageState extends State<HighestScoresPage> {
  /// variables for ads ///
  AdsService _adsService = AdsService();
  static const _insets = 16.0;

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
    Future.delayed(const Duration(seconds: 5), (){
      _adsService.showInterstitialAd();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      List lesserUsers = [];
      for (Map userInTop in widget.topUsersStatistics) {
        if (userInTop['score'] <= widget.userStatistics['score']) {
          lesserUsers.add(userInTop);
        }
      }
      if (lesserUsers.isNotEmpty) {
        widget.topUsersStatistics.removeWhere(
            (element) => element['userName'] == lesserUsers.first['userName']);
        widget.topUsersStatistics.add(widget.userStatistics);
        widget.topUsersStatistics
            .sort((a, b) => b['score'].compareTo(a['score']));
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        decoration: BoxDecoration(
            gradient: Constants.selectedBackgroundColor),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 28,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Icon(Icons.arrow_back_ios,color: Colors.white,
                    size: MediaQuery.of(context).size.width * .05,),
                  )),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    'Top Scores',
                    style: GoogleFonts.raleway(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        color: const Color(0xffffffff),
                        fontSize: MediaQuery.of(context).size.width * .07,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ScrollConfiguration(
                    behavior: MyBehavior(),
                    child: ListView(
                        padding: const EdgeInsets.only(bottom: 20, top: 20),
                        children: widget.topUsersStatistics.map((topUser) {
                          return Container(
                            margin: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 15),
                            height: MediaQuery.of(context).size.height * .07625,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: topUser['userName'] ==
                                          widget.userStatistics['userName']
                                      ? [
                                          const Color(0xffdf446b),
                                          const Color(0xffdf446b)
                                        ]
                                      : [
                                          const Color(0x22df446b),
                                          const Color(0x44df446b)
                                        ]),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: topUser['score'] == widget.topUsersStatistics.first['score']?
                                        Image.asset(
                                          'lib/assets/4399411.png',
                                          fit: BoxFit.cover,
                                        ) : Padding(
                                          padding: const EdgeInsets.all(1.75),
                                          child: Text(
                                            '${widget.topUsersStatistics.indexOf(topUser) + 1}',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                                textStyle:
                                                Theme.of(context).textTheme.displayLarge,
                                                color: const Color(0xffffffff),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${topUser['userName'] == widget.userStatistics['userName'] ? '${topUser['userName']}' : topUser['userName']}',
                                          style: GoogleFonts.raleway(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge,
                                              color: const Color(0xffffffff),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    formatNumber(topUser['score']),
                                    style: GoogleFonts.openSans(
                                        textStyle:
                                            Theme.of(context).textTheme.displayLarge,
                                        color: const Color(0xffffffff),
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

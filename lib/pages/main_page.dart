import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_chase/pages/falling_objects.dart';
import 'package:spectrum_chase/pages/highest_scores_page.dart';
import 'package:spectrum_chase/pages/info_page.dart';
import 'package:spectrum_chase/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                      bottom: MediaQuery.of(context).size.width * .07),
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
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * .145),
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
                          'Your Best Score',
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: const Color(0xffffffff),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatNumber(200),
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatNumber(10000000),
                          style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              color: Colors.white,
                              fontSize: 35,
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HighestScoresPage(),
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
                      onTap: (){
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
        ],
      ),
    );
  }
}

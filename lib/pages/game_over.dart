import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrum_chase/constants.dart';

import '../data/data_storage_service.dart';

class GameOver extends StatefulWidget {
  dynamic gameOverFunction;
  int score = 0;

  GameOver({super.key, required this.gameOverFunction, required this.score});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      DataStorageManager dataStorageManager = DataStorageManager(prefs);
      Map userMapSaved = dataStorageManager.getMap('user_statistics');
      if (userMapSaved.isNotEmpty) {
        if (userMapSaved['score'] < widget.score) {
          userMapSaved['score'] = widget.score;
          dataStorageManager.setMap('user_statistics', userMapSaved);
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(gradient: Constants.selectedBackgroundColor),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.alata(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * .085,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Score : ${widget.score}',
                  style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * .06,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 38.0),
                child: GestureDetector(
                  onTap: widget.gameOverFunction,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xffdf446b), Color(0xffdf446b)]),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.refresh,
                          size: MediaQuery.of(context).size.width * .086,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xffdf446b), Color(0xffdf446b)]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.home,
                        size: MediaQuery.of(context).size.width * .086,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

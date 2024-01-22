import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOver extends StatefulWidget {
  dynamic gameOverFunction;
  int score = 0;

  GameOver({super.key, required this.gameOverFunction, required this.score});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff171648), Color(0xff301585)])),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.raleway(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.white,
                    fontSize: 39,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'Score : ${widget.score}',
                style: GoogleFonts.raleway(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400
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
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: GestureDetector(
                  onTap: (){
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
                      child: Text(
                        'Go Home',
                        style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
                      children:[
                        /// Explanation ///
                        Padding(
                          padding: EdgeInsets.only(right: 25.0,
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
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: Center(
                                        child:
                                        Image.asset('lib/assets/2938687.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Your goal is to catch the specified color from the falling objects while avoiding others',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                      height: 1.7,
                                      textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                      color: Colors.white,
                                      fontSize: 20,
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
                                      textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.swipe_left_alt,
                                    color: Colors.white,size: 50,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * .2,
                                    height: MediaQuery.of(context).size.width * .2,
                                    color: Colors.transparent,
                                    child: Image.asset(
                                      'lib/assets/shopping-basket-icon-2048x1742-42o8ifn2.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  const Icon(Icons.swipe_right_alt,
                                    color: Colors.white,size: 50,),
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

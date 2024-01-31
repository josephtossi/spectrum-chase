import 'package:flutter/material.dart';

class Constants {
  static LinearGradient selectedBackgroundColor = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff171648), Color(0xff301585)]);

  static String selectedBasket = 'lib/assets/basket_1.png';

  static String selectedGameType = 'colors';

  /// ================================= ///
  static List gameTypeList = ['colors', 'sun_moon'];

  static List backGroundColors = [
    /// 1 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff171648), Color(0xff301585)]),

    /// 2 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff15202b), Color(0xff102027)]),

    /// 3 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff007991), Color(0xff78ffd6)]),

    /// 4 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff990000), Color(0xffffcc00)]),

    /// 5 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff2c3e50), Color(0xff3498db)]),

    /// 6 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff5f2c82), Color(0xff49a09d)]),

    /// 7 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff9d50bb), Color(0xff6e48aa)]),

    /// 8 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff5c258d), Color(0xff4389a2)]),

    /// 9 ///
    LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff1e3c72), Color(0xff2a5298)]),
  ];
}

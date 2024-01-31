import 'package:flutter/material.dart';

class FallingObject {
  final double top;
  final double left;
  Color color;
  double opacity;
  GlobalKey key;
  String icon = 'lib/assets/2938687.png';

  FallingObject({
    required this.top,
    required this.left,
    required this.color,
    required this.opacity,
    required this.icon
  }) : key = GlobalKey();
}

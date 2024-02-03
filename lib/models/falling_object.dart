import 'package:flutter/material.dart';

enum FallingObjectType { PRESENT, SHIELD, NORMAL }

class FallingObject {
  final double top;
  final double left;
  Color color;
  double opacity;
  GlobalKey key;
  String icon = 'lib/assets/2938687.png';
  FallingObjectType type;

  FallingObject(
      {required this.top,
      required this.left,
      required this.color,
      required this.opacity,
      required this.type,
      required this.icon})
      : key = GlobalKey();
}

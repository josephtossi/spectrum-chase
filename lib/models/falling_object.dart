import 'package:flutter/material.dart';

class FallingObject {
  final double top;
  final double left;
  Color color;
  double opacity;

  FallingObject(
      {required this.top,
      required this.left,
      required this.color,
      required this.opacity});
}

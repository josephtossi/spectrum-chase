import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Pixel extends StatelessWidget {
  Color color;
  Widget child;

  Pixel({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white,width: 3),
          color: color, borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child: child,
    );
  }
}

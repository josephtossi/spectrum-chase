import 'package:flutter/material.dart';
import 'package:spectrum_chase/pages/ideas/tetris.dart';
import 'package:spectrum_chase/pages/main_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MainPage(),
        // body: Tetris(),
      ),
    );
  }
}

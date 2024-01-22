import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spectrum_chase/pages/falling_objects.dart';
import 'package:spectrum_chase/pages/main_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xff301585),
    systemNavigationBarColor: Color(0xff301585),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MainPage(),
      ),
    );
  }
}

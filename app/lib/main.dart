import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:racquet_fun/screens/tabbed_screen/tabbed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Racquet Fun',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          curve: Curves.elasticOut,
          duration: 2000,
          splashIconSize: 300.0,
          splash: 'assets/images/logo.png',
          nextScreen: const TabbedScreen(),
          splashTransition: SplashTransition.slideTransition,
          backgroundColor: const Color.fromRGBO(222, 164, 106, 1.0),
        ));
  }
}

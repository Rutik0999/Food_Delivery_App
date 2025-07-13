import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:food_app_new/pages/login_page.dart';
import 'package:food_app_new/pages/login_page.dart';
import 'package:food_app_new/pages/onboard.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Lottie.asset(
              "assets/Lottie/Animation - 1722932940497.json",
              fit: BoxFit.contain, // Adjust to fit the screen
            ),
          ),
        ],
      ),
      nextScreen: const Onboard(),
      splashIconSize: double.infinity,
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      duration: 4000, // Duration in milliseconds (4 seconds)
    );
  }
}

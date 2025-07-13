import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_app_new/pages/EmailOtpPage.dart';
import 'package:food_app_new/providers/OrderProvider.dart';
import 'package:provider/provider.dart';

// Pages
// import 'package:food_app_new/pages/cart_page.dart';
// import 'package:food_app_new/pages/home_page.dart';
import 'package:food_app_new/pages/onboard.dart';
import 'package:food_app_new/pages/payment_confirmation_receipt.dart';
import 'package:food_app_new/pages/profile_page.dart';
import 'package:food_app_new/pages/login_page.dart';
import 'package:food_app_new/pages/signup_page.dart';
import 'package:food_app_new/pages/user_address_page.dart';
import 'package:food_app_new/pages/restaurant_page.dart';
import 'package:food_app_new/pages/menu_detail_page.dart';
import 'package:food_app_new/pages/cart.dart';

// Providers & Models
import 'package:food_app_new/providers/cart_provider.dart';
// import 'package:food_app_new/models/restaurant.dart';
import 'package:food_app_new/themes/theme_provider.dart';

// Splash Screen & SSL Override
import 'package:food_app_new/themes/splash_screen.dart';
import 'http_override.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SSL Override for development mode (Don't use in production!)
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ChangeNotifierProvider(create: (_) => Restaurant()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // Optional for global navigation/snackbars
          theme: themeProvider.themeData,
          home: SplashScreen(), // 👈 You can change this to HomePage() if needed
        );
      },
    );
  }
}

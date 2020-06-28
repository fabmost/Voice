import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'translations.dart';

import 'screens/splash_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/detail_comment_screen.dart';

import 'screens/new_poll_screen.dart';
import 'screens/new_challenge_screen.dart';

import 'providers/preferences_provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  MaterialColor generateMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    });
  }

  int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  Color tintColor(Color color, double factor) => Color.fromRGBO(
      tintValue(color.red, factor),
      tintValue(color.green, factor),
      tintValue(color.blue, factor),
      1);

  int shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  Color shadeColor(Color color, double factor) => Color.fromRGBO(
      shadeValue(color.red, factor),
      shadeValue(color.green, factor),
      shadeValue(color.blue, factor),
      1);

  Widget build(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Preferences()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voice Inc',
        theme: ThemeData(
          primarySwatch: generateMaterialColor(Color(0xFF111122)),
          accentColor: Color(0xFF6767CB),
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Color(0xFF6767CB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        localizationsDelegates: [
          const TranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
        ],
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            }
            if (snapshot.hasData) {
              return MenuScreen();
            }
            return PreferencesScreen();
          },
        ),
        routes: {
          OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
          CommentsScreen.routeName: (ctx) => CommentsScreen(),
          DetailCommentScreen.routeName: (ctx) => DetailCommentScreen(),
          NewPollScreen.routeName: (ctx) => NewPollScreen(),
          NewChallengeScreen.routeName: (ctx) => NewChallengeScreen(),
        },
      ),
    );
  }
}

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'translations.dart';

import 'screens/upgrade_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/countries_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/view_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/detail_comment_screen.dart';
import 'screens/detail_poll_screen.dart';
import 'screens/detail_challenge_screen.dart';
import 'screens/detail_cause_screen.dart';
import 'screens/flag_screen.dart';
import 'screens/user_name_screen.dart';
import 'screens/category_screen.dart';

import 'screens/new_poll_screen.dart';
import 'screens/new_challenge_screen.dart';
import 'screens/new_content_category_screen.dart';

import 'screens/verify_type_screen.dart';
import 'screens/verify_category_screen.dart';
import 'screens/verify_id_screen.dart';

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

  @override
  Widget build(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Preferences()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Galup',
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
          MenuScreen.routeName: (ctx) => MenuScreen(),
          OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
          CountriesScreen.routeName: (ctx) => CountriesScreen(),
          EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
          NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
          ViewProfileScreen.routeName: (ctx) => ViewProfileScreen(),
          ChatScreen.routeName: (ctx) => ChatScreen(),
          CommentsScreen.routeName: (ctx) => CommentsScreen(),
          DetailCommentScreen.routeName: (ctx) => DetailCommentScreen(),
          NewPollScreen.routeName: (ctx) => NewPollScreen(),
          NewChallengeScreen.routeName: (ctx) => NewChallengeScreen(),
          NewContentCategoryScreen.routeName: (ctx) =>
              NewContentCategoryScreen(),
          DetailPollScreen.routeName: (ctx) => DetailPollScreen(),
          DetailChallengeScreen.routeName: (ctx) => DetailChallengeScreen(),
          DetailCauseScreen.routeName: (ctx) => DetailCauseScreen(),
          VerifyTypeScreen.routeName: (ctx) => VerifyTypeScreen(),
          VerifyCategoryScreen.routeName: (ctx) => VerifyCategoryScreen(),
          VerifyIdScreen.routeName: (ctx) => VerifyIdScreen(),
          FlagScreen.routeName: (ctx) => FlagScreen(),
          UpgradeScreen.routeName: (ctx) => UpgradeScreen(),
          UserNameScreen.routeName: (ctx) => UserNameScreen(),
          CategoryScreen.routeName: (ctx) => CategoryScreen(),
        },
      ),
    );
  }
}

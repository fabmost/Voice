import 'dart:async';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'screens/detail_comment_screen.dart';
import 'screens/detail_poll_screen.dart';
import 'screens/detail_challenge_screen.dart';
import 'screens/detail_tip_screen.dart';
import 'screens/detail_cause_screen.dart';
import 'screens/flag_screen.dart';
import 'screens/user_name_screen.dart';
import 'screens/category_screen.dart';
import 'screens/session_login_screen.dart';
import 'screens/session_auth_screen.dart';

import 'screens/gallery_screen.dart';
import 'screens/new_poll_screen.dart';
import 'screens/new_challenge_screen.dart';
import 'screens/new_tip_screen.dart';
import 'screens/new_cause_screen.dart';
import 'screens/new_content_category_screen.dart';

import 'screens/verify_type_screen.dart';
import 'screens/verify_category_screen.dart';
import 'screens/verify_id_screen.dart';

import 'screens/test_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/database_provider.dart';
import 'providers/user_provider.dart';
import 'providers/config_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/content_provider.dart';

void main() {
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZoned(() {
    runApp(App());
  }, onError: Crashlytics.instance.recordError);
}

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
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (ctx) => UserProvider(null),
          update: (ctx, auth, previous) => UserProvider(auth.getUsername),
        ),
        ChangeNotifierProvider(create: (ctx) => DatabaseProvider()),
        ChangeNotifierProvider(create: (ctx) => ConfigurationProvider()),
        ChangeNotifierProvider(create: (ctx) => Preferences()),
        ChangeNotifierProvider(create: (ctx) => ContentProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, provider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Galup',
          theme: ThemeData(
            primarySwatch: generateMaterialColor(Color(0xFF722282)),
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
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('es', ''),
          ],
          home: provider.isAuth
              ? MenuScreen()
              : FutureBuilder(
                  future: provider.hasToken(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : provider.hasAccount
                              ? SessionLoginScreen()
                              : PreferencesScreen(),
                ),
          routes: {
            TestScreen.routeName: (ctx) => TestScreen(),
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
            DetailCommentScreen.routeName: (ctx) => DetailCommentScreen(),
            NewPollScreen.routeName: (ctx) => NewPollScreen(),
            NewChallengeScreen.routeName: (ctx) => NewChallengeScreen(),
            NewTipScreen.routeName: (ctx) => NewTipScreen(),
            NewCauseScreen.routeName: (ctx) => NewCauseScreen(),
            NewContentCategoryScreen.routeName: (ctx) =>
                NewContentCategoryScreen(),
            DetailPollScreen.routeName: (ctx) => DetailPollScreen(),
            DetailChallengeScreen.routeName: (ctx) => DetailChallengeScreen(),
            DetailTipScreen.routeName: (ctx) => DetailTipScreen(),
            DetailCauseScreen.routeName: (ctx) => DetailCauseScreen(),
            VerifyTypeScreen.routeName: (ctx) => VerifyTypeScreen(),
            VerifyCategoryScreen.routeName: (ctx) => VerifyCategoryScreen(),
            VerifyIdScreen.routeName: (ctx) => VerifyIdScreen(),
            FlagScreen.routeName: (ctx) => FlagScreen(),
            UpgradeScreen.routeName: (ctx) => UpgradeScreen(),
            UserNameScreen.routeName: (ctx) => UserNameScreen(),
            CategoryScreen.routeName: (ctx) => CategoryScreen(),
            SessionAuthScreen.routeName: (ctx) => SessionAuthScreen(),
            GalleryScreen.routeName: (ctx) => GalleryScreen(),
          },
        ),
      ),
    );
  }
}

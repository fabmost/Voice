import 'dart:math';

import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/detail_comment_screen.dart';

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
    return MaterialApp(
      title: 'Voice Inc',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Color(0xFF111122)),
        accentColor: Color(0xFF6767CB),
      ),
      home: MenuScreen(),
      routes: {
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
        CommentsScreen.routeName: (ctx) => CommentsScreen(),
        DetailCommentScreen.routeName: (ctx) => DetailCommentScreen(),
      },
    );
  }
}

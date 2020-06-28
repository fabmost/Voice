import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  Category({@required this.name, @required this.icon});

  static List<Category> categoriesList = [
    Category(name: 'Política', icon: Icons.ac_unit),
    Category(name: 'Youtuberos', icon: Icons.access_alarms),
    Category(name: 'Deporte', icon: Icons.backspace),
    Category(name: 'Algo más', icon: Icons.speaker_group),
  ];
}

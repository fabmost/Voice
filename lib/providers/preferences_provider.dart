import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with ChangeNotifier {
  bool _firstTime = true;

  bool get isFirstTime => _firstTime;

  Future<bool> getFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isfirstTime') ?? true;
  }

  Future<void> setFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isfirstTime', false);
    _firstTime = false;
    notifyListeners();
  }

}
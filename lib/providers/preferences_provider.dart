import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with ChangeNotifier {
  bool _firstTime = true;
  int _interactions = 0;

  bool get isFirstTime => _firstTime;

  Future<bool> getFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isfirstTime') ?? true;
  }

  Future<int> getInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions = prefs.getInt('interactions') ?? 0;
    notifyListeners();
    return _interactions;
  }

  Future<void> setInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions++;
    notifyListeners();
    return prefs.setInt('interactions', _interactions);
  }

  Future<void> removeInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions--;
    notifyListeners();
    return prefs.setInt('interactions', _interactions);
  }

  Future<void> setFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isfirstTime', false);
    _firstTime = false;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with ChangeNotifier {
  bool _firstTime = true;
  int _interactions = 0;
  bool _hasAccount = false;

  bool get isFirstTime => _firstTime;
  bool get hasAccount => _hasAccount;

  Future<bool> getFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isfirstTime') ?? true;
  }

  Future<int> getInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions = prefs.getInt('interactions') ?? 0;
    //notifyListeners();
    return _interactions;
  }

  Future<void> setInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions++;
    //notifyListeners();
    return prefs.setInt('interactions', _interactions);
  }

  Future<void> removeInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _interactions--;
    //notifyListeners();
    return prefs.setInt('interactions', _interactions);
  }

  Future<void> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    _hasAccount = prefs.getBool('hasAccount') ?? false;
    if (_hasAccount) {
      notifyListeners();
    }
    return; //prefs.getBool('hasAccount') ?? false;
  }

  Future<void> setAccount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasAccount', true);
    _hasAccount = true;
    notifyListeners();
  }

  Future<void> setFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isfirstTime', false);
    _firstTime = false;
    notifyListeners();
  }
}

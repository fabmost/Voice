import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'database_provider.dart';
import '../api.dart';
import '../mixins/text_mixin.dart';

class AuthProvider with ChangeNotifier, TextMixin {
  final _storage = FlutterSecureStorage();
  String _token;
  String _userName;
  bool _hasAccount = false;

  String get geToken => _token;
  String get getUsername => _userName;
  bool get isAuth {
    return _token != null;
  }

  bool get hasAccount => _hasAccount;

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = await _storage.read(key: API.sessionToken) ?? null;
    _userName = await _storage.read(key: API.userName) ?? null;
    _hasAccount = prefs.getBool('hasAccounts') ?? false;
    if (_token == null) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await setFCM('logout');
    final prefs = await SharedPreferences.getInstance();
    _storage.delete(key: API.sessionToken);
    _storage.delete(key: API.userHash);
    _storage.delete(key: API.userName);
    prefs.setBool('hasAccounts', true);
    _token = null;
    _userName = null;
    _hasAccount = true;
    notifyListeners();
  }

  Future<bool> canInteract() async {
    final prefs = await SharedPreferences.getInstance();
    final interactions = prefs.getInt('interactions') ?? 0;
    _userName = await _storage.read(key: API.userName) ?? null;

    if (_userName != null) {
      return true;
    }

    if (interactions < 5) {
      prefs.setInt('interactions', interactions + 1);
      return true;
    }
    return false;
  }

  Future<String> installation() async {
    var url = '${API.baseURL}/installation';

    final uuid = Uuid();
    final hash = uuid.v1();
    final datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final body = jsonEncode({
      'hash': hash,
      'utm_content': '',
      'utm_source': '',
      'utm_campaign': '',
      'utm_medium': '',
      'utm_term': '',
      'gclid': '',
      'language': '',
      'datetime': datetime
    });

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader:
            'Bearer ${API().getHash(hash, datetime)}'
      },
      body: body,
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }

    if (dataMap['status'] == 'success') {
      DatabaseProvider dbProvider = DatabaseProvider();
      await dbProvider.deleteAll();
      saveHash(hash);
      dataMap['categories'].forEach((e) async {
        Map dataMap = e as Map;

        dbProvider.saveCategory(
          id: dataMap['id'],
          name: dataMap['name'],
          icon: dataMap['icon'],
        );
      });
      dataMap['configs']['countries'].forEach((e) async {
        Map dataMap = e as Map;

        await dbProvider.saveCountry(
          name: dataMap['name'],
          code: dataMap['country_code'],
          flag: dataMap['flag'],
          phone: dataMap['code_phone'],
        );
      });
      _token = dataMap['session']['token'];
      return dataMap['session']['token'];
    } else {
      return null;
    }
  }

  Future<void> registerAnonymous(token) async {
    await _storage.write(key: API.sessionToken, value: token);
    _token = token;
    notifyListeners();
    return;
  }

  Future<void> saveHash(hash) async {
    await _storage.write(key: API.userHash, value: hash);
    return;
  }

  Future<String> getHash() async {
    return await _storage.read(key: API.userHash) ?? null;
  }

  Future<void> saveUserName(userName) async {
    await _storage.write(key: API.userName, value: userName);
    _userName = userName;
    notifyListeners();
    return;
  }

  Future<void> savePreferences(List categories) async {
    var url = '${API.baseURL}/registerCategories';

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $_token'
      },
      body: jsonEncode({'categories': categories}),
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      registerAnonymous(_token);
    }
    return;
  }

  Future<Map> signUp({name, last, email, user, password, token}) async {
    var url = '${API.baseURL}/registerProfile/';
    _token = token != null
        ? token
        : await _storage.read(key: API.sessionToken) ?? null;

    final body = jsonEncode({
      'name': serverSafe(name),
      'last_name': serverSafe(last),
      'email': email,
      'user_name': user,
      'password': password,
      'rrss': null,
      'rrss_uid': null,
    });

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $_token'
      },
      body: body,
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return {'result': false, 'message': 'Error'};
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      await _storage.write(key: API.sessionToken, value: _token);
      await saveUserName(user);
      return {'result': true};
    }
    if (dataMap['success'] == 'failed') {
      return {'result': false, 'message': dataMap['alert']['message']};
    }
    return {'result': false, 'message': dataMap['message']};
  }

  Future<Map> login({email, password}) async {
    var url = '${API.baseURL}/login';

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader:
            'Bearer ${API().getLog(email, password)}'
      },
      body: body,
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return {'result': false, 'message': 'Error'};
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      await _storage.write(key: API.sessionToken, value: _token);
      await saveHash(dataMap['hash_user']);
      await saveUserName(dataMap['user_name']);
      return {'result': true};
    }
    return {'result': false, 'message': dataMap['alert']['message']};
  }

  Future<void> setFCM(fcm) async {
    var url = '${API.baseURL}/registerFCM';
    _token = await _storage.read(key: API.sessionToken) ?? null;

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $_token'
      },
      body: jsonEncode({
        'fcm': fcm,
      }),
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }

    return;
  }

  Future<bool> recoverPassword(email) async {
    var url = '${API.baseURL}/forgotPassword';

    final uuid = Uuid();
    final hash = uuid.v1();
    final datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader:
            'Bearer ${API().getHash(hash, datetime)}'
      },
      body: jsonEncode({
        'email': email,
        "hash": hash,
        "datetime": datetime,
      }),
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return false;
    }

    if (dataMap['status'] == 'success') {
      return dataMap['SendMail'];
    }
    return false;
  }

  Future<void> renewToken() async {
    var url = '${API.baseURL}/token';
    final hash = await _storage.read(key: API.userHash) ?? null;
    final datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader:
            'Bearer ${API().getHash(hash, datetime)}'
      },
      body: jsonEncode({
        'hash': hash,
        'datetime': datetime,
      }),
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      await _storage.write(key: API.sessionToken, value: _token);
    }
    return;
  }
}

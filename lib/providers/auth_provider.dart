import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'database_provider.dart';
import '../api.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  String _token;
  String _userName;

  String get geToken => _token;
  String get getUsername => _userName;
  bool get isAuth {
    return _token != null;
  }

  Future<bool> hasToken() async {
    _token = await _storage.read(key: API.sessionToken) ?? null;
    _userName = await _storage.read(key: API.userName) ?? null;
    if (_token == null) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _storage.delete(key: API.sessionToken);
    _storage.delete(key: API.userHash);
    _storage.delete(key: API.userName);
    _token = null;
    _userName = null;
    notifyListeners();
  }

  Future<String> installation() async {
    var url = '${API.baseURL}/installation';

    final hash = UniqueKey().toString();
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

        await dbProvider.saveCategory(
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

  Future<Map> signUp({name, last, email, user, password}) async {
    var url = '${API.baseURL}/registerProfile/';
    _token = await _storage.read(key: API.sessionToken) ?? null;

    final body = jsonEncode({
      'name': name,
      'last_name': last,
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
    return {'result': false, 'message': dataMap['alert']['message']};
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

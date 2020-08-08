import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api.dart';
import '../models/category_model.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  String _token;
  String _hash;

  String get geToken => _token;
  bool get isAuth {
    return _token != null;
  }

  Future<bool> hasToken() async {
    _token = await _storage.read(key: API.sessionToken) ?? null;
    if (_token == null) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _storage.delete(key: API.sessionToken);
    _token = null;
    notifyListeners();
  }

  Future<Map> installation() async {
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
      return {};
    }

    if (dataMap['status'] == 'success') {
      saveHash(hash);
      List aux = dataMap['categories'];
      List categories = aux.map((e) {
        Map dataMap = e as Map;
        return CategoryModel(
          id: dataMap['id'],
          name: dataMap['name'],
        );
      }).toList();
      return {
        'token': dataMap['session']['token'],
        'categories': categories,
      };
    } else {
      return {};
    }
  }

  Future<void> registerAnonymous(token) async {
    await _storage.write(key: API.sessionToken, value: token);
    notifyListeners();
    return;
  }

  Future<void> saveHash(hash) async {
    await _storage.write(key: API.userHash, value: hash);
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

  Future<void> signUp({name, last, email, user, password}) async {
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
        HttpHeaders.authorizationHeader:
            'Bearer $_token'
      },
      body: body,
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

  Future<void> login({email, password}) async {
    var url = '${API.baseURL}/login';
    _token = await _storage.read(key: API.sessionToken) ?? null;

    final body = jsonEncode({
      'email': email,
      'password': API().getSalt(password),
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
      return;
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      await _storage.write(key: API.sessionToken, value: _token);
      saveHash(dataMap['hash_user']);
    }
    return;
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

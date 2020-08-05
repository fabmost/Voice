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

  Future<List> installation() async {
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
      return [];
    }

    if (dataMap['status'] == 'success') {
      _token = dataMap['session']['token'];
      List categories = dataMap['categories'];
      return categories.map((e) {
        Map dataMap = e as Map;
        return CategoryModel(
          id: dataMap['id'],
          name: dataMap['name'],
        );
      }).toList();
    } else {
      return [];
    }
  }

  Future<void> registerAnonymous() async {
    await _storage.write(key: API.sessionToken, value: _token);
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
      await _storage.write(key: API.sessionToken, value: _token);
      notifyListeners();
    }
    return;
  }
}

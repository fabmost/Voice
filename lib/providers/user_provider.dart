import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();

  Future<UserModel> getProfile(userName) async {
    var url = '${API.baseURL}/profile/$userName';
    final token = await _getToken();

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }

    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);

      return UserModel.fromJson(dataMap['profile']);
    }
    return null;
  }

  Future<bool> followUser(id) async {
    var url = '${API.baseURL}/follow';
    final token = await _getToken();
    Map parameters = {
      'user_name': id,
    };
    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final body = jsonEncode(parameters);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: body,
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return dataMap['is_following'];
    }
    return null;
  }

  Future<String> _getToken() {
    return _storage.read(key: API.sessionToken) ?? null;
  }

  Future<void> _saveToken(token) async {
    await _storage.write(key: API.sessionToken, value: token);
    return;
  }
}

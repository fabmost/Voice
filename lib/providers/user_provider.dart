import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final String _myUser;
  final _storage = FlutterSecureStorage();

  UserProvider(this._myUser);

  String get getUser => _myUser;

  Future<UserModel> userProfile() async {
    var url = '${API.baseURL}/profile/$_myUser';
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

  Future<Map> editProfile({
    name,
    lastName,
    userName,
    country,
    tiktok,
    facebook,
    instagram,
    youtube,
    bio,
    gender,
    cover,
    birth,
  }) async {
    var url = '${API.baseURL}/editProfile';
    final token = await _getToken();

    Map parameters = {};

    if (name != null) parameters['name'] = name;
    if (lastName != null) parameters['last_name'] = lastName;
    if (userName != null) parameters['“user_name”'] = userName;
    if (country != null) parameters['country_code'] = country;
    if (tiktok != null) parameters['country_code'] = tiktok;
    if (facebook != null) parameters['facebook'] = facebook;
    if (instagram != null) parameters['instagram'] = instagram;
    if (youtube != null) parameters['youtube'] = youtube;
    if (bio != null) parameters['biography'] = bio;
    if (gender != null) parameters['gender'] = gender;
    if (cover != null) parameters['cover'] = cover;
    if (birth != null) parameters['birhtday'] = birth;

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
      return {'result': false, 'message': 'Error'};
    }

    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);
      return {'result': true};
    }
    return {'result': false, 'message': dataMap['alert']['message']};
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

  Future<List<UserModel>> getFollowers(user, page) async {
    var url = '${API.baseURL}/followers/$user/$page';
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
      return [];
    }

    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);

      return UserModel.listFromJson(dataMap['followers']);
    }
    return [];
  }

  Future<List> getFollowing(user, page) async {
    var url = '${API.baseURL}/following/$user/$page';
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
      return [];
    }

    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);

      return UserModel.listFromJson(dataMap['followings']);
    }
    return [];
  }

  Future<Map> getAutocomplete(query) async {
    var url = '${API.baseURL}/search/autocomplete/$query';
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
      return {'users': [], 'hashtags': []};
    }

    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);

      return {
        'users': UserModel.listFromJson(dataMap['users']),
        'hashtags': dataMap['hashtags'].map((element) {
          return {
            'text': element['name'],
            'count': element['count'],
          };
        }).toList()
      };
    }
    return {'users': [], 'hashtags': []};
  }

  Future<String> _getToken() {
    return _storage.read(key: API.sessionToken) ?? null;
  }

  Future<void> _saveToken(token) async {
    await _storage.write(key: API.sessionToken, value: token);
    return;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api.dart';
import '../models/user_model.dart';
import '../mixins/text_mixin.dart';

class UserProvider with ChangeNotifier, TextMixin {
  final String _myUser;
  final _storage = FlutterSecureStorage();
  UserModel _currentUser;

  UserProvider(this._myUser);

  String get getUser => _myUser;
  UserModel get getUserModel => _currentUser;

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

      _currentUser = UserModel.fromJson(dataMap['profile']);
      notifyListeners();
      return _currentUser;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return userProfile();
    }
    return null;
  }

  Future<UserModel> getProfile(userName) async {
    
    var url = '${API.baseURL}/profile/${Uri.encodeComponent(userName)}';
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
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getProfile(userName);
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
    icon,
    cover,
    birth,
  }) async {
    var url = '${API.baseURL}/editProfile';
    final token = await _getToken();

    Map parameters = {};

    if (name != null) {
      parameters['name'] = name;
      _currentUser.name = name;
    }
    if (lastName != null) {
      parameters['last_name'] = lastName;
      _currentUser.lastName = lastName;
    }
    if (userName != null) {
      parameters['user_name'] = userName;
      _currentUser.userName = userName;
    }
    if (country != null) {
      parameters['country_code'] = country;
      _currentUser.country = country;
    }
    if (tiktok != null) {
      parameters['tiktok'] = tiktok;
      _currentUser.tiktok = tiktok;
    }
    if (facebook != null) {
      parameters['facebook'] = facebook;
      _currentUser.facebook = facebook;
    }
    if (instagram != null) {
      parameters['instagram'] = instagram;
      _currentUser.instagram = instagram;
    }
    if (youtube != null) {
      parameters['youtube'] = youtube;
      _currentUser.youtube = youtube;
    }
    if (bio != null) {
      String fixedBio = serverSafe(bio);
      parameters['biography'] = fixedBio;
      _currentUser.biography = fixedBio;
    }
    if (gender != null) {
      parameters['gender'] = gender;
      _currentUser.gender = gender;
    }
    if (icon != null) {
      parameters['icon'] = icon;
      _currentUser.icon = icon;
    }
    if (cover != null) {
      parameters['cover'] = cover;
      _currentUser.cover = cover;
    }
    if (birth != null) {
      parameters['birhtday'] = birth;
      _currentUser.birthday = birth;
    }

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
      notifyListeners();
      return {'result': true};
    }
    await _renewToken();
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
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return followUser(id);
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
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getFollowers(user, page);
    }
    return [];
  }

  Future<List<UserModel>> getFollowing(user, page) async {
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
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getFollowing(user, page);
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
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getAutocomplete(query);
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

  Future<void> _renewToken() async {
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
      _saveToken(dataMap['session']['token']);
    }
    return;
  }
}

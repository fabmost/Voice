import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../mixins/text_mixin.dart';

class UserProvider with ChangeNotifier, TextMixin {
  String _myUser;
  final _storage = FlutterSecureStorage();
  UserModel _currentUser;
  Map<String, UserModel> _users = {};
  List<GroupModel> _groups = [];

  UserProvider(this._myUser);

  String get getUser => _myUser;
  UserModel get getUserModel => _currentUser;
  Map<String, UserModel> get getUsers => {..._users};
  List<GroupModel> get getGroupsList => [..._groups];

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
    twitter,
    youtube,
    bio,
    gender,
    icon,
    cover,
    birth,
    stories,
  }) async {
    var url = '${API.baseURL}/editProfile';
    final token = await _getToken();

    Map parameters = {};

    bool userNameChanged = false;

    if (name != null) {
      parameters['name'] = name;
      if (_currentUser != null) _currentUser.name = name;
    }
    if (lastName != null) {
      parameters['last_name'] = lastName;
      if (_currentUser != null) _currentUser.lastName = lastName;
    }
    if (userName != null) {
      userNameChanged = true;
      parameters['user_name'] = userName;
      if (_currentUser != null) _currentUser.userName = userName;
    }
    if (country != null) {
      parameters['country_code'] = country;
      if (_currentUser != null) _currentUser.country = country;
    }
    if (tiktok != null) {
      parameters['tiktok'] = tiktok;
      if (_currentUser != null) _currentUser.tiktok = tiktok;
    }
    if (facebook != null) {
      parameters['facebook'] = facebook;
      if (_currentUser != null) _currentUser.facebook = facebook;
    }
    if (instagram != null) {
      parameters['instagram'] = instagram;
      if (_currentUser != null) _currentUser.instagram = instagram;
    }
    if (twitter != null) {
      parameters['twitter'] = twitter;
      if (_currentUser != null) _currentUser.twitter = twitter;
    }
    if (youtube != null) {
      parameters['youtube'] = youtube;
      if (_currentUser != null) _currentUser.youtube = youtube;
    }
    if (bio != null) {
      String fixedBio = serverSafe(bio);
      parameters['biography'] = fixedBio;
      if (_currentUser != null) _currentUser.biography = fixedBio;
    }
    if (gender != null) {
      parameters['gender'] = gender;
      if (_currentUser != null) _currentUser.gender = gender;
    }
    if (icon != null) {
      parameters['icon'] = icon;
      if (_currentUser != null) _currentUser.icon = icon;
    }
    if (cover != null) {
      parameters['cover'] = cover;
      if (_currentUser != null) _currentUser.cover = cover;
    }
    if (birth != null) {
      parameters['birhtday'] = birth;
      if (_currentUser != null) _currentUser.birthday = birth;
    }
    if (stories != null) {
      parameters['histories'] = stories;
      //if (_currentUser != null) _currentUser.birthday = birth;
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
      if (userNameChanged) {
        await _storage.write(key: API.userName, value: userName);
        _myUser = userName;
      }
      await _saveToken(dataMap['session']['token']);
      notifyListeners();
      return {'result': true};
    }
    await _renewToken();
    return {'result': false, 'message': dataMap['alert']['message']};
  }

  Future<void> verifyUser({type, idCategory, idResource}) async {
    var url = '${API.baseURL}/validateProfile';
    final token = await _getToken();
    Map parameters = {
      'type': type,
      'category': idCategory,
      'identification': idResource,
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
      await _saveToken(dataMap['session']['token']);
      return;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return verifyUser(
        type: type,
        idCategory: idCategory,
        idResource: idResource,
      );
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
      await _saveToken(dataMap['session']['token']);
      bool isFollowing = dataMap['is_following'];
      if (_users.containsKey(id)) {
        UserModel oldUser = _users[id];
        final newUser = UserModel(
          name: oldUser.name,
          lastName: oldUser.lastName,
          userName: oldUser.userName,
          icon: oldUser.icon,
          certificate: oldUser.certificate,
          isFollowing: isFollowing,
        );
        _users[newUser.userName] = newUser;
        if (isFollowing && _currentUser != null) {
          int following = _currentUser.following + 1;
          _currentUser.following = following;
        }
        if (!isFollowing && _currentUser != null) {
          int following = _currentUser.following - 1;
          _currentUser.following = following;
        }
        notifyListeners();
      }
      return isFollowing;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return followUser(id);
    }
    return null;
  }

  Future<List<UserModel>> getFollowers(user, page, [query]) async {
    var url;
    if (query == null)
      url = '${API.baseURL}/followers/$user/$page';
    else
      url = '${API.baseURL}/followers/$user/$page/$query';
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
      await _saveToken(dataMap['session']['token']);
      List<UserModel> mUsers = UserModel.listFromJson(dataMap['followers']);
      mUsers.forEach((element) {
        _users[element.userName] = element;
      });
      notifyListeners();
      return mUsers;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getFollowers(user, page, query);
    }
    return [];
  }

  Future<List<UserModel>> getFollowing(user, page, [query]) async {
    var url;
    if (query == null)
      url = '${API.baseURL}/following/$user/$page';
    else
      url = '${API.baseURL}/following/$user/$page/$query';

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
      await _saveToken(dataMap['session']['token']);

      List<UserModel> mUsers = UserModel.listFromJson(dataMap['followings']);
      mUsers.forEach((element) {
        _users[element.userName] = element;
      });
      notifyListeners();
      return mUsers;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getFollowing(user, page, query);
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

  Future<void> newGroup({title, members}) async {
    var url = '${API.baseURL}/registerGroup';
    final token = await _getToken();
    Map parameters = {
      'title': title,
      'users': members,
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
      await _saveToken(dataMap['session']['token']);

      final GroupModel newGroup = GroupModel(
        id: dataMap['id'],
        title: title,
        members: members.length,
      );
      _groups.add(newGroup);
      notifyListeners();
      return;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return;
    }
    return null;
  }

  Future<void> editGroup({id, title, members}) async {
    var url = '${API.baseURL}/editGroup';
    final token = await _getToken();
    Map parameters = {
      'id': id,
      'title': title,
      'users': members,
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
      await _saveToken(dataMap['session']['token']);

      final int groupId = _groups.indexWhere((element) => element.id == id);
      final GroupModel newGroup = GroupModel(
        id: id,
        title: title,
        members: members.length,
      );
      _groups[groupId] = newGroup;

      notifyListeners();
      return;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return;
    }
    return null;
  }

  Future<List<GroupModel>> getGroups(page) async {
    var url = '${API.baseURL}/groups/$page';
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
      await _saveToken(dataMap['session']['token']);
      List<GroupModel> mGroups = GroupModel.listFromJson(dataMap['groups']);
      if (page == 0) {
        _groups = mGroups;
      }else{
        _groups.addAll(mGroups);
      }
      notifyListeners();
      return mGroups;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getGroups(page);
    }
    return [];
  }

  Future<List<UserModel>> getMembers(id, page) async {
    var url = '${API.baseURL}/groupMembers/$id/$page';
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
      await _saveToken(dataMap['session']['token']);
      List<UserModel> mUsers = UserModel.listFromJson(dataMap['users']);

      return mUsers;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getMembers(id, page);
    }
    return [];
  }

  Future<bool> deleteGroup(id) async {
    var url = '${API.baseURL}/deleteGroup';
    final token = await _getToken();
    Map parameters = {'id': id};
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);

      _groups.removeWhere((element) => element.id == id);
      notifyListeners();

      return true;
    }
    return false;
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

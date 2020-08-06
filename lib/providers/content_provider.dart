import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';

class ContentProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  List<ContentModel> _homeContent = [];

  List<ContentModel> get getHome => [..._homeContent];

  Future<void> getBaseTimeline(int page, String type) async {
    var url = '${API.baseURL}/timeLine/';
    final token = await _getToken();

    Map parameters = {'page': page};
    if (type != null) {
      parameters['type'] = type;
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
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      List timeLine = dataMap['timeline'];
      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'poll':
            _homeContent.add(PollModel.fromJson(content));
            break;
          case 'challenge':
            _homeContent.add(ChallengeModel.fromJson(content));
            break;
        }
      });
      notifyListeners();
    }
  }

  Future<void> newPoll({name, category, description, answers}) async {
    var url = '${API.baseURL}/registerPoll';
    final token = await _getToken();
    Map parameters = {
      'poll': name,
      'category': category,
      'description': description,
      'timelife': null,
      'hashtag': [],
      'answers': answers,
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
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
    }
  }

  Future<void> newChallenge(
      {name, category, resource, description, parameter, goal}) async {
    var url = '${API.baseURL}/registerChallenge';
    final token = await _getToken();

    Map parameters = {
      'challenge': name,
      'category': category,
      'resources': [resource],
      'description': description,
      'timelife': null,
      'taged': [],
      'hashtag': [],
      'med_param': parameter,
      'goal': goal
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
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
    }
  }

  Future<void> saveContent(id, type) async {
    var url = '${API.baseURL}/registerSaved';
    final token = await _getToken();

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode({
        'id': id,
        'type': type,
      }),
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
    }
  }

  Future<void> getPollStatistics(idPoll) async {
    var url = '${API.baseURL}/pollStatistics/$idPoll/';
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
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
    }
  }

  Future<String> _getToken() {
    return _storage.read(key: API.sessionToken) ?? null;
  }

  Future<void> _saveToken(token) async {
    await _storage.write(key: API.sessionToken, value: token);
    return;
  }
}

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

  Future<ContentModel> getContent(type, id) async {
    var url = '${API.baseURL}/contents/$type/$id';
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
    }
  }

  Future<List> getComments (type, id) async {
    var url = '${API.baseURL}/comments/$type/$id/';
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
    }
  }
  

  Future<bool> likeContent(type, id) async {
    var url = '${API.baseURL}/registerLikes/$type/$id';
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
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      bool hasLiked = dataMap['is_likes'];

      final index = _homeContent.indexWhere((element) => element.id == id);
      if (index != -1) {
        ContentModel content = _homeContent[index];
        switch (type) {
          case 'poll':
            content = PollModel(
              id: content.id,
              type: 'poll',
              user: content.user,
              title: content.title,
              createdAt: content.createdAt,
              votes: (content as PollModel).votes,
              likes: hasLiked ? content.likes + 1 : content.likes -1,
              regalups: content.regalups,
              comments: (content as PollModel).comments,
              hasVoted: (content as PollModel).hasVoted,
              hasLiked: hasLiked,
              hasRegalup: content.hasRegalup,
              hasSaved: content.hasSaved,
              answers: (content as PollModel).answers,
              resources: (content as PollModel).resources,
            );
            break;
          case 'challenge':
            break;
          case 'cause':
            break;
        }
        _homeContent[index] = content;
      }
      notifyListeners();

      return hasLiked;
    }
  }

  Future<void> likeComment(id, like) async {
    var url = '${API.baseURL}/registerLike/comments/$id';
    final token = await _getToken();
    Map parameters = {
      'like': like,
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

  Future<void> votePoll(id, answer) async {
    var url = '${API.baseURL}/registerVotes/$id';
    final token = await _getToken();
    Map parameters = {
      'id_answer': answer,
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

  Future<void> newComment({comment, type, id}) async {
    var url = '${API.baseURL}/registerComments/$type/$id/';
    final token = await _getToken();
    Map parameters = {
      'comment': comment,
      'hashtags': [],
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

  Future<void> newRegalup(id, type) async {
    var url = '${API.baseURL}/registerRegalup/$type/$id';
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

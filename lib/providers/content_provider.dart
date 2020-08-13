import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:voice_inc/models/user_model.dart';

import '../api.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/cause_model.dart';
import '../models/comment_model.dart';

class ContentProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  List<ContentModel> _homeContent = [];

  List<ContentModel> get getHome => [..._homeContent];

  Future<bool> getBaseTimeline(int page, String type) async {
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      List timeLine = dataMap['timeline'];
      if(timeLine.isEmpty){
        return false;
      }
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
      return true;
    }
    return false;
  }

  Future<List<ContentModel>> getUserTimeline(
      String user, int page, String type) async {
    var url = '${API.baseURL}/timeLine/$user';
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
      return [];
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      List<ContentModel> contentList = [];
      List timeLine = dataMap['timeline'];
      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'poll':
            contentList.add(PollModel.fromJson(content));
            break;
          case 'challenge':
            contentList.add(ChallengeModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    return [];
  }

  Future<List<ContentModel>> getSaved(int page) async {
    var url = '${API.baseURL}/saved/$page';
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
      List<ContentModel> contentList = [];
      List timeLine = dataMap['timeline'];
      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'poll':
            contentList.add(PollModel.fromJson(content));
            break;
          case 'challenge':
            contentList.add(ChallengeModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    return [];
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
      switch (type) {
        case 'P':
          return PollModel.fromJson(dataMap['data']);
        case 'C':
          return ChallengeModel.fromJson(dataMap['data']);
        case 'CA':
          return CauseModel.fromJson(dataMap['data']);
      }
    }
    return null;
  }

  Future<List<CommentModel>> getComments({type, id, page}) async {
    var url = '${API.baseURL}/comments/$type/$id/$page';
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
      return CommentModel.listFromJson(dataMap['comments']);
    }
    return [];
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
              likes: hasLiked ? content.likes + 1 : content.likes - 1,
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
    return null;
  }

  Future<Map> likeComment(id, like) async {
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
      return {};
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return {
        'like': dataMap['is_likes'],
        'dislike': dataMap['is_dislike'],
      };
    }
    return {};
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

  Future<void> newPoll({name, category, resources, description, answers}) async {
    var url = '${API.baseURL}/registerPoll';
    final token = await _getToken();
    Map parameters = {
      'poll': name,
      'category': category,
      'description': description,
      'timelife': null,
      'hashtag': [],
      'answers': answers,
      'resources': resources,
      'taged': [],
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

  Future<CommentModel> newComment({comment, type, id}) async {
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
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return CommentModel.fromJson(dataMap['comment']);
    }
    return null;
  }

  Future<bool> newRegalup(type, id) async {
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
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      bool hasRegalup = dataMap['is_regalup'];

      final index = _homeContent.indexWhere((element) => element.id == id);
      if (index != -1) {
        ContentModel content = _homeContent[index];
        switch (type) {
          case 'P':
            content = PollModel(
              id: content.id,
              type: 'poll',
              user: content.user,
              title: content.title,
              createdAt: content.createdAt,
              votes: (content as PollModel).votes,
              likes: content.likes,
              regalups:
                  hasRegalup ? content.regalups + 1 : content.regalups - 1,
              comments: (content as PollModel).comments,
              hasVoted: (content as PollModel).hasVoted,
              hasLiked: content.hasLiked,
              hasRegalup: hasRegalup,
              hasSaved: content.hasSaved,
              answers: (content as PollModel).answers,
              resources: (content as PollModel).resources,
            );
            break;
          case 'C':
            break;
          case 'CA':
            break;
        }
        _homeContent[index] = content;
      }
      notifyListeners();

      return hasRegalup;
    }
    return null;
  }

  Future<bool> saveContent(id, type) async {
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
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return dataMap['is_save'];
    }
    return null;
  }

  Future<List<UserModel>> getLikes({type, id, page}) async {
    var url = '${API.baseURL}/likes/$type/$id/$page';
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
      return UserModel.likesListFromJson(dataMap['likes']);
    }
    return [];
  }

  Future<List<UserModel>> getPollStatistics({idPoll, page, idAnswer}) async {
    var url;
    if (idAnswer != null)
      url = '${API.baseURL}/pollStatistics/$idPoll/$page/$idAnswer';
    else
      url = '${API.baseURL}/pollStatistics/$idPoll/$page/';
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
      return UserModel.votersListFromJson(dataMap['statistics']);
    }
    return [];
  }

  Future<String> uploadResource(String filePath, type, content) async {
    var url = '${API.baseURL}/uploadResource';
    final token = await _getToken();

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));
    final file = await http.MultipartFile.fromPath('upload', filePath);

    imageUploadRequest.fields['type'] = type;
    imageUploadRequest.fields['content'] = content;
    imageUploadRequest.files.add(file);

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    imageUploadRequest.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Accept': '*/*',
      HttpHeaders.userAgentHeader: webViewUserAgent,
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    final response = await http.Response.fromStream(await imageUploadRequest.send());
    
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return dataMap['id_resource'];
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

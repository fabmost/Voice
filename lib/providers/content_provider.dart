import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:voice_inc/models/user_model.dart';

import '../api.dart';
import '../mixins/text_mixin.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../models/cause_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';

class ContentProvider with ChangeNotifier, TextMixin {
  final _storage = FlutterSecureStorage();
  List<ContentModel> _homeContent = [];
  List<ContentModel> _causesContent = [];
  List<UserModel> _usersList = [];
  List<NotificationModel> _notificationsList = [];

  List<ContentModel> get getHome => [..._homeContent];
  List<ContentModel> get getCauses => [..._causesContent];
  List<UserModel> get getUsers => [..._usersList];
  List<NotificationModel> get getNotificationsList => [..._notificationsList];

  Future<bool> getBaseTimeline(int page, String type, [tries = 1]) async {
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

    if (page == 0) {
      _homeContent.clear();
      notifyListeners();
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);

      List timeLine = dataMap['timeline'];
      if (timeLine.isEmpty) {
        return false;
      }
      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'poll':
          case 'regalup_p':
            _homeContent.add(PollModel.fromJson(content));
            break;
          case 'challenge':
          case 'regalup_c':
            _homeContent.add(ChallengeModel.fromJson(content));
            break;
          case 'Tips':
          case 'regalup_ti':
            _homeContent.add(TipModel.fromJson(content));
            break;
          case 'causes':
            _homeContent.add(CauseModel.fromJson(content));
            break;
        }
      });
      notifyListeners();
      return true;
    }
    if (dataMap['action'] == 4 && tries > 3) {
      await _renewToken();
      return getBaseTimeline(page, type, tries + 1);
    }
    return false;
  }

  Future<bool> getCausesCarrousel() async {
    var url = '${API.baseURL}/timeLine/';
    final token = await _getToken();

    _causesContent.clear();
    final Map parameters = {'page': 0, 'type': 'CA'};
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
      if (timeLine.isEmpty) {
        return false;
      }
      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'causes':
            _causesContent.add(CauseModel.fromJson(content));
            break;
        }
      });
      notifyListeners();
      return true;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getCausesCarrousel();
    }
    return false;
  }

  Future<List<ContentModel>> getUserTimeline(
    String user,
    int page,
    String type,
  ) async {
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
          case 'Tips':
            contentList.add(TipModel.fromJson(content));
            break;
          case 'causes':
            contentList.add(CauseModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getUserTimeline(user, page, type);
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
          case 'Tips':
            contentList.add(TipModel.fromJson(content));
            break;
          case 'causes':
            contentList.add(CauseModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getSaved(page);
    }
    return [];
  }

  Future<List<ContentModel>> getTopContent(page) async {
    var url = '${API.baseURL}/topContent/$page';
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
          case 'Tips':
            contentList.add(TipModel.fromJson(content));
            break;
          case 'causes':
            contentList.add(CauseModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getTopContent(page);
    }
    return [];
  }

  Future<void> getTopUsers() async {
    var url = '${API.baseURL}/topUsers/0';
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

      _usersList = UserModel.listFromJson(dataMap['users']);
      notifyListeners();
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getTopUsers();
    }
    return;
  }

  Future<List<ContentModel>> getCategory(String category, int page) async {
    var url = '${API.baseURL}/search/previews/$category/$page';
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
          case 'regalup_p':
            contentList.add(PollModel.fromJson(content));
            break;
          case 'challenge':
          case 'regalup_c':
            contentList.add(ChallengeModel.fromJson(content));
            break;
          case 'Tips':
          case 'regalup_ti':
            contentList.add(TipModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getCategory(category, page);
    }
    return [];
  }

  Future<List<ContentModel>> search(String query, int page) async {
    var url = '${API.baseURL}/search/${query.replaceAll('#', '')}/$page';
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
          case 'Tips':
            contentList.add(TipModel.fromJson(content));
            break;
          case 'causes':
            contentList.add(CauseModel.fromJson(content));
            break;
        }
      });
      return contentList;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return search(query, page);
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
      if (dataMap['data']['id'] == 'null') return null;
      switch (type) {
        case 'P':
          return PollModel.fromJson(dataMap['data']);
        case 'C':
          return ChallengeModel.fromJson(dataMap['data']);
        case 'CA':
          return CauseModel.fromJson(dataMap['data']);
        case 'T':
          return TipModel.fromJson(dataMap['data']);
      }
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getContent(type, id);
    }
    return null;
  }

  Future<CommentModel> getComment(id) async {
    var url = '${API.baseURL}/comment/$id';
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
      return CommentModel.fromJson(dataMap['comments']);
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getComment(id);
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
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getComments(
        id: id,
        page: page,
        type: type,
      );
    }
    return [];
  }

  Future<List<CommentModel>> getReplys({type, idContent, page, id}) async {
    var url = '${API.baseURL}/comments/$type/$idContent/$page/$id';
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
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getComments(
        id: id,
        page: page,
        type: type,
      );
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
          case 'causes':
            break;
        }
        _homeContent[index] = content;
      }
      notifyListeners();

      return hasLiked;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return likeContent(type, id);
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

  Future<double> rateTip(id, rate) async {
    var url = '${API.baseURL}/valueTips/$id';
    final token = await _getToken();
    Map parameters = {
      'value': rate,
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
      return 0;
    }
    if (dataMap['success'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return (dataMap['total'] * 1.0);
    }
    return 0;
  }

  Future<bool> newPoll(
      {name, category, resources, description, answers, taged, hashtag}) async {
    var url = '${API.baseURL}/registerPoll';
    final token = await _getToken();
    Map parameters = {
      'poll': serverSafe(name),
      'category': category,
      'description': serverSafe(description),
      'timelife': null,
      'hashtag': hashtag,
      'answers': answers,
      'resources': resources,
      'taged': taged,
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);
      return true;
    }
    return false;
  }

  Future<bool> newChallenge(
      {name,
      category,
      resource,
      description,
      parameter,
      goal,
      taged,
      hashtag}) async {
    var url = '${API.baseURL}/registerChallenge';
    final token = await _getToken();

    Map parameters = {
      'challenge': serverSafe(name),
      'category': category,
      'resources': [resource],
      'description': serverSafe(description),
      'timelife': null,
      'taged': taged,
      'hashtag': hashtag,
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return true;
    }
    return false;
  }

  Future<bool> newTip(
      {name, category, resource, description, taged, hashtag}) async {
    var url = '${API.baseURL}/registerTips';
    final token = await _getToken();

    Map parameters = {
      'title': serverSafe(name),
      'category': category,
      'resources': [resource],
      'description': serverSafe(description),
      'timelife': null,
      'taged': taged,
      'hashtag': hashtag,
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return true;
    }
    return false;
  }

  Future<bool> newCause(
      {name,
      description,
      resource,
      phone,
      web,
      bank,
      goal,
      taged,
      hashtag}) async {
    var url = '${API.baseURL}/registerCause';
    final token = await _getToken();

    Map parameters = {
      'by': '',
      'title': serverSafe(name),
      'description': serverSafe(description),
      'goal': goal,
      'taged': taged,
      'hashtag': hashtag,
      'resources': [resource],
    };

    if (phone != null) parameters['phone'] = phone;
    if (web != null) parameters['web'] = web;
    if (bank != null) parameters['account'] = bank;

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
      return true;
    }
    return false;
  }

  Future<CommentModel> newComment({comment, type, id, hashtag}) async {
    var url = '${API.baseURL}/registerComments/$type/$id/';
    final token = await _getToken();
    Map parameters = {
      'comment': serverSafe(comment),
      'hashtags': hashtag,
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

  Future<CommentModel> newReply(
      {comment, type, idContent, id, hashtags}) async {
    var url = '${API.baseURL}/registerComments/$type/$idContent/$id';
    final token = await _getToken();
    Map parameters = {
      'comment': serverSafe(comment),
      'hashtags': hashtags,
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
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getLikes(id: id, page: page, type: type);
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
    final response =
        await http.Response.fromStream(await imageUploadRequest.send());

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

  Future<String> uploadResourceGetUrl(String filePath, type, content) async {
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
    final response =
        await http.Response.fromStream(await imageUploadRequest.send());

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return dataMap['url'];
    }
    return null;
  }

  Future<bool> deleteContent({id, type}) async {
    var url = '${API.baseURL}/deleteContent';
    final token = await _getToken();
    Map parameters = {'type': type, 'idt': id};
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
    if (dataMap['success'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return true;
    }
    return false;
  }

  Future<bool> flagContent({id, type, action}) async {
    var url = '${API.baseURL}/reportContent';
    final token = await _getToken();
    Map parameters = {'type': type, 'id_content': id, 'action': action};
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

  Future<bool> getNotifications(page) async {
    var url = '${API.baseURL}/notification/$page';
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
      return false;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      if (page == 0) {
        _notificationsList.clear();
      }
      if (dataMap['notification'].isEmpty) {
        return false;
      }
      _notificationsList
          .addAll(NotificationModel.listFromJson(dataMap['notification']));
      notifyListeners();
      return true;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getNotifications(page);
    }
    return false;
  }

  Future<void> notificationRead(id) async {
    var url = '${API.baseURL}/notifyOpen';
    final token = await _getToken();

    final body = jsonEncode({'id_notify': id});
    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          HttpHeaders.userAgentHeader: webViewUserAgent,
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: body);
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      int index = _notificationsList.indexWhere((element) => element.id == id);
      if (index != -1) {
        final model = _notificationsList[index];
        _notificationsList[index] = NotificationModel(
          id: model.id,
          icon: model.icon,
          idContent: model.idContent,
          message: model.message,
          type: model.type,
          userName: model.userName,
          isNew: false,
        );
        notifyListeners();
      }
      return;
    }
    return;
  }

  Future<Map> getUnread() async {
    var url = '${API.baseURL}/unread';
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
      return {
        'notifications': false,
        'chats': false,
      };
    }
    if (dataMap['status'] == 'success') {
      _saveToken(dataMap['session']['token']);
      return {
        'notifications': dataMap['notifications'],
        'chats': dataMap['chats'],
      };
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getUnread();
    }
    return {
      'notifications': false,
      'chats': false,
    };
  }
}

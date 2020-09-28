import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:voice_inc/models/poll_answer_model.dart';
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
  List<NotificationModel> _notificationsList = [];
  Map<String, PollModel> _polls = {};
  Map<String, ChallengeModel> _challenges = {};
  Map<String, TipModel> _tips = {};
  Map<String, CauseModel> _causes = {};
  Map<String, CommentModel> _comments = {};

  List<NotificationModel> get getNotificationsList => [..._notificationsList];
  Map<String, PollModel> get getPolls => {..._polls};
  Map<String, ChallengeModel> get getChallenges => {..._challenges};
  Map<String, TipModel> get getTips => {..._tips};
  Map<String, CauseModel> get getCausesList => {..._causes};
  Map<String, CommentModel> get getCommentsMap => {..._comments};

  Future<List<ContentModel>> getBaseTimeline(int page, String type,
      [tries = 1]) async {
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
      return [];
    }

    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);

      List<ContentModel> contentList = [];
      List timeLine = dataMap['timeline'];

      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'poll':
          case 'regalup_p':
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
          case 'regalup_c':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
          case 'regalup_ti':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
            break;
          case 'causes':
          case 'regalup_ca':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
            break;
        }
      });
      notifyListeners();
      return contentList;
    }
    if (dataMap['action'] == 4 && tries < 3) {
      await _renewToken();
      return getBaseTimeline(page, type, tries + 1);
    }
    return [];
  }

  Future<List<CauseModel>> getCausesCarrousel() async {
    var url = '${API.baseURL}/timeLine/';
    final token = await _getToken();

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
      return [];
    }
    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);

      List<CauseModel> contentList = [];
      List timeLine = dataMap['timeline'];

      timeLine.forEach((element) {
        Map content = element as Map;
        switch (content['type']) {
          case 'causes':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
            break;
        }
      });
      notifyListeners();
      return contentList;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getCausesCarrousel();
    }
    return [];
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
          case 'regalup_p':
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
          case 'regalup_c':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
          case 'regalup_ti':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
            break;
          case 'causes':
          case 'regalup_ca':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
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
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
            break;
          case 'causes':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
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
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
            break;
          case 'causes':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
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

  Future<List<UserModel>> getTopUsers(page) async {
    var url = '${API.baseURL}/topUsers/$page';
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
      List<UserModel> userList = [];

      userList.addAll(UserModel.listFromJson(dataMap['users']));

      return userList;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getTopUsers(page);
    }
    return [];
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
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
          case 'regalup_c':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
          case 'regalup_ti':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
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
            PollModel poll = PollModel.fromJson(content);
            contentList.add(poll);
            _polls[poll.id] = poll;
            break;
          case 'challenge':
            ChallengeModel challenge = ChallengeModel.fromJson(content);
            contentList.add(challenge);
            _challenges[challenge.id] = challenge;
            break;
          case 'Tips':
            TipModel tip = TipModel.fromJson(content);
            contentList.add(tip);
            _tips[tip.id] = tip;
            break;
          case 'causes':
            CauseModel cause = CauseModel.fromJson(content);
            contentList.add(cause);
            _causes[cause.id] = cause;
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
      if (dataMap['data']['id'] == 'null' || dataMap['data']['id'] == null) return null;
      switch (type) {
        case 'P':
          PollModel poll = PollModel.fromJson(dataMap['data']);
          _polls[poll.id] = poll;
          return poll;
        case 'C':
          ChallengeModel challenge = ChallengeModel.fromJson(dataMap['data']);
          _challenges[challenge.id] = challenge;
          return challenge;
        case 'CA':
          CauseModel cause = CauseModel.fromJson(dataMap['data']);
          _causes[cause.id] = cause;
          return cause;
        case 'T':
          TipModel tip = TipModel.fromJson(dataMap['data']);
          _tips[tip.id] = tip;
          return tip;
      }
      await _saveToken(dataMap['session']['token']);
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
      CommentModel comment = CommentModel.fromJson(dataMap['comments']);
      _comments[comment.id] = comment;
      notifyListeners();
      return comment;
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
      List<CommentModel> commentList = [];
      (dataMap['comments'] as List).forEach((element) {
        CommentModel comment = CommentModel.fromJson(element);
        commentList.add(comment);
        _comments[comment.id] = comment;
      });
      notifyListeners();
      return commentList;
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
      List<CommentModel> commentList = [];
      (dataMap['comments'] as List).forEach((element) {
        CommentModel comment = CommentModel.fromJson(element);
        commentList.add(comment);
        _comments[comment.id] = comment;
      });
      notifyListeners();
      return commentList;
    }
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getReplys(
        id: id,
        page: page,
        type: type,
        idContent: idContent,
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

      switch (type) {
        case 'P':
          PollModel oldPoll = _polls[id];
          final content = PollModel(
            id: oldPoll.id,
            type: oldPoll.type,
            user: oldPoll.user,
            title: oldPoll.title,
            createdAt: oldPoll.createdAt,
            votes: oldPoll.votes,
            likes: hasLiked ? oldPoll.likes + 1 : oldPoll.likes - 1,
            regalups: oldPoll.regalups,
            comments: oldPoll.comments,
            hasVoted: oldPoll.hasVoted,
            hasLiked: hasLiked,
            hasRegalup: oldPoll.hasRegalup,
            hasSaved: oldPoll.hasSaved,
            answers: oldPoll.answers,
            resources: oldPoll.resources,
            body: oldPoll.body,
            certificate: oldPoll.certificate,
            creator: oldPoll.creator,
            description: oldPoll.description,
          );
          _polls[content.id] = content;
          break;
        case 'C':
          ChallengeModel oldChallenge = _challenges[id];
          final content = ChallengeModel(
            id: oldChallenge.id,
            type: oldChallenge.type,
            user: oldChallenge.user,
            title: oldChallenge.title,
            createdAt: oldChallenge.createdAt,
            likes: hasLiked ? oldChallenge.likes + 1 : oldChallenge.likes - 1,
            regalups: oldChallenge.regalups,
            comments: oldChallenge.comments,
            hasLiked: hasLiked,
            hasRegalup: oldChallenge.hasRegalup,
            hasSaved: oldChallenge.hasSaved,
            resources: oldChallenge.resources,
            certificate: oldChallenge.certificate,
            creator: oldChallenge.creator,
            description: oldChallenge.description,
            goal: oldChallenge.goal,
            parameter: oldChallenge.parameter,
          );
          _challenges[content.id] = content;
          break;
        case 'TIP':
          TipModel oldTip = _tips[id];
          final content = TipModel(
            id: oldTip.id,
            type: oldTip.type,
            user: oldTip.user,
            title: oldTip.title,
            createdAt: oldTip.createdAt,
            likes: hasLiked ? oldTip.likes + 1 : oldTip.likes - 1,
            regalups: oldTip.regalups,
            comments: oldTip.comments,
            hasLiked: hasLiked,
            hasRegalup: oldTip.hasRegalup,
            hasSaved: oldTip.hasSaved,
            resources: oldTip.resources,
            certificate: oldTip.certificate,
            creator: oldTip.creator,
            description: oldTip.description,
            body: oldTip.body,
            hasRated: oldTip.hasRated,
            total: oldTip.total,
          );
          _tips[content.id] = content;
          break;
        case 'CA':
          CauseModel oldCause = _causes[id];
          final content = CauseModel(
            id: oldCause.id,
            type: oldCause.type,
            account: oldCause.account,
            by: oldCause.by,
            certificate: oldCause.certificate,
            createdAt: oldCause.createdAt,
            creator: oldCause.creator,
            description: oldCause.description,
            goal: oldCause.goal,
            hasLiked: hasLiked,
            hasRegalup: oldCause.hasRegalup,
            hasSaved: oldCause.hasSaved,
            info: oldCause.info,
            likes: hasLiked ? oldCause.likes + 1 : oldCause.likes - 1,
            phone: oldCause.phone,
            regalups: oldCause.regalups,
            resources: oldCause.resources,
            title: oldCause.title,
            user: oldCause.user,
            web: oldCause.web,
          );
          _causes[content.id] = content;
          break;
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
      bool isLike = dataMap['is_likes'];
      bool isDislike = dataMap['is_dislike'];

      CommentModel comment = _comments[id];
      int newLikes = comment.likes;
      int newDislikes = comment.dislikes;
      if (isLike) {
        newLikes++;
      } else {
        if (comment.hasLike) newLikes--;
      }
      if (isDislike) {
        newDislikes++;
      } else {
        if (comment.hasDislike) newDislikes--;
      }
      final newComment = CommentModel(
        id: comment.id,
        user: comment.user,
        certificate: comment.certificate,
        createdAt: comment.createdAt,
        body: comment.body,
        comments: comment.comments,
        parentId: comment.parentId,
        parentType: comment.parentType,
        hasLike: isLike,
        hasDislike: isDislike,
        likes: newLikes,
        dislikes: newDislikes,
      );
      _comments[newComment.id] = newComment;
      notifyListeners();
      await _saveToken(dataMap['session']['token']);
      return;
    }
    return;
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
      PollModel oldPoll = _polls[id];
      final answers = oldPoll.answers;
      final indexAnswer = answers.indexWhere((element) => element.id == answer);
      if (indexAnswer != -1) {
        final oldAnswer = answers[indexAnswer];
        final newAnswer = PollAnswerModel(
          id: oldAnswer.id,
          answer: oldAnswer.answer,
          count: oldAnswer.count + 1,
          isVote: true,
          url: oldAnswer.url,
        );
        answers[indexAnswer] = newAnswer;
        final content = PollModel(
          id: oldPoll.id,
          type: oldPoll.type,
          user: oldPoll.user,
          title: oldPoll.title,
          createdAt: oldPoll.createdAt,
          votes: oldPoll.votes + 1,
          likes: oldPoll.likes,
          regalups: oldPoll.regalups,
          comments: oldPoll.comments,
          hasVoted: true,
          hasLiked: oldPoll.hasLiked,
          hasRegalup: oldPoll.hasRegalup,
          hasSaved: oldPoll.hasSaved,
          answers: answers,
          resources: oldPoll.resources,
          body: oldPoll.body,
          certificate: oldPoll.certificate,
          creator: oldPoll.creator,
          description: oldPoll.description,
        );
        _polls[content.id] = content;
        notifyListeners();
      }
      await _saveToken(dataMap['session']['token']);
      return;
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
      TipModel oldTip = _tips[id];
      final content = TipModel(
        id: oldTip.id,
        type: oldTip.type,
        user: oldTip.user,
        title: oldTip.title,
        createdAt: oldTip.createdAt,
        likes: oldTip.likes,
        regalups: oldTip.regalups,
        comments: oldTip.comments,
        hasLiked: oldTip.hasLiked,
        hasRegalup: oldTip.hasRegalup,
        hasSaved: oldTip.hasSaved,
        resources: oldTip.resources,
        body: oldTip.body,
        certificate: oldTip.certificate,
        creator: oldTip.creator,
        description: oldTip.description,
        hasRated: true,
        total: (dataMap['total'] * 1.0),
      );
      _tips[content.id] = content;
      notifyListeners();
      await _saveToken(dataMap['session']['token']);
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
      switch (type) {
        case 'P':
          PollModel oldPoll = _polls[id];
          final content = PollModel(
            id: oldPoll.id,
            type: oldPoll.type,
            user: oldPoll.user,
            title: oldPoll.title,
            createdAt: oldPoll.createdAt,
            votes: oldPoll.votes,
            likes: oldPoll.likes,
            regalups: oldPoll.regalups,
            comments: oldPoll.comments + 1,
            hasVoted: oldPoll.hasVoted,
            hasLiked: oldPoll.hasLiked,
            hasRegalup: oldPoll.hasRegalup,
            hasSaved: oldPoll.hasSaved,
            answers: oldPoll.answers,
            resources: oldPoll.resources,
            body: oldPoll.body,
            certificate: oldPoll.certificate,
            creator: oldPoll.creator,
            description: oldPoll.description,
          );
          _polls[content.id] = content;
          break;
        case 'C':
          ChallengeModel oldChallenge = _challenges[id];
          final content = ChallengeModel(
            id: oldChallenge.id,
            type: oldChallenge.type,
            user: oldChallenge.user,
            title: oldChallenge.title,
            createdAt: oldChallenge.createdAt,
            likes: oldChallenge.likes,
            regalups: oldChallenge.regalups,
            comments: oldChallenge.comments + 1,
            hasLiked: oldChallenge.hasLiked,
            hasRegalup: oldChallenge.hasRegalup,
            hasSaved: oldChallenge.hasSaved,
            resources: oldChallenge.resources,
            certificate: oldChallenge.certificate,
            creator: oldChallenge.creator,
            description: oldChallenge.description,
            goal: oldChallenge.goal,
            parameter: oldChallenge.parameter,
          );
          _challenges[content.id] = content;
          break;
        case 'TIP':
          TipModel oldTip = _tips[id];
          final content = TipModel(
            id: oldTip.id,
            type: oldTip.type,
            user: oldTip.user,
            title: oldTip.title,
            createdAt: oldTip.createdAt,
            likes: oldTip.likes,
            regalups: oldTip.regalups,
            comments: oldTip.comments + 1,
            hasLiked: oldTip.hasLiked,
            hasRegalup: oldTip.hasRegalup,
            hasSaved: oldTip.hasSaved,
            resources: oldTip.resources,
            certificate: oldTip.certificate,
            creator: oldTip.creator,
            description: oldTip.description,
            body: oldTip.body,
            hasRated: oldTip.hasRated,
            total: oldTip.total,
          );
          _tips[content.id] = content;
          break;
      }
      CommentModel commentObj = CommentModel.fromJson(dataMap['comment']);
      _comments[commentObj.id] = commentObj;
      notifyListeners();
      return commentObj;
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
      await _saveToken(dataMap['session']['token']);
      CommentModel comment = _comments[id];
      final newComment = CommentModel(
        id: comment.id,
        parentId: comment.parentId,
        parentType: comment.parentType,
        user: comment.user,
        certificate: comment.certificate,
        createdAt: comment.createdAt,
        body: comment.body,
        comments: comment.comments + 1,
        likes: comment.likes,
        dislikes: comment.dislikes,
        hasLike: comment.hasLike,
        hasDislike: comment.hasDislike,
      );
      CommentModel reply = CommentModel.fromJson(dataMap['comment']);
      _comments[newComment.id] = newComment;
      _comments[reply.id] = reply;
      notifyListeners();
      return reply;
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

      switch (type) {
        case 'P':
          PollModel oldPoll = _polls[id];
          final content = PollModel(
            id: oldPoll.id,
            type: oldPoll.type,
            user: oldPoll.user,
            title: oldPoll.title,
            createdAt: oldPoll.createdAt,
            votes: oldPoll.votes,
            likes: oldPoll.likes,
            regalups: hasRegalup ? oldPoll.regalups + 1 : oldPoll.regalups - 1,
            comments: oldPoll.comments,
            hasVoted: oldPoll.hasVoted,
            hasLiked: oldPoll.hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: oldPoll.hasSaved,
            answers: oldPoll.answers,
            resources: oldPoll.resources,
            body: oldPoll.body,
            certificate: oldPoll.certificate,
            creator: oldPoll.creator,
            description: oldPoll.description,
          );
          _polls[content.id] = content;
          break;
        case 'C':
          ChallengeModel oldChallenge = _challenges[id];
          final content = ChallengeModel(
            id: oldChallenge.id,
            type: oldChallenge.type,
            user: oldChallenge.user,
            title: oldChallenge.title,
            createdAt: oldChallenge.createdAt,
            likes: oldChallenge.likes,
            regalups: hasRegalup
                ? oldChallenge.regalups + 1
                : oldChallenge.regalups - 1,
            comments: oldChallenge.comments,
            hasLiked: oldChallenge.hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: oldChallenge.hasSaved,
            resources: oldChallenge.resources,
            certificate: oldChallenge.certificate,
            creator: oldChallenge.creator,
            description: oldChallenge.description,
            goal: oldChallenge.goal,
            parameter: oldChallenge.parameter,
          );
          _challenges[content.id] = content;
          break;
        case 'TIP':
          TipModel oldTip = _tips[id];
          final content = TipModel(
            id: oldTip.id,
            type: oldTip.type,
            user: oldTip.user,
            title: oldTip.title,
            createdAt: oldTip.createdAt,
            likes: oldTip.likes,
            regalups: hasRegalup ? oldTip.regalups + 1 : oldTip.regalups - 1,
            comments: oldTip.comments,
            hasLiked: oldTip.hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: oldTip.hasSaved,
            resources: oldTip.resources,
            certificate: oldTip.certificate,
            creator: oldTip.creator,
            description: oldTip.description,
            body: oldTip.body,
            hasRated: oldTip.hasRated,
            total: oldTip.total,
          );
          _tips[content.id] = content;
          break;
        case 'CA':
          CauseModel oldCause = _causes[id];
          final content = CauseModel(
            id: oldCause.id,
            type: oldCause.type,
            user: oldCause.user,
            title: oldCause.title,
            createdAt: oldCause.createdAt,
            likes: oldCause.likes,
            regalups:
                hasRegalup ? oldCause.regalups + 1 : oldCause.regalups - 1,
            hasLiked: oldCause.hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: oldCause.hasSaved,
            resources: oldCause.resources,
            certificate: oldCause.certificate,
            creator: oldCause.creator,
            description: oldCause.description,
            account: oldCause.account,
            by: oldCause.by,
            goal: oldCause.goal,
            info: oldCause.info,
            phone: oldCause.phone,
            web: oldCause.web,
          );
          _causes[content.id] = content;
          break;
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
    if (dataMap['alert']['action'] == 4) {
      await _renewToken();
      return getPollStatistics(
        idPoll: idPoll,
        page: page,
        idAnswer: idAnswer,
      );
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
    if (dataMap['status'] == 'success') {
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

  Future<void> setThumbnail({String type, String id, video}) async {
    Uint8List mFile = await VideoThumbnail.thumbnailData(
      video: video,
      imageFormat: ImageFormat.JPEG,
      quality: 50,
      timeMs: 1000,
    );

    if (mFile == null) return;

    switch (type) {
      case 'P':
        PollModel oldPoll = _polls[id];
        final content = PollModel(
          id: oldPoll.id,
          type: oldPoll.type,
          user: oldPoll.user,
          title: oldPoll.title,
          createdAt: oldPoll.createdAt,
          votes: oldPoll.votes,
          likes: oldPoll.likes,
          regalups: oldPoll.regalups,
          comments: oldPoll.comments,
          hasVoted: oldPoll.hasVoted,
          hasLiked: oldPoll.hasLiked,
          hasRegalup: oldPoll.hasRegalup,
          hasSaved: oldPoll.hasSaved,
          answers: oldPoll.answers,
          resources: oldPoll.resources,
          body: oldPoll.body,
          certificate: oldPoll.certificate,
          creator: oldPoll.creator,
          description: oldPoll.description,
          thumbnail: mFile,
        );
        _polls[content.id] = content;
        break;
      case 'C':
        ChallengeModel oldChallenge = _challenges[id];
        final content = ChallengeModel(
          id: oldChallenge.id,
          type: oldChallenge.type,
          user: oldChallenge.user,
          title: oldChallenge.title,
          createdAt: oldChallenge.createdAt,
          likes: oldChallenge.likes,
          regalups: oldChallenge.regalups,
          comments: oldChallenge.comments,
          hasLiked: oldChallenge.hasLiked,
          hasRegalup: oldChallenge.hasRegalup,
          hasSaved: oldChallenge.hasSaved,
          resources: oldChallenge.resources,
          certificate: oldChallenge.certificate,
          creator: oldChallenge.creator,
          description: oldChallenge.description,
          goal: oldChallenge.goal,
          parameter: oldChallenge.parameter,
          thumbnail: mFile,
        );
        _challenges[content.id] = content;
        break;
      case 'TIP':
        TipModel oldTip = _tips[id];
        final content = TipModel(
          id: oldTip.id,
          type: oldTip.type,
          user: oldTip.user,
          title: oldTip.title,
          createdAt: oldTip.createdAt,
          likes: oldTip.likes,
          regalups: oldTip.regalups,
          comments: oldTip.comments,
          hasLiked: oldTip.hasLiked,
          hasRegalup: oldTip.hasRegalup,
          hasSaved: oldTip.hasSaved,
          resources: oldTip.resources,
          certificate: oldTip.certificate,
          creator: oldTip.creator,
          description: oldTip.description,
          body: oldTip.body,
          hasRated: oldTip.hasRated,
          total: oldTip.total,
          thumbnail: mFile,
        );
        _tips[content.id] = content;
        break;
      case 'CA':
        CauseModel oldCause = _causes[id];
        final content = CauseModel(
          id: oldCause.id,
          type: oldCause.type,
          account: oldCause.account,
          by: oldCause.by,
          certificate: oldCause.certificate,
          createdAt: oldCause.createdAt,
          creator: oldCause.creator,
          description: oldCause.description,
          goal: oldCause.goal,
          hasLiked: oldCause.hasLiked,
          hasRegalup: oldCause.hasRegalup,
          hasSaved: oldCause.hasSaved,
          info: oldCause.info,
          likes: oldCause.likes,
          phone: oldCause.phone,
          regalups: oldCause.regalups,
          resources: oldCause.resources,
          title: oldCause.title,
          user: oldCause.user,
          web: oldCause.web,
          thumbnail: mFile,
        );
        _causes[content.id] = content;
        break;
    }
    notifyListeners();
    return;
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
      await _saveToken(dataMap['session']['token']);
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

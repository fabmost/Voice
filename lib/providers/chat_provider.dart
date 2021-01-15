import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  List<ChatModel> _chats = [];
  bool needsReload = true;

  List<ChatModel> get getChats => [..._chats];

  Future<List<ChatModel>> getChatsList(page) async {
    var url = '${API.baseURL}/sessionMessage/$page';
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
    if (page == 0) {
      _chats.clear();
    }
    needsReload = false;
    if (dataMap['status'] == 'success') {
      await _saveToken(dataMap['session']['token']);

      List<ChatModel> contentList = [];
      List timeLine = dataMap['session_messages'];

      timeLine.forEach((element) {
        Map content = element as Map;
        ChatModel chat = ChatModel.objectFromJson(content);
        contentList.add(chat);
        _chats.add(chat);
      });

      notifyListeners();
      return contentList;
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getChatsList(page);
    }
    return [];
  }

  Future<List<MessageModel>> getMessages(user, page) async {
    var url = '${API.baseURL}/message/$user/$page';
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

      return MessageModel.listFromJson(dataMap['messages']);
    }
    if (dataMap['action'] == 4) {
      await _renewToken();
      return getMessages(user, page);
    }
    return [];
  }

  void updateChat(String userHash, String message, DateTime time) {
    int index = _chats.indexWhere((element) => element.user.hash == userHash);
    if (index != -1) {
      ChatModel oldChat = _chats.removeAt(index);
      ChatModel newChat = ChatModel(
        id: oldChat.id,
        user: oldChat.user,
        updatedAt: time,
        lastMessage: message,
      );
      _chats.insert(0, newChat);
    } else {
      needsReload = true;
    }
    notifyListeners();
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

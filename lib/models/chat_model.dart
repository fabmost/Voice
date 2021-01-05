import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'user_model.dart';

class ChatModel {
  final String id;
  final UserModel user;
  final DateTime updatedAt;
  final String lastMessage;

  ChatModel({
    @required this.id,
    @required this.user,
    @required this.updatedAt,
    @required this.lastMessage,
  });

  static ChatModel objectFromJson(Map element) {
    return ChatModel(
      id: element['id'],
      user: UserModel(
        name: element['user']['name'],
        lastName: element['user']['last_name'],
        icon: element['user']['icon'],
        hash: element['user']['user_hash'],
      ),
      lastMessage: element['message'],
      updatedAt:
          DateFormat('yyyy-MM-DD HH:mm:ss').parse(element['date'], true),
    );
  }
}

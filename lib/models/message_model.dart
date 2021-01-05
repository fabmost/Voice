import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'user_model.dart';

class MessageModel {
  final String id;
  final String sender;
  final String type;
  final String message;
  final DateTime createdAt;
  final bool read;

  MessageModel({
    @required this.id,
    @required this.sender,
    @required this.type,
    @required this.message,
    @required this.createdAt,
    @required this.read,
  });

  static List<MessageModel> listFromJson(List<dynamic> content) {
    List<MessageModel> mList = [];

    content.forEach((element) {
      mList.add(MessageModel(
        id: element['id'],
        sender:  element['user_name'],
        type: element['type'],
        message: element['message'],
        createdAt:
            DateFormat('yyyy-MM-DD HH:mm:ss').parse(element['date'], true),
        read: element['view'],
      ));
    });

    return mList;
  }
}

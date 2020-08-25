import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chat_messages.dart';
import '../widgets/new_message.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatId;
  bool hasSearched = false;

  void _setChatId(value) {
    setState(() {
      chatId = value;
    });
  }

  void _searchChat(other) async {
    hasSearched = true;
    final user = await Provider.of<AuthProvider>(context, listen: false).getHash();
    final result = await Firestore.instance
        .collection('chats')
        .where('participant_ids', arrayContains: user)
        .getDocuments();
    if (result.documents.isNotEmpty) {
      final res = result.documents.firstWhere((element) => element['participant_ids'].contains(other));
      setState(() {
        chatId = res.documentID;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = ModalRoute.of(context).settings.arguments as Map;
    String other;
    if (map != null) {
      other = map['userId'];
      if (map.containsKey('chatId')) {
        chatId = map['chatId'];
      }
      if (other != null && chatId == null && !hasSearched) {
        _searchChat(other);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: chatId == null ? Container() : ChatMessages(chatId),
          ),
          NewMessage(chatId, other, _setChatId),
        ],
      ),
    );
  }
}

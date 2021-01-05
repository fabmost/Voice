import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/new_message.dart';
import '../widgets/message_bubble.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userHash;

  ChatScreen(this.userHash);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  int _currentPageNumber = 0;
  bool hasSearched = false;
  String userName;

/*
  void _searchChat(other) async {
    hasSearched = true;
    final user =
        await Provider.of<AuthProvider>(context, listen: false).getHash();
    final result = await Firestore.instance
        .collection('chats')
        .where('participant_ids', arrayContains: user)
        .getDocuments();
    if (result.documents.isNotEmpty) {
      final res = result.documents.firstWhere(
        (element) => element['participant_ids'].contains(other),
        orElse: () => null,
      );
      if (res != null) {
        setState(() {
          chatId = res.documentID;
        });
      }
    }
  }
  */

  void _getData() async {
    userName = Provider.of<UserProvider>(context, listen: false).getUser;
    List results = await Provider.of<ChatProvider>(context, listen: false)
        .getMessages(widget.userHash, _currentPageNumber);
    setState(() {
      _list = results;
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*
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
    */
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  reverse: true,
                  itemCount: _list.length,
                  itemBuilder: (ctx, i) {
                    MessageModel mMessage = _list[i];
                    return MessageBubble(
                      key: ValueKey(mMessage.id),
                      message: mMessage.message,
                      isMe: userName == mMessage.sender,
                      userimage: null,
                      username: mMessage.sender,
                    );
                  }),
            ),
            NewMessage('chatId', 'other', null),
          ],
        ),
      ),
    );
  }
}

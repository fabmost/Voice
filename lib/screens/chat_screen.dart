import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../socket_utils.dart';
import '../widgets/new_message.dart';
import '../widgets/message_bubble.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userHash;

  ChatScreen({this.userHash});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ScrollController _scrollController = ScrollController();
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  List<MessageModel> _list = [];
  int _currentPageNumber = 0;
  bool hasSearched = false;
  String userName;
  String myHash;

  void _getData() async {
    userName = Provider.of<UserProvider>(context, listen: false).getUser;
    List results = await Provider.of<ChatProvider>(context, listen: false)
        .getMessages(widget.userHash, _currentPageNumber);
    setState(() {
      _list = results;
    });
  }

  void _sendMessage(String message) {
    SocketUtils.sendSingleChatMessage(
        userName: userName,
        senderHash: myHash,
        receiverHash: widget.userHash,
        message: message,
        type: 'T',
        image: '',
        date: dateFormat.format(DateTime.now()));
  }

  void onChatMessageReceived(data) {
    if (data['hash_receiver'] == myHash || data['hash_sender'] == myHash) {
      Provider.of<ChatProvider>(context, listen: false).updateChat(
        data['hash_sender'] == myHash ? widget.userHash : data['hash_sender'],
        data['message'],
        dateFormat.parse(data['dateapp']),
      );
      if (data['hash_sender'] == widget.userHash ||
          data['hash_receiver'] == widget.userHash) {
        _addMessage(MessageModel(
          id: '${_list.length}',
          sender: data['username'],
          type: data['type'],
          message: data['message'],
          createdAt: dateFormat.parse(data['dateapp']),
          read: false,
        ));
      } else {
        _showNotification(data);
      }
    }
  }

  Future<void> _showNotification(data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Chat',
      'Chat',
      'Notificaciones de chats',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Galup',
      '${data['username']} te ha enviado un mensaje',
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }

  void _addMessage(MessageModel chatMessage) {
    setState(() {
      _list.insert(0, chatMessage);
    });
  }

  void _initSocketListeners() async {
    myHash = await Provider.of<AuthProvider>(context, listen: false).getHash();
    Future.delayed(Duration(seconds: 2), () async {
      SocketUtils.init(myHash);
      SocketUtils.setOnChatMessageReceivedListener(onChatMessageReceived);
    });
  }

  @override
  void initState() {
    _initSocketListeners();
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SocketUtils.disconnect(myHash);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _list.length,
                  itemBuilder: (ctx, i) {
                    MessageModel mMessage = _list[i];
                    return MessageBubble(
                      key: ValueKey(mMessage.id),
                      message: mMessage.message,
                      isMe: userName == mMessage.sender,
                      username: mMessage.sender,
                    );
                  }),
            ),
            NewMessage(_sendMessage),
          ],
        ),
      ),
    );
  }
}

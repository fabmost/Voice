import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_bubble.dart';
import '../providers/auth_provider.dart';

class ChatMessages extends StatelessWidget {
  final String chatId;

  ChatMessages(this.chatId);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).getHash(),
      builder: (ct, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
          stream: Firestore.instance
              .collection('chats')
              .document(chatId)
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final documents = snapshot.data.documents;

            return ListView.builder(
              reverse: true,
              itemCount: documents.length,
              itemBuilder: (ctx, i) => MessageBubble(
                documents[i]['text'],
                documents[i]['userId'],
                documents[i]['username'],
                documents[i]['userimage'] ?? '',
                documents[i]['userId'] == userSnap.data,
                key: ValueKey(documents[i].documentID),
              ),
            );
          },
        );
      },
    );
  }
}

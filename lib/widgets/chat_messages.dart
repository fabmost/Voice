import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  final String chatId;

  ChatMessages(this.chatId);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
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
                documents[i]['username'],
                documents[i]['userimage'] ?? '',
                documents[i]['userId'] == userSnap.data.uid,
                key: ValueKey(documents[i].documentID),
              ),
            );
          },
        );
      },
    );
  }
}

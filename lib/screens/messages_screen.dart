import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

import '../translations.dart';
import '../widgets/appbar.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Text(Translations.of(context).text('title_messages')),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('chats')
                .where('participant_ids', arrayContains: userSnap.data.uid)
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final documents = snapshot.data.documents;
              if (documents.isEmpty) {
                return Center(
                  child: Text(Translations.of(context).text('empty_messages')),
                );
              }

              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: documents.length,
                itemBuilder: (ctx, i) {
                  List ids = documents[i]['participant_ids'];
                  ids.remove(userSnap.data.uid);
                  Map userMap = documents[i]['participants'][ids[0]];
                  
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(ChatScreen.routeName,
                          arguments: {'chatId': documents[i].documentID});
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userMap['user_image'] ?? ''),
                    ),
                    title: Text(userMap['user_name']),
                    subtitle: Text(documents[i]['last_message']),
                    trailing: Text('Hace 5m'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

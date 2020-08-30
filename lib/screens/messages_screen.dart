import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'chat_screen.dart';

import '../translations.dart';
import '../providers/auth_provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).getHash(),
      builder: (ctx, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (userSnap.data == null) {
          return Center(
            child: Text(Translations.of(context).text('empty_messages')),
          );
        }
        return StreamBuilder(
          stream: Firestore.instance
              .collection('chats')
              .where('participant_ids', arrayContains: userSnap.data)
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
                ids.remove(userSnap.data);
                Map userMap = documents[i]['participants'][ids[0]];
                DateTime date = documents[i]['updatedAt'].toDate();

                final now = new DateTime.now();
                final difference = now.difference(date);

                return ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(ChatScreen.routeName, arguments: {
                      'chatId': documents[i].documentID,
                      'userId': ids[0],
                    });
                  },
                  leading: CircleAvatar(
                    backgroundImage: userMap['user_image'] == null
                        ? null
                        : NetworkImage(userMap['user_image']),
                  ),
                  title: Text(userMap['user_name']),
                  subtitle: Text(
                    documents[i]['last_message'],
                    maxLines: 2,
                  ),
                  trailing: Text(timeago.format(now.subtract(difference))),
                );
              },
            );
          },
        );
      },
    );
  }
}

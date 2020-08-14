import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'detail_poll_screen.dart';
import 'detail_challenge_screen.dart';
import 'detail_tip_screen.dart';
import 'detail_cause_screen.dart';
import 'view_profile_screen.dart';
import 'detail_comment_screen.dart';
import '../translations.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  void _toPoll(context, id) {
    Navigator.of(context).pushNamed(DetailPollScreen.routeName, arguments: id);
  }

  void _toChallenge(context, id) {
    Navigator.of(context)
        .pushNamed(DetailChallengeScreen.routeName, arguments: id);
  }

  void _toTip(context, id) {
    Navigator.of(context)
        .pushNamed(DetailTipScreen.routeName, arguments: id);
  }

  void _toCause(context, id) {
    Navigator.of(context).pushNamed(DetailCauseScreen.routeName, arguments: id);
  }

  void _toProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toComment(context, id) {
    Navigator.of(context).pushNamed(DetailCommentScreen.routeName,
        arguments: Firestore.instance.collection('comments').document(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_notifications')),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('notifications')
                .where('users', arrayContains: userSnap.data.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final documents = snapshot.data.documents;
              if (documents.isEmpty) {
                return Center(
                  child: Text('No tienes notificaciones'),
                );
              }

              return ListView.separated(
                separatorBuilder: (context, index) => Divider(height: 1),
                itemCount: documents.length,
                itemBuilder: (ctx, i) {
                  final doc = documents[i];

                  final icon = doc['icon'];
                  final type = doc['type'];
                  bool hasRead = false;
                  if (doc['read'] != null) {
                    hasRead = (doc['read'] as List).contains(userSnap.data.uid);
                  }
                  return Container(
                    color: hasRead ? Colors.white : Color(0x22000000),
                    child: ListTile(
                      onTap: () {
                        Firestore.instance
                            .collection('notifications')
                            .document(doc.documentID)
                            .updateData({
                          'read': FieldValue.arrayUnion([userSnap.data.uid])
                        });
                        switch (type) {
                          case 'poll':
                            return _toPoll(context, doc['content_id']);
                          case 'challenge':
                            return _toChallenge(context, doc['content_id']);
                          case 'tip':
                            return _toTip(context, doc['content_id']);
                          case 'cause':
                            return _toCause(context, doc['content_id']);
                          case 'profile':
                            return _toProfile(context, doc['content_id']);
                          case 'comment':
                            return _toComment(context, doc['content_id']);
                          default:
                            return null;
                        }
                      },
                      leading: icon != null
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context).accentColor,
                              backgroundImage: NetworkImage(icon),
                            )
                          : Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                      title: Text(doc['title']),
                    ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/comment.dart';
import '../widgets/new_comment.dart';

class CommentsScreen extends StatelessWidget {
  static const routeName = '/comments';

  @override
  Widget build(BuildContext context) {
    final reference =
        ModalRoute.of(context).settings.arguments as DocumentReference;
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_comments')),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: FirebaseAuth.instance.currentUser(),
              builder: (ctx, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return StreamBuilder(
                  stream: Firestore.instance
                      .collection('comments')
                      .where('parent', isEqualTo: reference)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (ct, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final documents = snapshot.data.documents;
                    if (documents.isEmpty) {
                      return Center(
                        child: Text(Translations.of(context).text('empty_comments')),
                      );
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, i) {
                        final doc = documents[i];
                        int ups = 0;
                        bool hasUp = false;
                        int downs = 0;
                        bool hasDown = false;

                        if (doc['up'] != null) {
                          ups = doc['up'].length;
                          hasUp = doc['up'].contains(userSnap.data.uid);
                        }
                        if (doc['down'] != null) {
                          downs = doc['down'].length;
                          hasDown = doc['down'].contains(userSnap.data.uid);
                        }

                        return Comment(
                          reference: doc.reference,
                          myId: userSnap.data.uid,
                          title: doc['text'],
                          comments: doc['comments'],
                          date: doc['createdAt'].toDate(),
                          userName: doc['username'],
                          userImage: doc['userImage'],
                          ups: ups,
                          hasUp: hasUp,
                          downs: downs,
                          hasDown: hasDown,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          NewComment(),
        ],
      ),
    );
  }
}

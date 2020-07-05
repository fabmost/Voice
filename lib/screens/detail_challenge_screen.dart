import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/header_challenge.dart';
import '../widgets/new_comment.dart';
import '../widgets/comment.dart';

class DetailChallengeScreen extends StatelessWidget {
  static const routeName = '/challenge';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    final DocumentReference reference = Firestore.instance.collection('content').document(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_challenge')),
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

                    return ListView.builder(
                      itemCount: documents.isEmpty ? 2 : documents.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return HeaderChallenge(reference, userSnap.data.uid);
                        }
                        if (documents.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(Translations.of(context)
                                  .text('empty_comments')),
                            ),
                          );
                        }
                        final doc = documents[i - 1];
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
                          userId: doc['userId'],
                          title: doc['text'],
                          comments: doc['comments'],
                          date: doc['createdAt'].toDate(),
                          userName: doc['username'],
                          userImage: doc['userImage'] ?? '',
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
          NewComment(reference),
        ],
      ),
    );
  }
}
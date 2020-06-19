import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/header_comment.dart';
import '../widgets/comment.dart';
import '../widgets/new_comment.dart';

class DetailCommentScreen extends StatelessWidget {
  static const routeName = '/detail-comment';

  @override
  Widget build(BuildContext context) {
    final reference =
        ModalRoute.of(context).settings.arguments as DocumentReference;
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios'),
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
                        child: Text('Sé el primero en comentar'),
                      );
                    }
                    return ListView.builder(
                      itemCount: documents.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return HeaderComment(reference, userSnap.data.uid);
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

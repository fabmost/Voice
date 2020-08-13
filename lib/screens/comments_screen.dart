import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/comments_list.dart';
import '../widgets/likes_list.dart';
import '../widgets/comment.dart';
import '../widgets/new_comment.dart';

class CommentsScreen extends StatelessWidget {
  final String id;
  final String type;

  CommentsScreen({this.id, this.type});

  Widget _commentsList(context, reference) {
    return Column(
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
                      child:
                          Text(Translations.of(context).text('empty_comments')),
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
        NewComment(
          id: '',
          type: '',
          function: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Translations.of(context).text('title_comments')),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Comentarios',
              ),
              Tab(
                text: 'Likes',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CommentsList(
              id: id,
              type: type,
            ),
            LikesList(
              id: id,
              type: type,
            ),
          ],
        ),
      ),
    );
  }
}

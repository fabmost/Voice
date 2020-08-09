import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_tip.dart';
import 'repost_tip.dart';
import '../custom/galup_font_icons.dart';

class TipUserList extends StatelessWidget {
  final String userId;

  TipUserList(this.userId);

  Widget _tipWidget(doc, userId) {
    int likes = 0;
    bool hasLiked = false;
    if (doc['likes'] != null) {
      likes = doc['likes'].length;
      hasLiked = (doc['likes'] as List).contains(userId);
    }
    int reposts = 0;
    if (doc['reposts'] != null) {
      reposts = doc['reposts'].length;
    }
    bool hasSaved = false;
    if (doc['saved'] != null) {
      hasSaved = (doc['saved'] as List).contains(userId);
    }
    return UserTip(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      description: doc['description'] ?? '',
      images: doc['images'],
      isVideo: doc['is_video'] ?? false,
      comments: doc['comments'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasSaved: hasSaved,
      date: doc['createdAt'].toDate(),
      likesList: doc['likes'] ?? [],
      influencer: doc['influencer'] ?? '',
    );
  }

  Widget _repostTipWidget(doc, userId) {
    return RepostTip(
        reference: doc['parent'] ?? doc.reference,
        myId: userId,
        userId: doc['user_id'],
        userName: doc['user_name'],
        title: doc['title'],
        creatorName: doc['creator_name'],
        creatorImage: doc['creator_image'] ?? '',
        date: doc['originalDate'].toDate(),
        influencer: doc['influencer'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
          stream: Firestore.instance
              .collection('content')
              .where('user_id', isEqualTo: userId)
              .where('type', whereIn: ['tip', 'repost-tip'])
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final documents = snapshot.data.documents;
            if (documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Icon(
                      GalupFont.empty_content,
                      color: Color(0xFF8E8EAB),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Realiza o regalupea tips para verlos aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E8EAB),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, i) {
                final doc = documents[i];
                switch (doc['type']) {
                  case 'tip':
                    return _tipWidget(doc, userSnap.data.uid);
                  case 'repost-tip':
                    return _repostTipWidget(doc, userSnap.data.uid);
                  default:
                    return SizedBox();
                }
              },
            );
          },
        );
      },
    );
  }
}

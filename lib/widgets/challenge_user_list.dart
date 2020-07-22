import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_challenge.dart';
import 'repost_challenge.dart';
import '../custom/galup_font_icons.dart';

class ChallengeUserList extends StatelessWidget {
  final String userId;

  ChallengeUserList(this.userId);

  Widget _challengeWidget(doc, userId) {
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
    return UserChallenge(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      description: doc['description'] ?? '',
      images: doc['images'],
      isVideo: doc['is_video'] ?? false,
      metric: doc['metric_type'],
      goal: doc['metric_goal'],
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

  Widget _repostChallengeWidget(doc, userId) {
    return RepostChallenge(
        reference: doc['parent'] ?? doc.reference,
        myId: userId,
        userId: doc['user_id'],
        userName: doc['user_name'],
        title: doc['title'],
        creatorName: doc['creator_name'],
        creatorImage: doc['creator_image'] ?? '',
        metric: doc['metric_type'],
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
              .where('type', whereIn: ['challenge', 'repost-challenge'])
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
                      'Realiza o regalupea retos para verlos aquí',
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
                  case 'challenge':
                    return _challengeWidget(doc, userSnap.data.uid);
                  case 'repost-challenge':
                    return _repostChallengeWidget(doc, userSnap.data.uid);
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

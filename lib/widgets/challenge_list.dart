import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'challenge.dart';
import '../custom/galup_font_icons.dart';

class ChallengeList extends StatelessWidget {
  final String userId;

  ChallengeList(this.userId);

  Widget _challengeWidget(doc, userId) {
    int likes = 0;
    bool hasLiked = false;
    if (doc['likes'] != null) {
      likes = doc['likes'].length;
      hasLiked = (doc['likes'] as List).contains(userId);
    }
    int reposts = 0;
    bool hasReposted = false;
    if (doc['reposts'] != null) {
      reposts = doc['reposts'].length;
      hasReposted = (doc['reposts'] as List).contains(userId);
    }
    bool hasSaved = false;
    if (doc['saved'] != null) {
      hasSaved = (doc['saved'] as List).contains(userId);
    }
    return Challenge(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      metric: doc['metric_type'],
      goal: doc['metric_goal'],
      comments: doc['comments'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      date: doc['createdAt'].toDate(),
      influencer: doc['influencer'] ?? ''
    );
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
              .where('type', isEqualTo: 'challenge')
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
                      'Este usuario no ha realizado retos',
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
                return _challengeWidget(doc, userSnap.data.uid);
              },
            );
          },
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'poll.dart';
import '../custom/galup_font_icons.dart';

class PollList extends StatelessWidget {
  final String userId;

  PollList(this.userId);

  Widget _pollWidget(doc, userId) {
    int vote = -1;
    bool hasVoted = false;
    int voters = 0;
    if (doc['voters'] != null) {
      voters = doc['voters'].length;
      final item = (doc['voters'] as List).firstWhere(
        (element) => (element as Map).containsKey(userId),
        orElse: () => null,
      );
      if (item != null) {
        hasVoted = true;
        vote = item[userId];
      }
    }
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
    return Poll(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      comments: doc['comments'],
      options: doc['options'],
      votes: doc['results'],
      images: doc['images'] ?? [],
      hasVoted: hasVoted,
      vote: vote,
      voters: voters,
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
              .where('type', isEqualTo: 'poll')
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
                      'Este usuario no ha realizado encuestas',
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
                return _pollWidget(doc, userSnap.data.uid);
              },
            );
          },
        );
      },
    );
  }
}

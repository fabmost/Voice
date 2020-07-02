import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'poll.dart';
import 'challenge.dart';
import 'cause.dart';

class SavedList extends StatelessWidget {
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
      hasVoted: hasVoted,
      vote: vote,
      voters: voters,
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
    );
  }

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
    );
  }

  Widget _causeWidget(doc, userId) {
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
    return Cause(
      reference: doc.reference,
      myId: userId,
      title: doc['title'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      creator: doc['creator'],
      info: doc['info'],
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
              .where('saved', arrayContains: userSnap.data.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final documents = snapshot.data.documents;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, i) {
                final doc = documents[i];
                switch (doc['type']) {
                  case 'poll':
                    return _pollWidget(doc, userSnap.data.uid);
                  case 'challenge':
                    return _challengeWidget(doc, userSnap.data.uid);
                  case 'cause':
                    return _causeWidget(doc, userSnap.data.uid);
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

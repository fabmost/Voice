import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/appbar.dart';
import '../widgets/poll.dart';
import '../widgets/challenge.dart';
import '../widgets/cause.dart';

import '../widgets/repost_poll.dart';
import '../widgets/repost_challenge.dart';
import '../widgets/repost_cause.dart';

class PollsScreen extends StatelessWidget {
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
      images: doc['images'] ?? [],
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

  Widget _repostPollWidget(doc, userId) {
    return RepostPoll(
      reference: doc['parent'] ?? doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      title: doc['title'],
      options: doc['options'],
      creatorName: doc['creator_name'],
      creatorImage: doc['creator_image'] ?? '',
      images: doc['images'] ?? [],
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
    );
  }

  Widget _repostCauseWidget(doc, userId) {
    return RespostCause(
      reference: doc['parent'] ?? doc.reference,
      myId: userId,
      userName: doc['user_name'],
      title: doc['title'],
      creator: doc['creator'],
      info: doc['info'],
    );
  }

  Widget _likesHome(userId, userLikes) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('content')
          .where('category', whereIn: userLikes)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data.documents;
        return _contentList(documents, userId);
      },
    );
  }

  Widget _topHome(userId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('content')
          .orderBy('interactions', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data.documents;
        return _contentList(documents, userId);
      },
    );
  }

  Widget _userHome(userId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('content')
          .where('home', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data.documents;
        if(documents.isEmpty){
          return _topHome(userId);
        }
        return _contentList(documents, userId);
      },
    );
  }

  /**
   * 
   * Guardar detro de un arreglo home el id del usuario
   * Filtrar por arrayContains id de usuario
   * 
   * 
  */

  Widget _contentList(documents, userId) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (ctx, i) {
        final doc = documents[i];
        switch (doc['type']) {
          case 'poll':
            return _pollWidget(doc, userId);
          case 'challenge':
            return _challengeWidget(doc, userId);
          case 'cause':
            return _causeWidget(doc, userId);
          case 'repost-poll':
            return _repostPollWidget(doc, userId);
          case 'repost-challenge':
            return _repostChallengeWidget(doc, userId);
          case 'repost-cause':
            return _repostCauseWidget(doc, userId);
          default:
            return SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Image.asset(
          'assets/logo.png',
          width: 42,
        ),
        true,
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, AsyncSnapshot<FirebaseUser> userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if(userSnap.data.isAnonymous){
            return _topHome(userSnap.data.uid);
          }
          return _userHome(userSnap.data.uid);
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/appbar.dart';
import '../widgets/poll.dart';
import '../widgets/challenge.dart';
import '../widgets/tip.dart';
import '../widgets/cause.dart';

import '../widgets/repost_poll.dart';
import '../widgets/repost_challenge.dart';
import '../widgets/repost_tip.dart';
import '../widgets/repost_cause.dart';

import '../widgets/cause_tile.dart';

class PollsScreen extends StatelessWidget {
  final ScrollController homeController;
  final Function stopVideo;
  VideoPlayerController _controller;

  PollsScreen({Key key, this.homeController, this.stopVideo}) : super(key: key);

  void _scrollToTop() {
    homeController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _playVideo(VideoPlayerController controller) {
    if (_controller != null) {
      _controller.pause();
    }
    _controller = controller;
    stopVideo(_controller);
  }

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
      description: doc['description'] ?? '',
      comments: doc['comments'],
      options: doc['options'],
      votes: doc['voters'],
      hasVoted: hasVoted,
      vote: vote,
      voters: voters,
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      images: doc['images'] ?? [],
      video: doc['video'] ?? '',
      thumb: doc['video_thumb'] ?? '',
      date: doc['createdAt'].toDate(),
      influencer: doc['influencer'] ?? '',
      videoFunction: _playVideo,
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
      description: doc['description'] ?? '',
      metric: doc['metric_type'],
      goal: doc['metric_goal'],
      isVideo: doc['is_video'] ?? false,
      images: doc['images'],
      comments: doc['comments'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      date: doc['createdAt'].toDate(),
      influencer: doc['influencer'] ?? '',
      videoFunction: _playVideo,
    );
  }

  Widget _tipWidget(doc, userId) {
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
    return Tip(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      description: doc['description'] ?? '',
      isVideo: doc['is_video'] ?? false,
      images: doc['images'],
      comments: doc['comments'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      date: doc['createdAt'].toDate(),
      influencer: doc['influencer'] ?? '',
      videoFunction: _playVideo,
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
      date: doc['createdAt'].toDate(),
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
        date: doc['originalDate'].toDate(),
        influencer: doc['influencer'] ?? '');
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

  Widget _repostCauseWidget(doc, userId) {
    return RespostCause(
      reference: doc['parent'] ?? doc.reference,
      myId: userId,
      userName: doc['user_name'],
      title: doc['title'],
      creator: doc['creator'],
      info: doc['info'],
      date: doc['originalDate'].toDate(),
    );
  }

  Widget _causesList(userId) {
    return FutureBuilder(
      future: Firestore.instance
          .collection('content')
          .where('type', isEqualTo: 'cause')
          .orderBy('createdAt', descending: true)
          .getDocuments(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data.documents;
        return Container(
          height: 192,
          child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemCount: documents.length,
              itemBuilder: (context, i) {
                bool hasLiked = false;
                if (documents[i]['likes'] != null) {
                  hasLiked = (documents[i]['likes'] as List).contains(userId);
                }
                return CauseTile(
                  documents[i].documentID,
                  documents[i]['title'],
                  hasLiked,
                );
              }),
        );
      },
    );
  }

/*
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
  */

  Widget _topHome(userId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('content')
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
        if (documents.isEmpty) {
          return _topHome(userId);
        }
        return _contentList(documents, userId);
      },
    );
  }

  Widget _contentList(documents, userId) {
    return ListView.builder(
      controller: homeController,
      itemCount: documents.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 6) {
          return _causesList(userId);
        }
        final doc = (i > 6) ? documents[i - 1] : documents[i];
        final List flagArray = doc['flag'] ?? [];
        if (flagArray.contains(userId)) {
          return Container();
        }
        switch (doc['type']) {
          case 'poll':
            return _pollWidget(doc, userId);
          case 'challenge':
            return _challengeWidget(doc, userId);
          case 'tip':
            return _tipWidget(doc, userId);
          case 'cause':
            return _causeWidget(doc, userId);
          case 'repost-poll':
            return _repostPollWidget(doc, userId);
          case 'repost-challenge':
            return _repostChallengeWidget(doc, userId);
          case 'repost-tip':
            return _repostTipWidget(doc, userId);
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
        GestureDetector(
          onTap: _scrollToTop,
          child: Image.asset(
            'assets/logo.png',
            width: 42,
          ),
        ),
        true,
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, AsyncSnapshot<FirebaseUser> userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnap.data.isAnonymous) {
            return _topHome(userSnap.data.uid);
          }
          return _userHome(userSnap.data.uid);
        },
      ),
    );
  }
}

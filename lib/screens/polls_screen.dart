import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/appbar.dart';
import '../widgets/poll.dart';
import '../widgets/challenge.dart';
import '../widgets/tip.dart';
import '../widgets/cause.dart';
import '../widgets/cause_user.dart';

import '../widgets/repost_poll.dart';
import '../widgets/repost_challenge.dart';
import '../widgets/repost_tip.dart';
import '../widgets/repost_cause.dart';

import '../widgets/cause_tile.dart';
import '../widgets/influencer_item.dart';

class PollsScreen extends StatefulWidget {
  final ScrollController homeController;
  final Function stopVideo;

  PollsScreen({Key key, this.homeController, this.stopVideo}) : super(key: key);

  @override
  _PollsScreenState createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  VideoPlayerController _controller;
  List<DocumentSnapshot> _usersList = [];
  List<DocumentSnapshot> _causesList = [];

  void _scrollToTop() {
    widget.homeController.animateTo(
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
    widget.stopVideo(_controller);
  }

  void _getUsers() async {
    final results = await Firestore.instance
        .collection('users')
        .orderBy('followers_count', descending: true)
        .limit(20)
        .getDocuments();
    setState(() {
      _usersList = results.documents;
    });
  }

  void _getCauses() async {
    final results = await Firestore.instance
        .collection('content')
        .where('type', isEqualTo: 'cause')
        .orderBy('createdAt', descending: true)
        .getDocuments();
    setState(() {
      _causesList = results.documents;
    });
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
    bool hasRated = false;
    double rate = 0;
    if (doc['rates'] != null) {
      int amount = doc['rates'].length;
      double rateSum = 0;
      (doc['rates'] as List).forEach((element) {
        Map map = (element as Map);
        if (map.containsKey(userId)) {
          hasRated = true;
        }
        rateSum += map.values.first;
      });
      if (amount > 0 && rateSum > 0) {
        rate = rateSum / amount;
      }
    }
    return Tip(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      hasRated: hasRated,
      rating: rate,
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

    if (doc['info'] != null && doc['info'].toString().isNotEmpty)
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
    return CauseUser(
      reference: doc.reference,
      myId: userId,
      userId: doc['user_id'],
      userName: doc['user_name'],
      userImage: doc['user_image'] ?? '',
      title: doc['title'],
      description: doc['description'] ?? '',
      goal: doc['goal'],
      isVideo: doc['is_video'] ?? false,
      images: doc['images'],
      likes: likes,
      hasLiked: hasLiked,
      reposts: reposts,
      hasReposted: hasReposted,
      hasSaved: hasSaved,
      date: doc['createdAt'].toDate(),
      influencer: doc['influencer'] ?? '',
      bank: doc['bank'] ?? '',
      contact: doc['phone'],
      web: doc['web'],
      videoFunction: _playVideo,
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
        description: doc['description'] ?? '',
        images: doc['images'] ?? [],
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
      date: doc['originalDate'].toDate(),
      info: doc['info'],
      influencer: doc['influencer'] ?? '',
      userImage: doc['creator_image'] ?? '',
      images: doc['images'] ?? [],
    );
  }

  Widget _causesListWidget(userId) {
    if (_causesList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 192,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 16),
        itemCount: _causesList.length,
        itemBuilder: (context, i) {
          bool hasLiked = false;
          if (_causesList[i]['likes'] != null) {
            hasLiked = (_causesList[i]['likes'] as List).contains(userId);
          }
          return CauseTile(
            _causesList[i].documentID,
            _causesList[i]['title'],
            hasLiked,
          );
        },
      ),
    );
  }

  Widget _influencersListWidget(userId) {
    if (_usersList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Galuperos que puedas conocer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemCount: _usersList.length,
              itemBuilder: (context, i) {
                return InfluencerItem(
                  reference: _usersList[i].reference,
                  userName: _usersList[i]['user_name'],
                  image: _usersList[i]['image'] ?? '',
                  isFollowing: true,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _topHome(userId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('content')
          .orderBy('createdAt', descending: true)
          .limit(100)
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

/*
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
  */

  Widget _contentList(documents, userId) {
    return ListView.builder(
      controller: widget.homeController,
      itemCount: documents.length + 2,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return _influencersListWidget(userId);
        }
        if (i == 6) {
          return _causesListWidget(userId);
        }
        final doc = (i > 6) ? documents[i - 2] : documents[i - 1];
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
  void didChangeDependencies() {
    _getUsers();
    _getCauses();
    super.didChangeDependencies();
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
          return _topHome(userSnap.data.uid);
        },
      ),
    );
  }
}

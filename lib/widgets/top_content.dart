import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_tile.dart';
import 'challenge_tile.dart';
import 'tip_tile.dart';
import 'cause_tile.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../models/cause_model.dart';
import '../providers/content_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class TopContent extends StatefulWidget {
  final Function setVideo;

  TopContent(this.setVideo);

  @override
  _FilteredContentState createState() => _FilteredContentState();
}

class _FilteredContentState extends State<TopContent> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<ContentModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'top',
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      description: content.description,
      votes: content.votes,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      hasVoted: content.hasVoted,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      answers: content.answers,
      resources: content.resources,
    );
  }

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      description: content.description,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      parameter: content.parameter,
      goal: content.goal,
      resources: content.resources,
    );
  }

  Widget _tipWidget(TipModel content) {
    return TipTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      description: content.description,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      rate: content.total,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      hasRated: content.hasRated,
      resources: content.resources,
    );
  }

  Widget _causeWidget(CauseModel content) {
    return CauseTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      description: content.description,
      info: content.info,
      goal: content.goal,
      phone: content.phone,
      web: content.web,
      bank: content.account,
      likes: content.likes,
      regalups: content.regalups,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      resources: content.resources,
      regalupName: content.creator,
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore &&
            _currentPageNumber < 3) {
          _currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getTopContent(_currentPageNumber)
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
              } else {
                _list.addAll(newObjects);
              }
            });
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    loadMoreStatus = LoadMoreStatus.LOADING;
    List results = await Provider.of<ContentProvider>(context, listen: false)
        .getTopContent(_currentPageNumber);
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _list = results;
      }
      _isLoading = false;
    });
    loadMoreStatus = LoadMoreStatus.STABLE;
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : NotificationListener(
            onNotification: onNotification,
            child: ListView.builder(
              controller: scrollController,
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final doc = _list[i];
                switch (doc.type) {
                  case 'poll':
                    return _pollWidget(doc);
                  case 'challenge':
                    return _challengeWidget(doc);
                  case 'Tips':
                    return _tipWidget(doc);
                  case 'causes':
                    return _causeWidget(doc);
                  default:
                    return SizedBox();
                }
              },
            ),
          );
  }
}

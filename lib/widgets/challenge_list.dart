import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'challenge_tile.dart';
import '../custom/galup_font_icons.dart';
import '../models/content_model.dart';
import '../models/challenge_model.dart';
import '../providers/content_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class ChallengeList extends StatefulWidget {
  final String userId;

  ChallengeList(this.userId);

  @override
  _ChallengeListState createState() => _ChallengeListState();
}

class _ChallengeListState extends State<ChallengeList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<ContentModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

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
      resources: content.resources
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getUserTimeline(widget.userId, _currentPageNumber, 'C')
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
    List results = await Provider.of<ContentProvider>(context, listen: false)
        .getUserTimeline(widget.userId, _currentPageNumber, 'C');
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _list = results;
      }
      _isLoading = false;
    });
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
        : _list.isEmpty
            ? Center(
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
              )
            : NotificationListener(
                onNotification: onNotification,
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: _list.length,
                    itemBuilder: (context, i) => _challengeWidget(_list[i])),
              );
  }
}

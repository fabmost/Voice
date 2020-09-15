import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'challenge_tile.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';
import '../models/challenge_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class ChallengeUserList extends StatefulWidget {
  final String userId;
  final ScrollController scrollController;
  final Function setVideo;

  ChallengeUserList(this.userId, this.scrollController, this.setVideo);

  @override
  _ChallengeUserListState createState() => _ChallengeUserListState();
}

class _ChallengeUserListState extends State<ChallengeUserList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<ContentModel> _list = [];
  int _currentPageNumber;
  bool _isLoading = false;
  bool _hasMore = true;

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
      title: content.title,
      description: content.description,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      goal: content.goal,
      parameter: content.parameter,
      hasSaved: content.hasSaved,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      resources: content.resources,
    );
  }

  Widget _repostChallengeWidget(ChallengeModel content) {
    return ChallengeTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
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
      regalupName: content.creator,
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (widget.scrollController.position.maxScrollExtent >
              widget.scrollController.offset &&
          widget.scrollController.position.maxScrollExtent -
                  widget.scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getUserTimeline(widget.userId, _currentPageNumber, 'C')
              .then((newContent) {
            setState(() {
              if (newContent.isEmpty) {
                _hasMore = false;
              } else {
                if (newContent.length < 10) {
                  _hasMore = false;
                }
                _list.addAll(newContent);
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
        if (results.length < 10) {
          _hasMore = false;
        }
        _list = results;
      }
      _isLoading = false;
    });
  }

  Future<void> _resetData() async {
    loadMoreStatus = LoadMoreStatus.LOADING;
    _currentPageNumber = 0;

    List results = await Provider.of<ContentProvider>(context, listen: false)
        .getUserTimeline(widget.userId, _currentPageNumber, 'C');
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        if (results.length < 10) {
          _hasMore = false;
        }
        _list = results;
      }
    });
    loadMoreStatus = LoadMoreStatus.STABLE;
    return;
  }

  @override
  void initState() {
    _currentPageNumber = 0;
    _getData();
    super.initState();
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Realiza o regalupea retos para verlos aquí',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8EAB),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : NotificationListener(
                onNotification: onNotification,
                child: RefreshIndicator(
                  onRefresh: _resetData,
                  child: ListView.builder(
                    itemCount: _hasMore ? _list.length + 1 : _list.length,
                    itemBuilder: (context, i) {
                      if (i == _list.length)
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        );
                      switch (_list[i].type) {
                        case 'challenge':
                          return _challengeWidget(_list[i]);
                        case 'regalup_c':
                          return _repostChallengeWidget(_list[i]);
                      }
                      return Container();
                    },
                  ),
                ),
              );
  }
}

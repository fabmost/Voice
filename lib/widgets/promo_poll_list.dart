import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_promo_tile.dart';
import '../custom/galup_font_icons.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../providers/content_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class PromoPollList extends StatefulWidget {
  final String userId;
  final ScrollController scrollController;

  PromoPollList(this.userId, this.scrollController);

  @override
  _PollListState createState() => _PollListState();
}

class _PollListState extends State<PromoPollList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<ContentModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  
  Widget _promoPollWidget(PollModel content) {
    return PollPromoTile(
      reference: 'user',
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
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
      terms: content.terms,
      message: content.message,
      promoUrl: content.promoUrl,
      regalupName: content.creator,
      audio: content.audio,
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
              .getUserTimeline(widget.userId, _currentPageNumber, 'POP')
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
              } else {
                if (newObjects.length < 10) {
                  _hasMore = false;
                }
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
        .getUserTimeline(widget.userId, _currentPageNumber, 'POP');
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
        .getUserTimeline(widget.userId, _currentPageNumber, 'POP');
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
    _getData();
    super.initState();
  }

  @override
  void dispose() {
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
                      'Este usuario no ha realizado encuestas',
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
                        case 'promo_p':
                        case 'regalup_promo_p':
                          return _promoPollWidget(_list[i]);
                      }
                      return Container();
                    },
                  ),
                ),
              );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_poll_tile.dart';
import 'repost_poll.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class PollUserList extends StatefulWidget {
  final String userId;
  final ScrollController scrollController;
  final Function setVideo;

  PollUserList(this.userId, this.scrollController, this.setVideo);

  @override
  _PollUserListState createState() => _PollUserListState();
}

class _PollUserListState extends State<PollUserList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<ContentModel> _list = [];
  int _currentPageNumber;
  bool _isLoading = false;
  bool _hasMore = true;

  Widget _pollWidget(PollModel content) {
    return UserPollTile(
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
      answers: content.answers,
      resources: content.resources,
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (widget.scrollController.position.maxScrollExtent > widget.scrollController.offset &&
          widget.scrollController.position.maxScrollExtent - widget.scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getUserTimeline(widget.userId, _currentPageNumber, 'P')
              .then((newContent) {
            setState(() {
              if (newContent.isEmpty) {
                _hasMore = false;
              } else {
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
        .getUserTimeline(widget.userId, _currentPageNumber, 'P');
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
    _currentPageNumber = 0;
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    //scrollController.dispose();
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
                      'Realiza o regalupea encuestas para verlas aquí',
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
                  itemCount: _list.length,
                  itemBuilder: (context, i) => _pollWidget(_list[i]),
                ),
              );
  }
}

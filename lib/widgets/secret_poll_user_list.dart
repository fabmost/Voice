import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'secret_poll_tile.dart';
import 'user_secret_poll_tile.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class SecretPollUserList extends StatefulWidget {
  final ScrollController scrollController;
  final Function setVideo;

  SecretPollUserList(this.scrollController, this.setVideo);

  @override
  _PollUserListState createState() => _PollUserListState();
}

class _PollUserListState extends State<SecretPollUserList> {
  String userId;
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<ContentModel> _list = [];
  int _currentPageNumber;
  bool _isLoading = false;
  bool _hasMore = true;
  VideoPlayerController _controller;

  void _playVideo(VideoPlayerController controller) {
    if(_controller != null){
      _controller.pause();
    }
    _controller = controller;
  }

  Widget _sharedPollWidget(int pos, PollModel content) {
    return SecretPollTile(
      reference: 'list',
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
      videoFunction: _playVideo,
      groups: content.groups,
      pos: pos,
      deleteFunction: _deleteContent,
      audio: content.audio,
    );
  }

  Widget _pollWidget(PollModel content) {
    return UserSecretPollTile(
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
      removeFunction: _removeContent,
      groups: content.groups,
      audio: content.audio,
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (widget.scrollController.position.maxScrollExtent >=
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
              .getUserTimeline(userId, _currentPageNumber, 'SP')
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

  void _removeContent(id) {
    setState(() {
      _list.removeWhere((element) => element.id == id);
    });
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    userId = Provider.of<UserProvider>(context, listen: false).getUser;
    List<ContentModel> results =
        await Provider.of<ContentProvider>(context, listen: false)
            .getUserTimeline(userId, _currentPageNumber, 'SP');
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
        .getUserTimeline(userId, _currentPageNumber, 'SP');
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

  void _deleteContent(pos) {
    setState(() {
      _list.removeAt(pos);
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Realiza o regalupea encuestas para verlas aquí',
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
                        case 'secret_p':
                          if (_list[i].user.userName == userId)
                            return _pollWidget(_list[i]);
                          return _sharedPollWidget(i, _list[i]);
                      }
                      return Container();
                    },
                  ),
                ),
              );
  }
}

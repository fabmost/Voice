import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_tile.dart';
import 'challenge_tile.dart';
import '../custom/galup_font_icons.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../providers/content_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class SavedList extends StatefulWidget {
  final ScrollController scrollController;
  final Function setVideo;

  SavedList(this.scrollController, this.setVideo);

  @override
  _SavedListState createState() => _SavedListState();
}

class _SavedListState extends State<SavedList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<ContentModel> _list = [];
  int _currentPageNumber;
  bool _isLoading = false;
  bool _hasMore = true;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'saved',
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
        resources: content.resources);
  }

  Widget _causeWidget(doc) {
    return Container();
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
              .getSaved(_currentPageNumber)
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
        .getSaved(_currentPageNumber);
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
                      GalupFont.empty_saved,
                      color: Color(0xFF8E8EAB),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no guardas ningún reto o encuesta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E8EAB),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _hasMore ? _list.length + 1 : _list.length,
                itemBuilder: (context, i) {
                  if (i == _list.length)
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  final doc = _list[i];
                  switch (doc.type) {
                    case 'poll':
                      return _pollWidget(doc);
                    case 'challenge':
                      return _challengeWidget(doc);
                    case 'cause':
                      return _causeWidget(doc);
                    default:
                      return SizedBox();
                  }
                },
              );
  }
}

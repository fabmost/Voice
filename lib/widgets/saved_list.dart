import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'poll_tile.dart';
import 'private_poll_tile.dart';
import 'poll_promo_tile.dart';
import 'challenge_tile.dart';
import 'tip_tile.dart';
import 'cause_tile.dart';
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
  VideoPlayerController _controller;

  void _playVideo(VideoPlayerController controller) {
    if (_controller != null) {
      _controller.pause();
    }
    _controller = controller;
  }

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'saved',
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
      audio: content.audio,
    );
  }

  Widget _privatepollWidget(PollModel content) {
    return PrivatePollTile(
      reference: 'saved',
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
      audio: content.audio,
    );
  }

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

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
        reference: 'saved',
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
        resources: content.resources);
  }

  Widget _tipWidget(content) {
    return TipTile(
      reference: 'saved',
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
      rate: content.total,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      hasRated: content.hasRated,
      resources: content.resources,
    );
  }

  Widget _causeWidget(content) {
    return CauseTile(
      reference: 'saved',
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
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
        if (results.length < 10) _hasMore = false;
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Aún no guardas ningún reto, encuesta, tip o causa',
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
                    case 'private_p':
                      return _privatepollWidget(doc);
                    case 'promo_p':
                      return _promoPollWidget(doc);
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
              );
  }
}

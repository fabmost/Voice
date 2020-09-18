import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../widgets/poll_tile.dart';
import '../widgets/challenge_tile.dart';
import '../widgets/tip_tile.dart';
import '../widgets/cause_tile.dart';
import '../providers/content_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class SearchResultsScreen extends StatefulWidget {
  final String query;

  SearchResultsScreen(this.query);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<ContentModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'search',
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
      certificate: content.certificate,
      resources: content.resources,
    );
  }

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
      reference: 'search',
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
    );
  }

  Widget _causeWidget(content) {
    return CauseTile(
      reference: 'search',
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

  Widget _tipWidget(TipModel content) {
    return TipTile(
      reference: 'search',
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
              .search(widget.query, _currentPageNumber)
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
    String query = widget.query.replaceAll('#', '').trim();
    List results = await Provider.of<ContentProvider>(context, listen: false)
        .search(removeDiacritics(query), _currentPageNumber);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? Center(
                  child: Text('Sin resultados'),
                )
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
                        case 'cause':
                          return _causeWidget(doc);
                        case 'tip':
                          return _tipWidget(doc);
                        default:
                          return SizedBox();
                      }
                    },
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../widgets/poll_tile.dart';
import '../widgets/challenge_tile.dart';
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
      reference: 'home',
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

  Widget _causeWidget(doc) {
    /*
    return SearchCause(
      reference: Firestore.instance.collection('content').document(id),
      title: doc['title'],
      creator: doc['creator'],
      info: doc['info'],
    );
    */
    return Container();
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
    List results = await Provider.of<ContentProvider>(context, listen: false)
        .search(widget.query, _currentPageNumber);
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
                        default:
                          return SizedBox();
                      }
                    },
                  ),
                ),
    );
  }
}

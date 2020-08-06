import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_tile.dart';
import 'challenge_tile.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class HomeList extends StatefulWidget {
  final List<ContentModel> mList;

  HomeList(this.mList);

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  int currentPageNumber;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      votes: content.votes,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      hasVoted: content.hasVoted,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
    );
  }

  Widget _challengeWidget(content) {
    return ChallengeTile(
      
    );
  }

  Widget _causeWidget(content) {
    return Container();
  }

  Widget _repostPollWidget(content) {
    return Container();
  }

  Widget _repostChallengeWidget(content) {
    return Container();
  }

  Widget _repostCauseWidget(content) {
    return Container();
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadMoreStatus != null && loadMoreStatus == LoadMoreStatus.STABLE) {
          currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getBaseTimeline(currentPageNumber, null)
              .then((moviesObject) {
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  @override
  void initState() {
    //movies = widget.movies.movies;
    currentPageNumber = 0;
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.mList.length + 1,
        itemBuilder: (ctx, i) {
          if(i == widget.mList.length){
            return Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ));
          }
          final doc = widget.mList[i];
          switch (doc.type) {
            case 'poll':
              return _pollWidget(doc);
            case 'challenge':
              return _challengeWidget(doc);
            case 'cause':
              return _causeWidget(doc);
            case 'repost-poll':
              return _repostPollWidget(doc);
            case 'repost-challenge':
              return _repostChallengeWidget(doc);
            case 'repost-cause':
              return _repostCauseWidget(doc);
            default:
              return SizedBox();
          }
        },
      ),
    );
  }
}
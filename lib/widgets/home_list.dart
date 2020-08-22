import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_tile.dart';
import 'challenge_tile.dart';
import 'tip_tile.dart';
import 'cause_card.dart';
import 'user_card.dart';
import '../providers/content_provider.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../models/cause_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class HomeList extends StatefulWidget {
  final ScrollController scrollController;
  final List<ContentModel> mList;
  final List<ContentModel> mCauses;
  final List<UserModel> mUsers;

  HomeList(this.scrollController, this.mList, this.mCauses, this.mUsers);

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  int currentPageNumber;
  bool _hasMore = true;
  bool _requestedUsers = false;
  bool _requestedCauses = false;

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

  Widget _tipWidget(TipModel content) {
    return TipTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
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
    return Container();
  }

  Widget _repostPollWidget(PollModel content) {
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
      regalupName: content.creator,
    );
  }

  Widget _repostChallengeWidget(ChallengeModel content) {
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
      regalupName: content.creator,
    );
  }

  Widget _repostCauseWidget(content) {
    return Container();
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (widget.scrollController.position.maxScrollExtent > widget.scrollController.offset &&
          widget.scrollController.position.maxScrollExtent - widget.scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getBaseTimeline(currentPageNumber, null)
              .then((moviesObject) {
            _hasMore = moviesObject;
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  Future<void> _refreshTimeLine() async {
    currentPageNumber = 0;
    loadMoreStatus = LoadMoreStatus.LOADING;
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getBaseTimeline(currentPageNumber, null);
    _hasMore = result;
    loadMoreStatus = LoadMoreStatus.STABLE;
    return;
  }

  Widget _usersCarrousel() {
    if (widget.mUsers.isEmpty && !_requestedUsers) {
      _requestedUsers = true;
      Provider.of<ContentProvider>(context, listen: false).getTopUsers();
      return Container(
        height: 42,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'Galuperos que puedas conocer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemCount: widget.mUsers.length,
              itemBuilder: (context, i) {
                UserModel model = widget.mUsers[i];
                return UserCard(
                  userName: model.userName,
                  icon: model.icon,
                  isFollowing: model.isFollowing,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _causesCarrousel() {
    if (widget.mCauses.isEmpty && !_requestedCauses) {
      _requestedCauses = true;
      Provider.of<ContentProvider>(context, listen: false).getCausesCarrousel();
      return Container(
        height: 42,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 192,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 16),
        itemCount: widget.mCauses.length,
        itemBuilder: (context, i) {
          CauseModel model = widget.mCauses[i];
          return CauseCard(
            id: model.id,
            title: model.cause,
            liked: model.hasLiked,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    //movies = widget.movies.movies;
    currentPageNumber = 0;
    super.initState();
  }

  @override
  void dispose() {
    //widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: RefreshIndicator(
        onRefresh: _refreshTimeLine,
        child: ListView.builder(
          controller: widget.scrollController,
          itemCount: widget.mList.length + 2,
          itemBuilder: (ctx, i) {
            if (i == widget.mList.length + 1) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ));
            }
            if (i == 0) {
              return _usersCarrousel();
            }
            /*
            if (i == 6) {
              return _causesCarrousel();
            }
            */
            final doc = widget.mList[
                i - 1]; //(i > 6) ? widget.mList[i - 2] : widget.mList[i - 1];
            switch (doc.type) {
              case 'poll':
                return _pollWidget(doc);
              case 'challenge':
                return _challengeWidget(doc);
              case 'tip':
                return _tipWidget(doc);
              case 'cause':
                return _causeWidget(doc);
              case 'regalup_p':
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
      ),
    );
  }
}

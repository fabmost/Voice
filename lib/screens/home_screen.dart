import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/poll_tile.dart';
import '../widgets/poll_promo_tile.dart';
import '../widgets/challenge_tile.dart';
import '../widgets/tip_tile.dart';
import '../widgets/cause_tile.dart';
import '../widgets/cause_card.dart';
import '../widgets/user_card.dart';
import '../providers/content_provider.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../models/cause_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  HomeScreen(this.scrollController);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  List<UserModel> mUsers = [];
  List<CauseModel> mCauses = [];
  List<ContentModel> mList = [];
  int currentPageNumber;
  bool _hasMore = true;
  bool _requestMoreUsers = false;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'home',
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
    );
  }

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
      reference: 'home',
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

  Widget _tipWidget(TipModel content) {
    return TipTile(
      reference: 'home',
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

  Widget _causeWidget(CauseModel content) {
    return CauseTile(
      reference: 'home',
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

  Widget _repostPollWidget(PollModel content) {
    return PollTile(
      reference: 'home_${content.creator}',
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      title: content.title,
      certificate: content.certificate,
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
      reference: 'home_${content.creator}',
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

  Widget _repostTipWidget(TipModel content) {
    return TipTile(
      reference: 'home_${content.creator}',
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
      regalupName: content.creator,
    );
  }

  Widget _repostCauseWidget(content) {
    return CauseTile(
      reference: 'home_${content.creator}',
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
      regalupName: content.creator,
    );
  }

  Widget _promoPollWidget(PollModel content) {
    return PollPromoTile(
      reference: 'home',
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
      company: content.company,
      message: content.message,
      promoUrl: content.promoUrl,
      prize: content.prize,
      regalupName: content.creator,
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      var triggerFetchMoreSize =
          0.7 * widget.scrollController.position.maxScrollExtent;
      if (widget.scrollController.position.pixels > triggerFetchMoreSize) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getBaseTimeline(currentPageNumber, null)
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
              } else {
                mList.addAll(newObjects);
              }
            });
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
    final results = await Provider.of<ContentProvider>(context, listen: false)
        .getBaseTimeline(currentPageNumber, null);
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        mList = results;
      }
    });
    loadMoreStatus = LoadMoreStatus.STABLE;
    return;
  }

  void _moreUsers() async {
    final usersResult =
        await Provider.of<ContentProvider>(context, listen: false)
            .getTopUsers(1);
    _requestMoreUsers = true;
    setState(() {
      mUsers.addAll(usersResult);
    });
  }

  Widget _usersCarrousel() {
    if (mUsers.isEmpty) {
      return Container(
        height: 42,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    if (!_requestMoreUsers) {
      _moreUsers();
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
              itemCount: mUsers.length,
              itemBuilder: (context, i) {
                UserModel model = mUsers[i];
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
    if (mCauses.isEmpty) {
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
        itemCount: mCauses.length,
        itemBuilder: (context, i) {
          CauseModel model = mCauses[i];
          return CauseCard(
            id: model.id,
            title: model.title,
            liked: model.hasLiked,
          );
        },
      ),
    );
  }

  void _fetchData() async {
    loadMoreStatus = LoadMoreStatus.LOADING;
    final results = await Provider.of<ContentProvider>(context, listen: false)
        .getBaseTimeline(currentPageNumber, null);
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        mList = results;
      }
    });
    loadMoreStatus = LoadMoreStatus.STABLE;

    final usersResult =
        await Provider.of<ContentProvider>(context, listen: false)
            .getTopUsers(0);
    setState(() {
      mUsers = usersResult;
    });
    final causesResult =
        await Provider.of<ContentProvider>(context, listen: false)
            .getCausesCarrousel();
    setState(() {
      mCauses = causesResult;
    });
  }

  @override
  void initState() {
    currentPageNumber = 0;
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    //widget.scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (mList.isEmpty) return Center(child: CircularProgressIndicator());
    return NotificationListener(
      onNotification: onNotification,
      child: RefreshIndicator(
        onRefresh: _refreshTimeLine,
        child: ListView.builder(
          controller: widget.scrollController,
          itemCount: (mList.length < 6) ? mList.length + 1 : mList.length + 3,
          itemBuilder: (ctx, i) {
            if ((mList.length > 6 && i == mList.length + 2)) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ));
            }
            if (i == 0) {
              return _usersCarrousel();
            }
            if (i == 6) {
              return _causesCarrousel();
            }
            final doc = (i > 6) ? mList[i - 2] : mList[i - 1];
            switch (doc.type) {
              case 'poll':
                return _pollWidget(doc);
              case 'challenge':
                return _challengeWidget(doc);
              case 'Tips':
                return _tipWidget(doc);
              case 'causes':
                return _causeWidget(doc);
              case 'regalup_p':
                return _repostPollWidget(doc);
              case 'regalup_c':
                return _repostChallengeWidget(doc);
              case 'regalup_ca':
                return _repostCauseWidget(doc);
              case 'regalup_ti':
                return _repostTipWidget(doc);
              case 'promo_p':
              case 'regalup_promo_p':
                return _promoPollWidget(doc);
              default:
                return SizedBox();
            }
          },
        ),
      ),
    );
  }
}

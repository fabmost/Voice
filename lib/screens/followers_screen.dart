import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_profile_screen.dart';
import '../translations.dart';
import '../providers/user_provider.dart';
import '../widgets/influencer_badge.dart';
import '../widgets/follow_button.dart';
import '../models/user_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class FollowersScreen extends StatefulWidget {
  final userId;

  FollowersScreen(this.userId);

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  TextEditingController _controller = new TextEditingController();
  List<UserModel> _userList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPageNumber = 0;
  String _filter;
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  String _currentUser;

  void _toProfile(userId) async {
    if (_currentUser != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    loadMoreStatus = LoadMoreStatus.LOADING;
    final users = await Provider.of<UserProvider>(context, listen: false)
        .getFollowers(widget.userId, _currentPageNumber);
    _currentUser = Provider.of<UserProvider>(context, listen: false).getUser;
    setState(() {
      if (users.isEmpty) {
        _hasMore = false;
      }
      _userList = users;
      _isLoading = false;
    });
    loadMoreStatus = LoadMoreStatus.STABLE;
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
          Provider.of<UserProvider>(context, listen: false)
              .getFollowers(widget.userId, _currentPageNumber)
              .then((newUsers) {
            setState(() {
              if (newUsers.isEmpty) {
                _hasMore = false;
              } else {
                _userList.addAll(newUsers);
              }
            });
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _controller.addListener(() {
      setState(() {
        _filter = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _userTile(UserModel user) {
    return ListTile(
      onTap: () => _toProfile(user.userName),
      leading: CircleAvatar(
        backgroundImage: user.icon == null ? null : NetworkImage(user.icon),
      ),
      title: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '${user.name} ${user.lastName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(user.userName, user.certificate, 16),
        ],
      ),
      subtitle: Text('@${user.userName}'),
      trailing: (_currentUser != user.userName)
          ? FollowButton(
              userName: user.userName,
              isFollowing: user.isFollowing,
            )
          : SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('label_followers')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_userList.isEmpty)
              ? Center(
                  child: Text(Translations.of(context).text('empty_followers')),
                )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText:
                                Translations.of(context).text('hint_search')),
                        controller: _controller,
                      ),
                    ),
                    Expanded(
                      child: NotificationListener(
                        onNotification: onNotification,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _hasMore
                              ? _userList.length + 1
                              : _userList.length,
                          itemBuilder: (ctx, i) {
                            if (i == _userList.length)
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            final doc = _userList[i];

                            return _filter == null || _filter == ""
                                ? Column(
                                    children: <Widget>[
                                      _userTile(doc),
                                      Divider()
                                    ],
                                  )
                                : doc.userName
                                        .toLowerCase()
                                        .contains(_filter.toLowerCase())
                                    ? _userTile(doc)
                                    : Container();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

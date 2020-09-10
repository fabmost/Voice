import 'dart:async';

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
  List<UserModel> _searchList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearching = false;
  bool _finishedSearching = false;
  int _currentPageNumber = 0;
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  String _currentUser;
  Timer _debounce;

  void _toProfile(userId) async {
    if (_currentUser != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_controller.text.length > 2)
        _searchUsers();
      else {
        setState(() {
          _isSearching = false;
        });
        loadMoreStatus = LoadMoreStatus.STABLE;
      }
    });
  }

  void _searchUsers() async {
    setState(() {
      _searchList.clear();
      _isSearching = true;
      _finishedSearching = false;
    });
    loadMoreStatus = LoadMoreStatus.LOADING;
    final users = await Provider.of<UserProvider>(context, listen: false)
        .getFollowers(widget.userId, 0, _controller.text);
    setState(() {
      _searchList = users;
      _finishedSearching = true;
    });
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
      var triggerFetchMoreSize =
          0.7 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
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
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounce?.cancel();
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
                        child: ListView.separated(
                          controller: scrollController,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _isSearching
                              ? _searchList.isEmpty ? 1 : _searchList.length
                              : _hasMore
                                  ? _userList.length + 1
                                  : _userList.length,
                          itemBuilder: (ctx, i) {
                            if (_isSearching) {
                              if (i == _searchList.length)
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: _finishedSearching
                                      ? Text('Sin resultados')
                                      : CircularProgressIndicator(),
                                );
                              final doc = _searchList[i];

                              return _userTile(doc);
                            }
                            if (i == _userList.length)
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            final doc = _userList[i];

                            return _userTile(doc);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

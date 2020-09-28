import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'influencer_badge.dart';
import '../translations.dart';
import '../models/user_model.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../screens/view_profile_screen.dart';

enum LoadMoreStatus { LOADING, STABLE }

class LikesList extends StatefulWidget {
  final String id;
  final String type;

  LikesList({this.id, this.type});

  @override
  _LikesListState createState() => _LikesListState();
}

class _LikesListState extends State<LikesList> with AutomaticKeepAliveClientMixin<LikesList>{
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<UserModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  void _toProfile(userId) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  Widget _userTile(UserModel user) {
    bool isAnon = user.userName.contains('ANONIMO');
    return ListTile(
      onTap: () => isAnon ? null : _toProfile(user.userName),
      leading: CircleAvatar(
        backgroundImage: user.icon == null ? null : NetworkImage(user.icon),
      ),
      title: Row(
        children: <Widget>[
          isAnon ? Text('Usuario anónimo') : Text('${user.userName}'),
          SizedBox(width: 8),
          InfluencerBadge(user.userName, user.certificate, 16),
        ],
      ),
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
          _moreData();
        }
      }
    }
    return true;
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    List results =
        await Provider.of<ContentProvider>(context, listen: false).getLikes(
      id: widget.id,
      type: widget.type,
      page: _currentPageNumber,
    );
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _list = results;
      }
      _isLoading = false;
    });
    if (_hasMore) {
      _moreData();
    }
  }

  void _moreData() {
    _currentPageNumber++;
    loadMoreStatus = LoadMoreStatus.LOADING;
    Provider.of<ContentProvider>(context, listen: false)
        .getLikes(
      id: widget.id,
      type: widget.type,
      page: _currentPageNumber,
    )
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

  @override
  bool get wantKeepAlive => true;

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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _list.isEmpty
            ? Center(
                child: Text(Translations.of(context).text('empty_likes')),
              )
            : NotificationListener(
                onNotification: onNotification,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _hasMore ? _list.length + 1 : _list.length,
                  itemBuilder: (context, i) {
                    if (i == _list.length)
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      );
                    return _userTile(_list[i]);
                  },
                ),
              );
  }
}

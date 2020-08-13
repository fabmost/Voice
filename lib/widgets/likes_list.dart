import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../models/user_model.dart';
import '../providers/content_provider.dart';
import '../screens/view_profile_screen.dart';

enum LoadMoreStatus { LOADING, STABLE }

class LikesList extends StatefulWidget {
  final String id;
  final String type;

  LikesList({this.id, this.type});

  @override
  _LikesListState createState() => _LikesListState();
}

class _LikesListState extends State<LikesList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<UserModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  void _toProfile(userId) async {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  Widget _userTile(UserModel user) {
    return ListTile(
      onTap: () => _toProfile(user.userName),
      leading: CircleAvatar(
        backgroundImage: user.icon == null ? null : NetworkImage(user.icon),
      ),
      title: Row(
        children: <Widget>[
          Text('${user.userName}'),
          SizedBox(width: 8),
          //InfluencerBadge(doc['influencer'] ?? '', 16),
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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _list.isEmpty
            ? Center(
                child: Text(Translations.of(context).text('empty_comments')),
              )
            : NotificationListener(
                onNotification: onNotification,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _list.length,
                  itemBuilder: (context, i) => _userTile(_list[i]),
                ),
              );
  }
}

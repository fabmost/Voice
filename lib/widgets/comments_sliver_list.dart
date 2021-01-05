import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/models/comment_model.dart';

import 'comment_list_tile.dart';
import 'new_comment.dart';
import '../translations.dart';
import '../providers/content_provider.dart';
import '../screens/comments_screen.dart';

enum LoadMoreStatus { LOADING, STABLE }

class CommentsSliverList extends StatefulWidget {
  final String id;
  final String type;
  final String owner;

  CommentsSliverList({this.id, this.type, this.owner});

  @override
  _CommentsSliverListState createState() => _CommentsSliverListState();
}

class _CommentsSliverListState extends State<CommentsSliverList>
    with AutomaticKeepAliveClientMixin<CommentsSliverList> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<CommentModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

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
              .getComments(
            id: widget.id,
            type: widget.type,
            page: _currentPageNumber,
          )
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
                //_list.removeLast();
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
    List<CommentModel> results =
        await Provider.of<ContentProvider>(context, listen: false).getComments(
      id: widget.id,
      type: widget.type,
      page: _currentPageNumber,
    );
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _list.addAll(results);
        if (results.length < 10) {
          _hasMore = false;
          //_list.removeLast();
        }
      }
      _isLoading = false;
    });
  }

  void _setComment(comment) {
    if (_list.isEmpty) {
      setState(() {
        _list.insert(0, comment);
      });
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => CommentsScreen(
            id: widget.id,
            type: widget.type,
            owner: widget.owner,
          ),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    //_list.add(_loadingWidget());
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _loadingWidget() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  List<Widget> _buildSlivers() {
    List<Widget> slivers = [];
    _list.forEach((value) {
      slivers.add(
        CommentListTile(
          id: widget.id,
          type: widget.type,
          owner: widget.owner,
          mComment: value,
        ),
      );
    });
    if (_hasMore) slivers.add(_loadingWidget());
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: <Widget>[
              Expanded(
                child: _list.isEmpty
                    ? Center(
                        child: Text(
                            Translations.of(context).text('empty_comments')),
                      )
                    : NotificationListener(
                        onNotification: onNotification,
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: _buildSlivers(),
                        ),
                      ),
              ),
              NewComment(
                id: widget.id,
                type: widget.type,
                function: _setComment,
              ),
            ],
          );
  }
}

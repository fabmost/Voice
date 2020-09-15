import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comment_tile.dart';
import 'new_comment.dart';
import '../translations.dart';
import '../providers/content_provider.dart';
import '../models/comment_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class CommentsList extends StatefulWidget {
  final String id;
  final String type;

  CommentsList({this.id, this.type});

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
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
        await Provider.of<ContentProvider>(context, listen: false).getComments(
      id: widget.id,
      type: widget.type,
      page: _currentPageNumber,
    );
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        if (results.length < 10) {
          _hasMore = false;
        }
        _list = results;
      }
      _isLoading = false;
    });
  }

  void _setComment(comment) {
    setState(() {
      _list.insert(0, comment);
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
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount:
                                _hasMore ? _list.length + 1 : _list.length,
                            itemBuilder: (context, i) {
                              if (i == _list.length)
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              return CommentTile(
                                contentId: widget.id,
                                type: widget.type,
                                id: _list[i].id,
                                title: _list[i].body,
                                comments: _list[i].comments,
                                date: _list[i].createdAt,
                                userName: _list[i].user.userName,
                                userImage: _list[i].user.icon ?? '',
                                ups: _list[i].likes,
                                hasUp: _list[i].hasLike,
                                downs: _list[i].dislikes,
                                hasDown: _list[i].hasDislike,
                                certificate: _list[i].certificate,
                              );
                            }),
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

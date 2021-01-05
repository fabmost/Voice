import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comment_tile.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class CommentListTile extends StatefulWidget {
  final String id;
  final String type;
  final String owner;
  final CommentModel mComment;

  CommentListTile({this.id, this.type, this.owner, this.mComment});

  @override
  _CommentListTileState createState() => _CommentListTileState();
}

class _CommentListTileState extends State<CommentListTile> {
  bool _hasMore = false;
  int _currentPageNumber = -1;
  bool _isLoading = false;

  List<CommentModel> _mList = [];

  void _showMore() async {
    _currentPageNumber++;
    setState(() {
      _isLoading = true;
    });
    List<CommentModel> results =
        await Provider.of<ContentProvider>(context, listen: false).getReplys(
      id: _mList[0].id,
      type: widget.type,
      page: _currentPageNumber,
      idContent: widget.id,
    );
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _mList.addAll(results);
        if (_mList.length >= _mList[0].comments) {
          _hasMore = false;
        }
      }
      _isLoading = false;
    });
  }

  void _removeContent(id) {
    int index = _mList.indexWhere((element) => element.id == id);
    setState(() {
      if (index == 0) {
        _mList.clear();
        _hasMore = false;
      } else {
        _mList[0] = CommentModel(
          body: _mList[0].body,
          certificate: _mList[0].certificate,
          comments: _mList[0].comments - 1,
          createdAt: _mList[0].createdAt,
          dislikes: _mList[0].dislikes,
          hasDislike: _mList[0].hasDislike,
          hasLike: _mList[0].hasLike,
          id: _mList[0].id,
          likes: _mList[0].likes,
          parentId: _mList[0].parentId,
          parentType: _mList[0].parentType,
          user: _mList[0].user,
        );
        _mList.removeAt(index);
      }
    });
  }

  void _addContent(mComment) {
    if (_mList.length == 1) {
      setState(() {
        _mList[0] = CommentModel(
          body: _mList[0].body,
          certificate: _mList[0].certificate,
          comments: _mList[0].comments + 1,
          createdAt: _mList[0].createdAt,
          dislikes: _mList[0].dislikes,
          hasDislike: _mList[0].hasDislike,
          hasLike: _mList[0].hasLike,
          id: _mList[0].id,
          likes: _mList[0].likes,
          parentId: _mList[0].parentId,
          parentType: _mList[0].parentType,
          user: _mList[0].user,
        );

        _mList.add(mComment);
      });
    } else {
      List<CommentModel> copyList = [];
      copyList.addAll(_mList);
      _mList.clear();

      copyList[0] = CommentModel(
        body: copyList[0].body,
        certificate: copyList[0].certificate,
        comments: copyList[0].comments + 1,
        createdAt: copyList[0].createdAt,
        dislikes: copyList[0].dislikes,
        hasDislike: copyList[0].hasDislike,
        hasLike: copyList[0].hasLike,
        id: copyList[0].id,
        likes: copyList[0].likes,
        parentId: copyList[0].parentId,
        parentType: copyList[0].parentType,
        user: copyList[0].user,
      );
      copyList.add(mComment);
      setState(() {
        _mList = copyList;
      });
    }
  }

  @override
  void initState() {
    //widget.mComment.comments > 0;
    _mList.add(widget.mComment);
    if (widget.mComment.comments > 0) _hasMore = true;
    super.initState();
  }

  Widget _loadMoreButton() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 36,
          ),
          width: 1,
          height: 24,
          color: Colors.grey,
        ),
        ListTile(
          onTap: _showMore,
          tileColor: Colors.transparent,
          leading: const SizedBox.shrink(),
          title: Text(
            'Ver respuestas',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (i == _mList.length) {
            return _isLoading
                ? Container(
                    margin: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : _loadMoreButton();
          }
          return CommentTile(
            isParent: i == 0,
            isLast: _mList[0].comments > 0 ? i == _mList[0].comments : false,
            contentId: widget.id,
            type: widget.type,
            id: _mList[i].id,
            title: _mList[i].body,
            comments: _mList[i].comments,
            date: _mList[i].createdAt,
            userName: _mList[i].user.userName,
            userImage: _mList[i].user.icon ?? '',
            ups: _mList[i].likes,
            hasUp: _mList[i].hasLike,
            downs: _mList[i].dislikes,
            hasDown: _mList[i].hasDislike,
            certificate: _mList[i].certificate,
            removeFunction: _removeContent,
            owner: widget.owner,
            parentId: _mList[0].id,
            addFunction: _addContent,
          );
        },
        childCount: _hasMore ? _mList.length + 1 : _mList.length,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/header_comment.dart';
import '../widgets/comment_tile.dart';
import '../widgets/new_comment.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class DetailCommentScreen extends StatefulWidget {
  final String id;
  final bool fromNotification;

  DetailCommentScreen(this.id, [this.fromNotification = false]);

  @override
  _DetailCommentScreenState createState() => _DetailCommentScreenState();
}

class _DetailCommentScreenState extends State<DetailCommentScreen> {
  CommentModel commentModel;
  List<CommentModel> _commentsList = [];
  bool _isLoading = false;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _commentsList.clear();
    });
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getComment(widget.id);
    if (result == null) {
      _noExists();
      return;
    }
    List<CommentModel> newObjects =
        await Provider.of<ContentProvider>(context, listen: false).getReplys(
            id: widget.id,
            type: result.parentType,
            page: 0,
            idContent: result.parentId);
    setState(() {
      _isLoading = false;
      commentModel = result;
      _commentsList.addAll(newObjects);
    });
  }

  void _noExists() {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text('Este contenido ya no existe'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      ).then((value) {
        Navigator.of(context).pop();
      });
    });
  }

  void _setComment(comment) {
    setState(() {
      _commentsList.insert(0, comment);
    });
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_comments')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        _commentsList.isEmpty ? 1 : _commentsList.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return HeaderComment(
                            commentModel, widget.fromNotification);
                      }
                      if (_commentsList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(Translations.of(context)
                                .text('empty_comments')),
                          ),
                        );
                      }
                      final doc = _commentsList[i - 1];

                      return CommentTile(
                        id: doc.id,
                        contentId: doc.parentId,
                        type: doc.parentType,
                        title: doc.body,
                        comments: doc.comments,
                        date: doc.createdAt,
                        userName: doc.user.userName,
                        userImage: doc.user.icon ?? '',
                        ups: doc.likes,
                        hasUp: doc.hasLike,
                        downs: doc.dislikes,
                        hasDown: doc.hasDislike,
                        certificate: doc.certificate,
                      );
                    },
                  ),
                ),
                NewComment(
                  id: commentModel.parentId,
                  type: commentModel.parentType,
                  idComment: commentModel.id,
                  function: _setComment,
                ),
              ],
            ),
    );
  }
}

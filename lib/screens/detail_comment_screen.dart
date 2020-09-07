import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/header_comment.dart';
import '../widgets/comment_tile.dart';
import '../widgets/new_comment.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class DetailCommentScreen extends StatefulWidget {
  static const routeName = '/detail-comment';
  final String id;
  final String type;
  final CommentModel comment;

  DetailCommentScreen({this.id, this.type, this.comment});

  @override
  _DetailCommentScreenState createState() => _DetailCommentScreenState();
}

class _DetailCommentScreenState extends State<DetailCommentScreen> {
  List<CommentModel> _commentsList = [];
  bool _isLoading = false;

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    List results =
        await Provider.of<ContentProvider>(context, listen: false).getReplys(
      id: widget.comment.id,
      type: widget.type,
      idContent: widget.id,
      page: 0,
    );
    setState(() {
      _commentsList = results;
      _isLoading = false;
    });
  }

  void _setComment(comment) {
    setState(() {
      _commentsList.insert(0, comment);
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_comments')),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _commentsList.isEmpty ? 2 : _commentsList.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return HeaderComment(widget.comment);
                }
                if (_commentsList.isEmpty) {
                  if (_isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child:
                          Text(Translations.of(context).text('empty_comments')),
                    ),
                  );
                }
                final doc = _commentsList[i - 1];

                return CommentTile(
                  contentId: widget.id,
                  type: widget.type,
                  id: doc.id,
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
            id: widget.id,
            type: widget.type,
            idComment: widget.comment.id,
            function: _setComment,
          ),
        ],
      ),
    );
  }
}

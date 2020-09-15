import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/header_tip.dart';
import '../widgets/new_comment.dart';
import '../widgets/comment_tile.dart';
import '../models/tip_model.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class DetailTipScreen extends StatefulWidget {
  static const routeName = '/tip';
  final String id;

  DetailTipScreen({this.id});

  @override
  _DetailTipScreenState createState() => _DetailTipScreenState();
}

class _DetailTipScreenState extends State<DetailTipScreen> {
  TipModel _tipModel;
  List<CommentModel> _commentsList = [];
  bool _isLoading = false;

  Future<void> _fetchTipAndComments() async {
    setState(() {
      _isLoading = true;
      _commentsList.clear();
    });
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getContent('T', widget.id);
    if (result == null) {
      _noExists();
      return;
    }
    List<CommentModel> newObjects =
        await Provider.of<ContentProvider>(context, listen: false)
            .getComments(id: widget.id, type: 'TIP', page: 0);
    setState(() {
      _isLoading = false;
      _tipModel = result;
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
    super.initState();
    _fetchTipAndComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_tip')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchTipAndComments(),
                    child: ListView.builder(
                      itemCount:
                          _commentsList.isEmpty ? 2 : _commentsList.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return HeaderTip(_tipModel);
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
                          contentId: widget.id,
                          type: 'TIP',
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
                ),
                NewComment(
                  id: _tipModel.id,
                  type: 'TIP',
                  function: _setComment,
                ),
              ],
            ),
    );
  }
}

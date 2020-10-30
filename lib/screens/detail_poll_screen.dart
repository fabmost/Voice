import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/header_poll.dart';
import '../widgets/header_private_poll.dart';
import '../widgets/comment_tile.dart';
import '../widgets/new_comment.dart';
import '../models/poll_model.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class DetailPollScreen extends StatefulWidget {
  static const routeName = '/poll';

  final String id;

  DetailPollScreen({this.id});

  @override
  _DetailPollScreenState createState() => _DetailPollScreenState();
}

class _DetailPollScreenState extends State<DetailPollScreen> {
  PollModel _pollModel;
  List<CommentModel> _commentsList = [];
  bool _isLoading = false;

  Future<void> _fetchPollAndComments() async {
    setState(() {
      _isLoading = true;
      _commentsList.clear();
    });
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getContent('P', widget.id);
    if (result == null) {
      _noExists();
      return;
    }
    List<CommentModel> newObjects =
        await Provider.of<ContentProvider>(context, listen: false)
            .getComments(id: widget.id, type: 'P', page: 0);
    setState(() {
      _isLoading = false;
      _pollModel = result;
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

  void _removeContent(id) {
    setState(() {
      _commentsList.removeWhere((element) => element.id == id);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPollAndComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_poll')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchPollAndComments(),
                    child: ListView.builder(
                      itemCount:
                          _commentsList.isEmpty ? 2 : _commentsList.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          if (_pollModel.type == 'private_p')
                            return HeaderPrivatePoll(_pollModel);
                          return HeaderPoll(_pollModel);
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
                          type: 'P',
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
                          removeFunction: _removeContent,
                          owner: _pollModel.user.userName,
                        );
                      },
                    ),
                  ),
                ),
                NewComment(
                  id: _pollModel.id,
                  type: 'P',
                  function: _setComment,
                ),
              ],
            ),
    );
  }
}

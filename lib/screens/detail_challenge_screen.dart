import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/header_challenge.dart';
import '../widgets/new_comment.dart';
import '../widgets/comment_tile.dart';
import '../models/challenge_model.dart';
import '../models/comment_model.dart';
import '../providers/content_provider.dart';

class DetailChallengeScreen extends StatefulWidget {
  static const routeName = '/challenge';
  final String id;

  DetailChallengeScreen({this.id});

  @override
  _DetailChallengeScreenState createState() => _DetailChallengeScreenState();
}

class _DetailChallengeScreenState extends State<DetailChallengeScreen> {
  ChallengeModel _challengeModel;
  List<CommentModel> _commentsList = [];
  bool _isLoading = false;

  Future<void> _fetchChallengeAndComments() async {
    setState(() {
      _isLoading = true;
      _commentsList.clear();
    });
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getContent('C', widget.id);
    List<CommentModel> newObjects =
        await Provider.of<ContentProvider>(context, listen: false)
            .getComments('C', widget.id);
    setState(() {
      _isLoading = false;
      _challengeModel = result;
      _commentsList.addAll(newObjects);
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
    _fetchChallengeAndComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_challenge')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchChallengeAndComments(),
                    child: ListView.builder(
                      itemCount:
                          _commentsList.isEmpty ? 2 : _commentsList.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return HeaderChallenge(_challengeModel);
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
                          title: doc.body,
                          comments: doc.comments,
                          date: doc.createdAt,
                          userName: doc.user.userName,
                          userImage: doc.user.icon ?? '',
                          ups: doc.likes,
                          hasUp: doc.hasLike,
                          downs: doc.dislikes,
                          hasDown: doc.hasDislike,
                        );
                      },
                    ),
                  ),
                ),
                NewComment(
                  id: _challengeModel.id,
                  type: 'C',
                  function: _setComment,
                ),
              ],
            ),
    );
  }
}

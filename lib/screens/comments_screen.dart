import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/comments_list.dart';
import '../widgets/likes_list.dart';

class CommentsScreen extends StatelessWidget {
  final String id;
  final String type;
  final String owner;

  CommentsScreen({
    this.id,
    this.type,
    @required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Translations.of(context).text('title_comments')),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Comentarios',
              ),
              Tab(
                text: 'Likes',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CommentsList(
              id: id,
              type: type,
              owner: owner,
            ),
            LikesList(
              id: id,
              type: type,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comment_header_options.dart';
import '../models/comment_model.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/search_results_screen.dart';
import '../screens/view_profile_screen.dart';

class HeaderComment extends StatelessWidget {
  final CommentModel comment;

  HeaderComment(this.comment);

  void _toTaggedProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toHash(context, hashtag) {
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(hashtag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    final difference = now.difference(comment.createdAt);
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: comment.user.icon == null
                ? null
                : NetworkImage(comment.user.icon),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                comment.user.userName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeago.format(now.subtract(difference)),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              )
            ],
          ),
          subtitle: ExtendedText(
            comment.body,
            style: TextStyle(fontSize: 16),
            specialTextSpanBuilder: MySpecialTextSpanBuilder(canClick: true),
            onSpecialTextTap: (parameter) {
              if (parameter.toString().startsWith('@')) {
                String atText = parameter.toString();
                int start = atText.indexOf('[');
                int finish = atText.indexOf(']');
                String toRemove = atText.substring(start + 1, finish);
                _toTaggedProfile(context, toRemove);
              } else if (parameter.toString().startsWith('#')) {
                _toHash(context, parameter.toString());
              }
            },
          ),
        ),
        CommentHeaderOptions(
          id: comment.id,
          likes: comment.likes,
          dislikes: comment.dislikes,
          hasLike: comment.hasLike,
          hasDislike: comment.hasDislike,
        ),
        Divider(),
      ],
    );
  }
}

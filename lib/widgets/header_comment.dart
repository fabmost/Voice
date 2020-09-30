import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'comment_header_options.dart';
import 'influencer_badge.dart';
import '../translations.dart';
import '../models/comment_model.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/search_results_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/detail_poll_screen.dart';
import '../screens/detail_challenge_screen.dart';
import '../screens/detail_tip_screen.dart';
import '../screens/detail_comment_screen.dart';
import '../providers/user_provider.dart';

class HeaderComment extends StatelessWidget {
  final CommentModel comment;
  final bool fromNotification;
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  HeaderComment(this.comment, this.fromNotification);

  void _goToParent(context) {
    switch (comment.parentType) {
      case 'poll':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPollScreen(id: comment.parentId),
          ),
        );
        break;
      case 'challenge':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailChallengeScreen(
              id: comment.parentId,
            ),
          ),
        );
        break;
      case 'TIP':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTipScreen(
              id: comment.parentId,
            ),
          ),
        );
        break;
      case 'comment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCommentScreen(
              comment.parentId,
              true,
            ),
          ),
        );
        break;
    }
  }

  void _toTaggedProfile(context, id) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != id) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: id);
    }
  }

  void _toHash(context, hashtag) {
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(hashtag),
    );
  }

  void _launchURL(String url) async {
    String newUrl = url;
    if (!url.contains('http')) {
      newUrl = 'http://$url';
    }
    if (await canLaunch(newUrl.trim())) {
      await launch(newUrl.trim());
    } else {
      throw 'Could not launch $newUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    final difference = now.difference(comment.createdAt);
    return Column(
      children: <Widget>[
        if (fromNotification)
          FlatButton(
            onPressed: () => _goToParent(context),
            textColor: Theme.of(context).primaryColor,
            child: Text(
              'Ver publicación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ListTile(
          leading: GestureDetector(
            onTap: () => _toTaggedProfile(context, comment.user.userName),
            child: CircleAvatar(
              backgroundImage: comment.user.icon == null
                  ? null
                  : NetworkImage(comment.user.icon),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: GestureDetector(
                  onTap: () => _toTaggedProfile(context, comment.user.userName),
                  child: Text(
                    comment.user.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              InfluencerBadge(comment.id, comment.user.certificate, 16),
              Text(
                timeago.format(now.subtract(difference),
                    locale: Translations.of(context).currentLanguage),
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
              } else if (regex.hasMatch(parameter.toString())) {
                _launchURL(parameter.toString());
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

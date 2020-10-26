import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'comment_options.dart';
import 'influencer_badge.dart';
import '../translations.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/detail_comment_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';

class CommentTile extends StatelessWidget {
  final String contentId;
  final String type;
  final String id;
  final String title;
  final DateTime date;
  final int comments;
  final String userName;
  final String userImage;
  final int ups;
  final int downs;
  final bool hasUp;
  final bool hasDown;
  final certificate;
  final Function removeFunction;
  final String owner;

  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  CommentTile({
    @required this.contentId,
    @required this.type,
    @required this.id,
    this.title,
    this.date,
    this.comments,
    this.userImage,
    this.userName,
    this.ups,
    this.downs,
    this.hasUp,
    this.hasDown,
    @required this.certificate,
    @required this.removeFunction,
    @required this.owner,
  });

  void _toComment(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCommentScreen(
          id,
        ),
      ),
    );
  }

  void _toProfile(context, user) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != user) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: user);
    }
  }

  void _toHash(context, hashtag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(hashtag),
      ),
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

  void _options(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _deleteAlert(context),
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('button_delete'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAlert(context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        content: Text('¿Seguro que deseas borrar este comentario?'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            child: Text(
              Translations.of(context).text('button_cancel'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(ct).pop();
            },
          ),
          FlatButton(
            textColor: Colors.red,
            child: Text(
              Translations.of(context).text('button_delete'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              _deleteContent(ct);
              Navigator.of(ct).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteContent(context) async {
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .deleteComment(
      id: id,
      contentId: contentId,
      type: type,
    );
    if (result) {
      //Navigator.of(context).pop();
      removeFunction(id);
    }
  }

  Widget _menuButton(context) {
    return Transform.rotate(
      angle: 270 * pi / 180,
      child: IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: () => _options(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(date);
    final newDate = now.subtract(difference).toLocal();

    return Column(
      children: <Widget>[
        ListTile(
          leading: GestureDetector(
            onTap: () => _toProfile(context, userName),
            child: CircleAvatar(
              backgroundImage: userImage == null
                  ? null
                  : userImage.isEmpty ? null : NetworkImage(userImage),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: GestureDetector(
                  onTap: () => _toProfile(context, userName),
                  child: Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              InfluencerBadge(id, certificate, 16),
              Text(
                timeago.format(newDate,
                    locale: Translations.of(context).currentLanguage),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              )
            ],
          ),
          subtitle: ExtendedText(
            title,
            style: TextStyle(fontSize: 16),
            specialTextSpanBuilder: MySpecialTextSpanBuilder(canClick: true),
            onSpecialTextTap: (parameter) {
              if (parameter.toString().startsWith('@')) {
                String atText = parameter.toString();
                int start = atText.indexOf('[');
                int finish = atText.indexOf(']');
                String toRemove = atText.substring(start + 1, finish);
                _toProfile(context, toRemove);
              } else if (parameter.toString().startsWith('#')) {
                _toHash(context, parameter.toString());
              } else if (regex.hasMatch(parameter.toString())) {
                _launchURL(parameter.toString());
              }
            },
          ),
          trailing: Provider.of<UserProvider>(context, listen: false).getUser ==
                  userName
              ? _menuButton(context)
              : Provider.of<UserProvider>(context, listen: false).getUser ==
                      owner
                  ? _menuButton(context)
                  : null,
        ),
        CommentOptions(
          id: id,
          likes: ups,
          dislikes: downs,
          hasLike: hasUp,
          hasDislike: hasDown,
          toComments: () => _toComment(context),
        ),
      ],
    );
  }
}

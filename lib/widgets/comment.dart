import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/detail_comment_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';

class Comment extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String userId;
  final String title;
  final DateTime date;
  final int comments;
  final String userName;
  final String userImage;
  final int ups;
  final int downs;
  final bool hasUp;
  final bool hasDown;

  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  Comment({
    this.reference,
    this.myId,
    this.userId,
    this.title,
    this.date,
    this.comments,
    this.userImage,
    this.userName,
    this.ups,
    this.downs,
    this.hasUp,
    this.hasDown,
  });

  void _toComment(context) {
    Navigator.of(context)
        .pushNamed(DetailCommentScreen.routeName, arguments: reference);
  }

  void _toProfile(context) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  void _toTaggedProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toHash(context, hashtag) {
    Navigator.of(context)
        .pushNamed(SearchResultsScreen.routeName, arguments: hashtag);
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

  void _upVote() {
    WriteBatch batch = Firestore.instance.batch();
    if (hasUp) {
      batch.updateData(reference, {
        'up': FieldValue.arrayRemove([myId]),
      });
    } else {
      batch.updateData(reference, {
        'up': FieldValue.arrayUnion([myId]),
        'down': FieldValue.arrayRemove([myId])
      });
    }
    batch.commit();
  }

  void _downVote() {
    WriteBatch batch = Firestore.instance.batch();
    if (hasDown) {
      batch.updateData(reference, {
        'down': FieldValue.arrayRemove([myId]),
      });
    } else {
      batch.updateData(reference, {
        'down': FieldValue.arrayUnion([myId]),
        'up': FieldValue.arrayRemove([myId])
      });
    }
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    final difference = now.difference(date);

    return Column(
      children: <Widget>[
        ListTile(
          leading: GestureDetector(
            onTap: () => _toProfile(context),
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () => _toProfile(context),
                child: Text(
                  userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            title,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(
                GalupFont.like,
                color: hasUp ? Theme.of(context).accentColor : Colors.black,
              ),
              label: Text(ups == 0 ? '' : '$ups'),
              onPressed: _upVote,
            ),
            FlatButton.icon(
              icon: Icon(
                GalupFont.dislike,
                color: hasDown ? Theme.of(context).accentColor : Colors.black,
              ),
              label: Text(downs == 0 ? '' : '$downs'),
              onPressed: _downVote,
            ),
            FlatButton(
              child: Text('Responder'),
              onPressed: () => _toComment(context),
            ),
          ],
        ),
        if (comments > 0)
          Row(
            children: <Widget>[
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
              FlatButton(
                child: Text('Ver respuestas ($comments)'),
                onPressed: () => _toComment(context),
              ),
            ],
          ),
        if (comments == 0) Divider(),
      ],
    );
  }
}

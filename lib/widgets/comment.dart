import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../custom/galup_font_icons.dart';
import '../screens/detail_comment_screen.dart';
import '../screens/view_profile_screen.dart';

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
              Text(
                userName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          subtitle: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(GalupFont.message),
              label: Text(comments == 0 ? '' : '$comments'),
              onPressed: () => _toComment(context),
            ),
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
          ],
        ),
        Divider(),
      ],
    );
  }
}

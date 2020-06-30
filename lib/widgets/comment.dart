import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';
import '../screens/detail_comment_screen.dart';

class Comment extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
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
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
          ),
          title: Text(
            userName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

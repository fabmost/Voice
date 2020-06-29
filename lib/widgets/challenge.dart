import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';
import '../screens/comments_screen.dart';
import '../screens/view_profile_screen.dart';

class Challenge extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String userImage;
  final String title;
  final String metric;
  final double goal;
  final int comments;
  final bool hasLiked;
  final int likes;
  final bool hasReposted;
  final int reposts;

  Challenge({
    this.reference,
    this.userName,
    this.myId,
    this.userImage,
    this.title,
    this.metric,
    this.goal,
    this.comments,
    this.userId,
    this.likes,
    this.hasLiked,
    this.reposts,
    this.hasReposted,
  });

  void _toProfile(context) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  void _toComments(context) {
    Navigator.of(context)
        .pushNamed(CommentsScreen.routeName, arguments: reference);
  }

  void _like() {
    if (hasLiked) {
      reference.updateData({
        'likes': FieldValue.arrayRemove([myId])
      });
    } else {
      reference.updateData({
        'likes': FieldValue.arrayUnion([myId])
      });
    }
  }

  void _flag(context){
    Navigator.of(context).pop();
  }

  void _options(context) {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                onTap: ()=> _flag(context),
                leading: new Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  "Denunciar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _challengeGoal() {
    bool goalReached = false;
    switch (metric) {
      case 'likes':
        if (likes >= goal) {
          goalReached = true;
        }
        break;
      case 'comentarios':
        if (comments >= goal) {
          goalReached = true;
        }
        break;
      case 'regalups':
        if (reposts >= goal) {
          goalReached = true;
        }
        break;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        onPressed: goalReached ? () {} : null,
        child: Text(goalReached ? 'Ver' : 'Faltan $metric'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFA4175D), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              onTap: myId == userId ? null : () => _toProfile(context),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFA4175D),
                backgroundImage: NetworkImage(userImage),
              ),
              title: Text(userName),
              subtitle: Text('Hace 5 días'),
              trailing: Transform.rotate(
                angle: 270 * pi / 180,
                child: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => _options(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            _challengeGoal(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton.icon(
                  onPressed: () => _toComments(context),
                  icon: Icon(GalupFont.message),
                  label: Text(comments == 0 ? '' : '$comments'),
                ),
                FlatButton.icon(
                  onPressed: _like,
                  icon: Icon(GalupFont.like,
                      color: hasLiked ? Color(0xFFA4175D) : Colors.black),
                  label: Text(likes == 0 ? '' : '$likes'),
                ),
                FlatButton.icon(
                  onPressed: null,
                  icon: Icon(GalupFont.repost),
                  label: Text(reposts == 0 ? '' : '$reposts'),
                ),
                IconButton(
                  icon: Icon(GalupFont.share),
                  onPressed: null,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

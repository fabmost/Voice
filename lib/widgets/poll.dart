import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'poll_options.dart';
import '../custom/galup_font_icons.dart';
import '../screens/comments_screen.dart';
import '../screens/view_profile_screen.dart';

class Poll extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String userId;
  final String userName;
  final String userImage;
  final String title;
  final int comments;
  final List options;
  final List votes;
  final bool hasVoted;
  final int vote;
  final int voters;
  final bool hasLiked;
  final int likes;
  final bool hasReposted;
  final int reposts;

  Poll({
    this.reference,
    this.myId,
    this.userName,
    this.userImage,
    this.title,
    this.comments,
    this.userId,
    this.options,
    this.votes,
    this.hasVoted,
    this.vote,
    this.voters,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).accentColor, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              onTap: myId == userId ? null : () => _toProfile(context),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).accentColor,
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
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: PollOptions(
                reference: reference,
                userId: userId,
                votes: votes,
                options: options,
                hasVoted: hasVoted,
                vote: vote,
                voters: voters,
              ),
            ),
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
                  icon: Icon(
                    GalupFont.like,
                    color:
                        hasLiked ? Theme.of(context).accentColor : Colors.black,
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

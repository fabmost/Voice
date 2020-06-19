import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'poll_options.dart';
import '../screens/comments_screen.dart';

class Poll extends StatelessWidget {
  final DocumentReference reference;
  final String title;
  final int comments;
  final String userId;
  final List options;
  final List votes;
  final bool hasVoted;
  final int vote;
  final int voters;

  Poll({
    this.reference,
    this.title,
    this.comments,
    this.userId,
    this.options,
    this.votes,
    this.hasVoted,
    this.vote,
    this.voters,
  });

  void _toComments(context) {
    Navigator.of(context)
        .pushNamed(CommentsScreen.routeName, arguments: reference);
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
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).accentColor,
              ),
              title: Text('Fabian'),
              subtitle: Text('Hace 5 días'),
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
                  icon: Icon(Icons.comment),
                  label: Text(comments == 0 ? '' : '$comments'),
                ),
                FlatButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.arrow_upward),
                  label: Text('15'),
                ),
                FlatButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.swap_vertical_circle),
                  label: Text('15'),
                ),
                IconButton(
                  icon: Icon(Icons.share),
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

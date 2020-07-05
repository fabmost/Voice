import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../custom/galup_font_icons.dart';
import '../screens/detail_challenge_screen.dart';

class RepostChallenge extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String title;
  final String metric;
  final String creatorName;
  final String creatorImage;
  final DateTime date;

  final Color color = Color(0xFFFFF5FB);

  RepostChallenge({
    this.reference,
    this.userName,
    this.myId,
    this.title,
    this.metric,
    this.userId,
    this.creatorImage,
    this.creatorName,
    this.date,
  });

  void _toDetail(context) {
    Navigator.of(context).pushNamed(DetailChallengeScreen.routeName,
        arguments: reference.documentID);
  }

  Widget _challengeGoal() {
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        onPressed: null,
        child: Text('Faltan $metric'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    final difference = now.difference(date);

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFA4175D), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => _toDetail(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: color,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            GalupFont.repost,
                            color: Colors.grey,
                            size: 12,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$userName Regalup',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFA4175D),
                        backgroundImage: NetworkImage(creatorImage),
                      ),
                      title: Text(
                        userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(timeago.format(now.subtract(difference))),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/detail_challenge_screen.dart';

class SearchChallenge extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String userName;
  final String title;
  final String metric;
  final String creatorName;
  final String creatorImage;
  final DateTime date;
  final String influencer;
  final String description;

  final Color color = Color(0xFFFFF5FB);

  SearchChallenge({
    this.reference,
    this.userName,
    this.title,
    this.metric,
    this.userId,
    this.creatorImage,
    this.creatorName,
    this.date,
    @required this.influencer,
    @required this.description,
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
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFA4175D),
                    backgroundImage: NetworkImage(creatorImage),
                  ),
                  title: Row(
                    children: <Widget>[
                      Text(
                        creatorName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      InfluencerBadge(influencer, 16),
                    ],
                  ),
                  subtitle: Text(timeago.format(now.subtract(difference))),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExtendedText(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                ),
              ),
              SizedBox(height: 16),
              _challengeGoal(),
              SizedBox(height: 16),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExtendedText(
                    description,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                  ),
                ),
              if (description.isNotEmpty) SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

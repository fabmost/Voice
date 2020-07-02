import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/detail_challenge_screen.dart';

class SearchChallenge extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String title;
  final String metric;
  final String creatorName;
  final String creatorImage;

  final Color color = Color(0xFFFFF5FB);

  SearchChallenge({
    this.reference,
    this.userName,
    this.myId,
    this.title,
    this.metric,
    this.userId,
    this.creatorImage,
    this.creatorName,
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
                  title: Text(
                    creatorName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Hace 5 días'),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/influencer_badge.dart';
import '../custom/galup_font_icons.dart';
import '../screens/detail_cause_screen.dart';

class RespostCause extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String creator;
  final String title;
  final String info;
  final String userName;
  final String userImage;
  final String influencer;
  final DateTime date;
  final List images;

  final Color color = Color(0xFFF0F0F0);

  RespostCause(
      {this.reference,
      this.myId,
      this.creator,
      this.info,
      this.title,
      this.userName,
      this.date,
      @required this.influencer,
      @required this.userImage,
      @required this.images});

  void _toDetail(context) {
    Navigator.of(context).pushNamed(DetailCauseScreen.routeName,
        arguments: reference.documentID);
  }

  Widget _causeButton(context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        borderSide: BorderSide(
          color: Colors.black,
          width: 2,
        ),
        onPressed: () => null,
        child: Text('Apoyo esta causa'),
      ),
    );
  }

  Widget _userTile(context) {
    if (info.isNotEmpty)
      return ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage: AssetImage('assets/logo.png'),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              creator,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Icon(GalupFont.info_circled_alt),
          ],
        ),
        subtitle: Text('Por: Galup'),
      );
    final now = new DateTime.now();
    final difference = now.difference(date);
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).accentColor,
        backgroundImage: NetworkImage(userImage),
      ),
      title: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              creator,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(influencer, 16),
        ],
      ),
      subtitle: Text(timeago.format(now.subtract(difference))),
    );
  }

  Widget _challengeGoal(context) {
    double width = (MediaQuery.of(context).size.width / 5) * 3;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black),
            image: DecorationImage(
              image: NetworkImage(images[0]),
              fit: BoxFit.cover,
            )),
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
          side: BorderSide(color: Colors.black, width: 0.5),
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
                    _userTile(context),
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
              if (images.isNotEmpty) _challengeGoal(context),
              if (images.isNotEmpty) SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

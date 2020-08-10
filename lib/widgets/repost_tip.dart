import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import '../custom/my_special_text_span_builder.dart';
import '../custom/galup_font_icons.dart';
import '../screens/detail_tip_screen.dart';

class RepostTip extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String title;
  final String creatorName;
  final String creatorImage;
  final DateTime date;
  final String influencer;

  final Color color = Color(0xFFF4FDFF);

  RepostTip({
    this.reference,
    this.userName,
    this.myId,
    this.title,
    this.userId,
    this.creatorImage,
    this.creatorName,
    this.date,
    @required this.influencer,
  });

  void _toDetail(context) {
    Navigator.of(context).pushNamed(DetailTipScreen.routeName,
        arguments: reference.documentID);
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
          side: BorderSide(color: Color(0xFF00B2E3), width: 0.5),
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
                        backgroundColor: Color(0xFF00B2E3),
                        backgroundImage: NetworkImage(creatorImage),
                      ),
                      title: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              creatorName,
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
                    ),
                  ],
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
                  specialTextSpanBuilder:
                      MySpecialTextSpanBuilder(),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

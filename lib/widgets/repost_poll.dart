import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_images.dart';
import '../custom/galup_font_icons.dart';
import '../screens/detail_poll_screen.dart';

class RepostPoll extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String userId;
  final String userName;
  final String title;
  final List options;
  final String creatorName;
  final String creatorImage;
  final List images;
  final DateTime date;
  final String influencer;

  final Color color = Color(0xFFF8F8FF);

  RepostPoll({
    this.reference,
    this.myId,
    this.userName,
    this.title,
    this.userId,
    this.options,
    this.creatorName,
    this.creatorImage,
    this.images,
    this.date,
    @required this.influencer,
  });

  void _toDetail(context) {
    Navigator.of(context)
        .pushNamed(DetailPollScreen.routeName, arguments: reference.documentID);
  }

  Widget _getOptions() {
    int pos = -1;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map(
          (option) {
            pos++;
            if (option.containsKey('image')) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(option['image']),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _poll(option['text'], pos),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: _poll(
                    option['text'],
                    pos,
                  ),
                ),
                SizedBox(height: 8),
              ],
            );
          },
        ).toList());
  }

  Widget _poll(option, position) {
    return Container(
      height: 42,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(option),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.black),
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
          side: BorderSide(color: Theme.of(context).accentColor, width: 0.5),
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
                        backgroundColor: Theme.of(context).accentColor,
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (images.isNotEmpty) SizedBox(height: 16),
              if (images.isNotEmpty)
                PollImages(
                  images,
                  '',
                  isClickable: false,
                ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8,
                ),
                child: _getOptions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

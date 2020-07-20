import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import '../screens/detail_poll_screen.dart';
import '../custom/my_special_text_span_builder.dart';

class SearchPoll extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final String userName;
  final String title;
  final List options;
  final String creatorName;
  final String creatorImage;
  final List images;
  final DateTime date;
  final String influencer;
  final String description;

  final Color color = Color(0xFFF8F8FF);

  SearchPoll({
    this.reference,
    this.userName,
    this.title,
    this.userId,
    this.options,
    this.creatorName,
    this.creatorImage,
    this.images,
    this.date,
    @required this.influencer,
    @required this.description,
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

  Widget _images() {
    if (images.length == 1) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[0]),
                fit: BoxFit.cover,
              )),
        ),
      );
    } else if (images.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[1]),
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[1]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(images[2]),
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      );
    }
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
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).accentColor,
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (images.isNotEmpty) SizedBox(height: 16),
              if (images.isNotEmpty) _images(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8,
                ),
                child: _getOptions(),
              ),
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

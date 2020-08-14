import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'like_content.dart';
import 'regalup_content.dart';
import 'poll_video.dart';
import 'menu_content.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../mixins/share_mixin.dart';
import '../models/resource_model.dart';
import '../screens/comments_screen.dart';
import '../screens/poll_gallery_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';

class ChallengeTile extends StatelessWidget with ShareContent {
  final String id;
  final String userName;
  final String userImage;
  final String title;
  final String description;
  final DateTime date;
  final int likes;
  final int regalups;
  final int comments;
  final bool hasLiked;
  final bool hasRegalup;
  final bool hasSaved;
  final String parameter;
  final int goal;
  final List resources;

  ChallengeTile({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.date,
    @required this.userName,
    @required this.userImage,
    @required this.likes,
    @required this.regalups,
    @required this.comments,
    @required this.hasLiked,
    @required this.hasRegalup,
    @required this.hasSaved,
    @required this.parameter,
    @required this.goal,
    @required this.resources,
  });

  final Color color = Color(0xFFFFF5FB);

  void _toProfile(context) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userName);
  }

  void _toHash(context, hashtag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(hashtag),
      ),
    );
  }

  void _toComments(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          id: id,
          type: 'C',
        ),
      ),
    );
  }

  void _share() {
    shareChallenge(id, title);
  }

  void _toGallery(context, images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: null,
          galleryItems: [images],
          initialIndex: 0,
        ),
      ),
    );
  }

  Widget _challengeGoal(context) {
    //bool goalReached = false;
    String goalString;
    int amount;
    switch (parameter) {
      case 'L':
        goalString = 'Likes';
        amount = likes;
        /*
        if (likes >= goal) {
          goalReached = true;
        }*/
        break;
      case 'C':
        goalString = 'Comentarios';
        amount = comments;
        /*
        if (comments >= goal) {
          goalReached = true;
        }*/
        break;
      case 'R':
        goalString = 'Regalups';
        amount = regalups;
        /*
        if (reposts >= goal) {
          goalReached = true;
        }*/
        break;
    }
    var totalPercentage = (amount == 0) ? 0.0 : amount / goal;
    if (totalPercentage > 1) totalPercentage = 1;
    final format = NumberFormat('###.##');

    ResourceModel resource = resources[0];
    return Column(
      children: <Widget>[
        if (resource.type == 'V') PollVideo('', resource.url, null),
        if (resource.type == 'I')
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _toGallery(context, resource.url),
              child: Hero(
                tag: resource.url,
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black),
                      image: DecorationImage(
                        image: NetworkImage(resource.url),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
          ),
        Container(
          height: 42,
          margin: EdgeInsets.all(16),
          child: Stack(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: totalPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xAAA4175D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                      bottomRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        goalString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '${format.format(totalPercentage * 100)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: color,
              child: ListTile(
                  onTap: () => _toProfile(context),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFA4175D),
                    backgroundImage: NetworkImage(userImage),
                  ),
                  title: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      //InfluencerBadge(influencer, 16),
                    ],
                  ),
                  subtitle: Text(timeago.format(now.subtract(difference))),
                  trailing: MenuContent(
                    id: id,
                    type: 'C',
                    isSaved: hasSaved,
                  )),
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
            _challengeGoal(context),
            SizedBox(height: 16),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExtendedText(
                  description,
                  style: TextStyle(fontSize: 16),
                  specialTextSpanBuilder:
                      MySpecialTextSpanBuilder(canClick: true),
                  onSpecialTextTap: (parameter) {
                    if (parameter.toString().startsWith('@')) {
                      String atText = parameter.toString();
                      int start = atText.indexOf('[');
                      int finish = atText.indexOf(']');
                      String toRemove = atText.substring(start + 1, finish);
                      //_toTaggedProfile(context, toRemove);
                    } else if (parameter.toString().startsWith('#')) {
                      _toHash(context, parameter.toString());
                    }
                  },
                ),
              ),
            if (description.isNotEmpty) SizedBox(height: 16),
            Container(
              color: color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () => _toComments(context),
                    icon: Icon(GalupFont.message),
                    label: Text(comments == 0 ? '' : '$comments'),
                  ),
                  LikeContent(
                    id: id,
                    type: 'C',
                    likes: likes,
                    hasLiked: hasLiked,
                  ),
                  RegalupContent(
                    id: id,
                    type: 'C',
                    regalups: regalups,
                    hasRegalup: hasRegalup,
                  ),
                  IconButton(
                    icon: Icon(GalupFont.share),
                    onPressed: _share,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

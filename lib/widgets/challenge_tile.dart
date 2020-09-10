import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'title_content.dart';
import 'description.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'menu_content.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';
import '../models/resource_model.dart';
import '../screens/comments_screen.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';

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
  final String regalupName;
  final certificate;

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
    @required this.certificate,
    this.regalupName,
  });

  final Color color = Color(0xFFFFF5FB);

  void _toProfile(context) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userName) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userName);
    }
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

  Widget _challengeGoal(context) {
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
        if (resource.type == 'V') PollVideo(resource.url, null),
        if (resource.type == 'I') PollImages([resource.url], null),
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
              child: Column(
                children: [
                  if (regalupName != null)
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
                            '$regalupName Regalup',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ListTile(
                      onTap: () => _toProfile(context),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFA4175D),
                        backgroundImage:
                            userImage == null ? null : NetworkImage(userImage),
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
                          InfluencerBadge(id, certificate, 16),
                        ],
                      ),
                      subtitle: Text(timeago.format(now.subtract(difference),
                          locale: Translations.of(context).currentLanguage)),
                      trailing: MenuContent(
                        id: id,
                        type: 'C',
                        isSaved: hasSaved,
                      )),
                ],
              ),
            ),
            SizedBox(height: 16),
            TitleContent(title),
            SizedBox(height: 16),
            if (goal > 0) _challengeGoal(context),
            if (goal > 0) SizedBox(height: 16),
            if (description != null && description.trim().isNotEmpty)
              Description(description),
            if (description != null && description.trim().isNotEmpty)
              SizedBox(height: 16),
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

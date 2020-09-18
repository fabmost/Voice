import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'title_content.dart';
import 'description.dart';
import 'challenge_meter.dart';
import 'comment_content.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'menu_content.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';
import '../models/resource_model.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';

class ChallengeTile extends StatelessWidget with ShareContent {
  final String reference;
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
    @required this.reference,
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

  void _share() {
    shareChallenge(id, title);
  }

  Widget _challengeGoal(context) {
    if (resources != null && resources.isNotEmpty) {
      ResourceModel resource = resources[0];

      if (resource.type == 'V') return PollVideo(resource.url, null);
      if (resource.type == 'I') return PollImages([resource.url], reference);
    }
    return Container();
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
            _challengeGoal(context),
            if (goal > 0) ChallengeMeter(id),
            SizedBox(height: 16),
            if (description != null && description.trim().isNotEmpty)
              Description(description),
            if (description != null && description.trim().isNotEmpty)
              SizedBox(height: 16),
            Container(
              color: color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CommentContent(
                    id: id,
                    type: 'C',
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

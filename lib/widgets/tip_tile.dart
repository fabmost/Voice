import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'title_content.dart';
import 'content_type_icon.dart';
import 'description.dart';
import 'comment_content.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'tip_total.dart';
import 'tip_rating.dart';
import 'menu_content.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';
import '../models/resource_model.dart';
import '../models/tip_model.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';

class TipTile extends StatelessWidget with ShareContent {
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
  final double rate;
  final bool hasLiked;
  final bool hasRegalup;
  final bool hasSaved;
  final bool hasRated;
  final List resources;
  final String regalupName;
  final certificate;

  TipTile({
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
    @required this.rate,
    @required this.hasLiked,
    @required this.hasRegalup,
    @required this.hasSaved,
    @required this.hasRated,
    @required this.resources,
    @required this.certificate,
    this.regalupName,
  });

  final Color color = Color(0xFFF4FDFF);

  void _toProfile(context) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userName) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userName);
    }
  }

  void showVote(context) {
    Map tips = Provider.of<ContentProvider>(context, listen: false).getTips;
    TipModel tip = tips[id];
    if (!tip.hasRated) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: TipRating(id),
        ),
      );
    }
  }

  void _share(context) {
    String image;
    if (userImage != null && userImage.isNotEmpty) {
      image = userImage;
    } else if (resources.isNotEmpty) {
      image = resources[0].url;
    }
    shareTip(context, id, title, image);
  }

  Widget _challengeGoal(context) {
    ResourceModel resource = resources[0];
    if (resource.type == 'V') return PollVideo(id, 'TIP', resource, null);
    if (resource.type == 'I') return PollImages([resource.url], reference);
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(date);
    final newDate = now.subtract(difference).toLocal();

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF00B2E3), width: 0.5),
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
                        backgroundColor: Color(0xFF00B2E3),
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
                      subtitle: Text(timeago.format(newDate,
                          locale: Translations.of(context).currentLanguage)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MenuContent(
                            id: id,
                            type: 'TIP',
                            isSaved: hasSaved,
                          ),
                          ContentTypeIcon(
                            name: 'Tip',
                            icon: GalupFont.tips,
                            color: Color(0xFF00B2E3),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TipTotal(
                    id: id,
                    total: rate,
                    hasRated: hasRated,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: TitleContent(title, false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (resources.isNotEmpty) _challengeGoal(context),
            if (resources.isNotEmpty) SizedBox(height: 16),
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
                    type: 'TIP',
                  ),
                  LikeContent(
                    id: id,
                    type: 'TIP',
                    likes: likes,
                    hasLiked: hasLiked,
                    tipFunction: () => showVote(context),
                  ),
                  RegalupContent(
                    id: id,
                    type: 'TIP',
                    regalups: regalups,
                    hasRegalup: hasRegalup,
                  ),
                  IconButton(
                    icon: Icon(GalupFont.share),
                    onPressed: ()=> _share(context),
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

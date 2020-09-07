import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'menu_content.dart';
import 'tip_total.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../models/tip_model.dart';
import '../models/resource_model.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';
import '../providers/user_provider.dart';

class HeaderTip extends StatelessWidget with ShareContent {
  final TipModel tipModel;
  final Color color = Color(0xFFF4FDFF);

  HeaderTip(this.tipModel);

  void _toProfile(context, creatorId) {
    if (Provider.of<UserProvider>(context, listen: false).getUser !=
        creatorId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
  }

  void _toHash(context, hashtag) {
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(hashtag),
    );
  }

  void _noExists(context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text('Este contenido ya no existe'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      ).then((value) {
        Navigator.of(context).pop();
      });
    });
  }

  void _share() {
    shareTip(tipModel.id, tipModel.title);
  }

  Widget _challengeGoal(context) {
    ResourceModel resource = tipModel.resources[0];
    if (resource.type == 'V') return PollVideo(resource.url, null);
    if (resource.type == 'I') return PollImages([resource.url], null);
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (tipModel == null) {
      _noExists(context);
      return Container();
    }
    final now = new DateTime.now();
    final difference = now.difference(tipModel.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: color,
          child: ListTile(
            onTap: () => _toProfile(context, tipModel.user.userName),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF00B2E3),
              backgroundImage: tipModel.user.icon == null
                  ? null
                  : NetworkImage(tipModel.user.icon),
            ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    tipModel.user.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                InfluencerBadge(tipModel.id, tipModel.certificate, 16),
              ],
            ),
            subtitle: Text(timeago.format(now.subtract(difference),
                locale: Translations.of(context).currentLanguage)),
            trailing: MenuContent(
              id: tipModel.id,
              type: 'TIP',
              isSaved: tipModel.hasSaved,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              TipTotal(
                id: tipModel.id,
                total: tipModel.total,
                hasRated: tipModel.hasRated,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  tipModel.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        if (tipModel.resources.isNotEmpty) _challengeGoal(context),
        if (tipModel.resources.isNotEmpty) SizedBox(height: 16),
        if (tipModel.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExtendedText(
              tipModel.description,
              style: TextStyle(fontSize: 16),
              specialTextSpanBuilder: MySpecialTextSpanBuilder(canClick: true),
              onSpecialTextTap: (parameter) {
                if (parameter.toString().startsWith('@')) {
                  String atText = parameter.toString();
                  int start = atText.indexOf('[');
                  int finish = atText.indexOf(']');
                  String toRemove = atText.substring(start + 1, finish);
                  _toProfile(context, toRemove);
                } else if (parameter.toString().startsWith('#')) {
                  _toHash(context, parameter.toString());
                }
              },
            ),
          ),
        if (tipModel.description.isNotEmpty) SizedBox(height: 16),
        Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              LikeContent(
                id: tipModel.id,
                type: 'TIP',
                likes: tipModel.likes,
                hasLiked: tipModel.hasLiked,
              ),
              RegalupContent(
                id: tipModel.id,
                type: 'TIP',
                regalups: tipModel.regalups,
                hasRegalup: tipModel.hasRegalup,
              ),
              IconButton(
                icon: Icon(GalupFont.share),
                onPressed: _share,
              ),
            ],
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'description.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'menu_content.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../models/challenge_model.dart';
import '../models/resource_model.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';

class HeaderChallenge extends StatelessWidget with ShareContent {
  final ChallengeModel challengeModel;
  final Color color = Color(0xFFFFF5FB);
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  HeaderChallenge(this.challengeModel);

  void _toProfile(context, creatorId) {
    if (Provider.of<UserProvider>(context, listen: false).getUser !=
        creatorId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
  }

  void _noExists(context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Este contenido ya no existe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    textColor: Colors.white,
                    child: Text('Ok'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).then((value) {
        Navigator.of(context).pop();
      });
    });
  }

  void _share() {
    shareChallenge(challengeModel.id, challengeModel.title);
  }

  Widget _challengeGoal(context) {
    //bool goalReached = false;
    String goal;
    int amount;
    switch (challengeModel.parameter) {
      case 'L':
        goal = 'Likes';
        amount = challengeModel.likes;
        /*
        if (likes >= goal) {
          goalReached = true;
        }*/
        break;
      case 'C':
        goal = 'Comentarios';
        amount = challengeModel.comments;
        /*
        if (comments >= goal) {
          goalReached = true;
        }*/
        break;
      case 'R':
        goal = 'Regalups';
        amount = challengeModel.regalups;
        /*
        if (reposts >= goal) {
          goalReached = true;
        }*/
        break;
    }
    var totalPercentage = (amount == 0) ? 0.0 : amount / challengeModel.goal;
    if (totalPercentage > 1) totalPercentage = 1;
    final format = NumberFormat('###.##');

    ResourceModel resource = challengeModel.resources[0];
    return Column(
      children: <Widget>[
        if (resource.type == 'V') PollVideo(resource.url, null),
        if (resource.type == 'I') PollImages([resource.url], ''),
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
                        goal,
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
    if (challengeModel == null) {
      _noExists(context);
      return Container();
    }
    final now = new DateTime.now();
    final difference = now.difference(challengeModel.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: color,
          child: ListTile(
            onTap: () => _toProfile(context, challengeModel.user.userName),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFA4175D),
              backgroundImage: challengeModel.user.icon == null
                  ? null
                  : NetworkImage(challengeModel.user.icon),
            ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    challengeModel.user.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                InfluencerBadge(challengeModel.id, challengeModel.certificate, 16),
              ],
            ),
            subtitle: Text(timeago.format(now.subtract(difference),
                locale: Translations.of(context).currentLanguage)),
            trailing: MenuContent(
              id: challengeModel.id,
              type: 'C',
              isSaved: challengeModel.hasSaved,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            challengeModel.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        _challengeGoal(context),
        SizedBox(height: 16),
        if (challengeModel.description != null &&
            challengeModel.description.isNotEmpty)
          Description(challengeModel.description),
        if (challengeModel.description != null &&
            challengeModel.description.isNotEmpty)
          SizedBox(height: 16),
        Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              LikeContent(
                id: challengeModel.id,
                type: 'C',
                likes: challengeModel.likes,
                hasLiked: challengeModel.hasLiked,
              ),
              RegalupContent(
                id: challengeModel.id,
                type: 'C',
                regalups: challengeModel.regalups,
                hasRegalup: challengeModel.hasRegalup,
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

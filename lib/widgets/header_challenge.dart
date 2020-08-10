import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_video.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../models/challenge_model.dart';
import '../models/resource_model.dart';
import '../providers/preferences_provider.dart';
import '../screens/view_profile_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/flag_screen.dart';
import '../screens/poll_gallery_screen.dart';
import '../screens/search_results_screen.dart';

class HeaderChallenge extends StatelessWidget with ShareContent {
  final ChallengeModel challengeModel;
  final Color color = Color(0xFFFFF5FB);

  HeaderChallenge(this.challengeModel);

  void _toProfile(context, creatorId) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
  }

  void _toHash(context, hashtag) {
    Navigator.of(context)
        .pushNamed(SearchResultsScreen.routeName, arguments: hashtag);
  }

  void _toGallery(context, images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: null,
          galleryItems: images,
          initialIndex: 0,
        ),
      ),
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

  void _anonymousAlert(context, text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text(Translations.of(context).text('button_cancel')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text(Translations.of(context).text('button_create_account')),
          ),
        ],
      ),
    );
  }

  void _share() {
    shareChallenge(challengeModel.id, challengeModel.title);
  }

  void _flag(context) {
    /*
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
        */
  }

  void _save(context, hasSaved) async {
    /*
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(
        context,
        Translations.of(context).text('dialog_need_account'),
      );
      return;
    }
    WriteBatch batch = Firestore.instance.batch();
    if (hasSaved) {
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'saved': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayRemove([userId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'saved': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayUnion([userId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();

    Navigator.of(context).pop();
    */
  }

  void _options(context, creatorId, hasSaved) {
    /*
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              if (creatorId != userId)
                ListTile(
                  onTap: () => _save(context, hasSaved),
                  leading: Icon(
                    GalupFont.saved,
                  ),
                  title: Text(hasSaved
                      ? Translations.of(context).text('button_delete')
                      : Translations.of(context).text('button_save')),
                ),
              ListTile(
                onTap: () => _flag(context),
                leading: new Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('title_flag'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
    */
  }

  Widget _challengeGoal(
    context,
  ) {
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
              backgroundImage: NetworkImage(challengeModel.user.icon),
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
                //InfluencerBadge(document['influencer'] ?? '', 16),
              ],
            ),
            subtitle: Text(timeago.format(now.subtract(difference))),
            trailing: Transform.rotate(
              angle: 270 * pi / 180,
              child: IconButton(
                icon: Icon(Icons.chevron_left),
                //onPressed: () => _options(context, creatorId, hasSaved),
              ),
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
        if (challengeModel.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExtendedText(
              challengeModel.description,
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
        if (challengeModel.description.isNotEmpty) SizedBox(height: 16),
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

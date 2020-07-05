import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../providers/preferences_provider.dart';
import '../screens/view_profile_screen.dart';
import '../screens/auth_screen.dart';

class HeaderChallenge extends StatelessWidget {
  final DocumentReference reference;
  final String userId;
  final Color color = Color(0xFFFFF5FB);

  HeaderChallenge(this.reference, this.userId);

  void _toProfile(context, creatorId) {
    if (userId != creatorId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
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

  void _like(context, hasLiked) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      final interactions =
          await Provider.of<Preferences>(context, listen: false)
              .getInteractions();
      if (interactions >= 5) {
        _anonymousAlert(
          context,
          Translations.of(context).text('dialog_interactions_done'),
        );
        return;
      }
    }
    WriteBatch batch = Firestore.instance.batch();
    if (hasLiked) {
      Provider.of<Preferences>(context, listen: false).removeInteractions();
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'liked': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'likes': FieldValue.arrayRemove([userId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      Provider.of<Preferences>(context, listen: false).setInteractions();
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'liked': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'likes': FieldValue.arrayUnion([userId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _repost(context) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(
        context,
        Translations.of(context).text('dialog_need_account'),
      );
      return;
    }
  }

  void _share() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse(
          'https://galup.page.link/challenge/${reference.documentID}'),
      androidParameters: AndroidParameters(
        packageName: 'com.oz.voice_inc',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.oz.voiceInc',
        minimumVersion: '0',
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share('Te comparto este Reto de Galup $url');
  }

  void _flag(context) {
    Navigator.of(context).pop();
  }

  void _save(context, hasSaved) async {
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
  }

  void _options(context, creatorId, hasSaved) {
    FocusScope.of(context).requestFocus(FocusNode());
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
                  title: Text(hasSaved ? 'Borrar' : 'Guardar'),
                ),
              ListTile(
                onTap: () => _flag(context),
                leading: new Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  'Denunciar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _challengeGoal(metric, goal, likes, comments, reposts) {
    bool goalReached = false;
    int amount;
    switch (metric) {
      case 'likes':
        amount = likes;
        if (likes >= goal) {
          goalReached = true;
        }
        break;
      case 'comentarios':
        amount = comments;
        if (comments >= goal) {
          goalReached = true;
        }
        break;
      case 'regalups':
        amount = reposts;
        if (reposts >= goal) {
          goalReached = true;
        }
        break;
    }
    final totalPercentage = (amount == 0) ? 0.0 : amount / goal;
    final format = NumberFormat('###.##');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        onPressed: goalReached ? () {} : null,
        child: Text(goalReached ? 'Ver' : '${format.format(totalPercentage * 100)}% completado'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: reference.snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final document = snapshot.data;

          int likes = 0;
          bool hasLiked = false;
          if (document['likes'] != null) {
            likes = document['likes'].length;
            hasLiked = (document['likes'] as List).contains(userId);
          }
          int reposts = 0;
          bool hasReposted = false;
          if (document['reposts'] != null) {
            reposts = document['reposts'].length;
            hasReposted = (document['reposts'] as List).contains(userId);
          }
          bool hasSaved = false;
          if (document['saved'] != null) {
            hasSaved = (document['saved'] as List).contains(userId);
          }

          final creatorId = document['user_id'];
          final userImage = document['user_image'] ?? '';

          final date = document['createdAt'].toDate();
          final now = new DateTime.now();
          final difference = now.difference(date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: color,
                child: ListTile(
                  onTap: creatorId == userId
                      ? null
                      : () => _toProfile(context, creatorId),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFA4175D),
                    backgroundImage: NetworkImage(userImage),
                  ),
                  title: Text(
                    document['user_name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(timeago.format(now.subtract(difference))),
                  trailing: Transform.rotate(
                    angle: 270 * pi / 180,
                    child: IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () => _options(context, creatorId, hasSaved),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  document['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _challengeGoal(
                document['metric_type'],
                document['metric_goal'],
                likes,
                document['comments'],
                reposts,
              ),
              SizedBox(height: 16),
              Container(
                color: color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () => _like(context, hasLiked),
                      icon: Icon(GalupFont.like,
                          color: hasLiked ? Color(0xFFA4175D) : Colors.black),
                      label: Text(likes == 0 ? '' : '$likes'),
                    ),
                    FlatButton.icon(
                      onPressed: () => _repost(context),
                      icon: Icon(GalupFont.repost,
                          color:
                              hasReposted ? Color(0xFFA4175D) : Colors.black),
                      label: Text(reposts == 0 ? '' : '$reposts'),
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
        });
  }
}

import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_video.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../providers/preferences_provider.dart';
import '../screens/view_profile_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/flag_screen.dart';
import '../screens/poll_gallery_screen.dart';
import '../screens/search_results_screen.dart';

class HeaderChallenge extends StatelessWidget with ShareContent {
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

  void _toTaggedProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
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
          reference: reference,
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

  void _repost(context, title, userName, userImage, influencer, metric, goal,
      date, hasReposted) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(
        context,
        Translations.of(context).text('dialog_need_account'),
      );
      return;
    }

    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    WriteBatch batch = Firestore.instance.batch();

    if (hasReposted) {
      String repostId;
      final item = (userData['reposted'] as List).firstWhere(
        (element) => (element as Map).containsKey(reference.documentID),
        orElse: () => null,
      );
      if (item != null) {
        repostId = item[reference.documentID];
      }
      batch.delete(Firestore.instance.collection('content').document(repostId));
      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {
          'reposted': FieldValue.arrayRemove([
            {reference.documentID: repostId}
          ])
        },
      );
      batch.updateData(reference, {
        'reposts': FieldValue.arrayRemove([user.uid]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      String repostId =
          Firestore.instance.collection('content').document().documentID;

      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {
          'reposted': FieldValue.arrayUnion([
            {reference.documentID: repostId}
          ])
        },
      );
      batch.setData(
          Firestore.instance.collection('content').document(repostId), {
        'type': 'repost-challenge',
        'user_name': userData['user_name'],
        'user_id': user.uid,
        'createdAt': Timestamp.now(),
        'title': title,
        'creator_name': userName,
        'creator_image': userImage,
        'influencer': influencer,
        'metric_type': metric,
        'metric_goal': goal,
        'originalDate': Timestamp.fromDate(date),
        'parent': reference,
        'home': userData['followers'] ?? [],
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([user.uid]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share(title) {
    shareChallenge(reference.documentID, title);
  }

  void _flag(context) {
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
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
  }

  Widget _challengeGoal(
    context,
    metric,
    goal,
    likes,
    comments,
    reposts,
    isVideo,
    images,
  ) {
    //bool goalReached = false;
    int amount;
    switch (metric) {
      case 'likes':
        amount = likes;
        /*
        if (likes >= goal) {
          goalReached = true;
        }*/
        break;
      case 'comentarios':
        amount = comments;
        /*
        if (comments >= goal) {
          goalReached = true;
        }*/
        break;
      case 'regalups':
        amount = reposts;
        /*
        if (reposts >= goal) {
          goalReached = true;
        }*/
        break;
    }
    var totalPercentage = (amount == 0) ? 0.0 : amount / goal;
    if (totalPercentage > 1) totalPercentage = 1;
    final format = NumberFormat('###.##');

    return Column(
      children: <Widget>[
        if (isVideo) PollVideo('', images[0], null),
        if (!isVideo)
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _toGallery(context, images),
              child: Hero(
                tag: images[0],
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
                        metric.toUpperCase(),
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
    return StreamBuilder(
        stream: reference.snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final document = snapshot.data;

          if (document.data == null) {
            _noExists(context);
            return Container();
          }

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
          final description = document['description'] ?? '';

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
                  title: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          document['user_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      InfluencerBadge(document['influencer'] ?? '', 16),
                    ],
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
                child: ExtendedText(
                  document['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  specialTextSpanBuilder:
                      MySpecialTextSpanBuilder(canClick: true),
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
              SizedBox(height: 16),
              _challengeGoal(
                  context,
                  document['metric_type'],
                  document['metric_goal'],
                  likes,
                  document['comments'],
                  reposts,
                  document['is_video'] ?? false,
                  document['images']),
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
                        _toTaggedProfile(context, toRemove);
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
                      onPressed: () => _like(context, hasLiked),
                      icon: Icon(GalupFont.like,
                          color: hasLiked ? Color(0xFFA4175D) : Colors.black),
                      label: Text(likes == 0 ? '' : '$likes'),
                    ),
                    FlatButton.icon(
                      onPressed: () => _repost(
                        context,
                        document['title'],
                        document['user_name'],
                        userImage,
                        document['influencer'],
                        document['metric_type'],
                        document['metric_goal'],
                        date,
                        hasReposted,
                      ),
                      icon: Icon(GalupFont.repost,
                          color:
                              hasReposted ? Color(0xFFA4175D) : Colors.black),
                      label: Text(reposts == 0 ? '' : '$reposts'),
                    ),
                    IconButton(
                      icon: Icon(GalupFont.share),
                      onPressed: () => _share(document['title']),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'poll_video.dart';
import 'influencer_badge.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../providers/preferences_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/comments_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/flag_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/poll_gallery_screen.dart';

class Tip extends StatelessWidget with ShareContent {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String userImage;
  final String title;
  final int comments;
  final bool hasLiked;
  final int likes;
  final bool hasReposted;
  final int reposts;
  final bool hasSaved;
  final DateTime date;
  final String influencer;
  final bool isVideo;
  final List images;
  final String description;

  final videoFunction;

  final Color color = Color(0xFFFFF5FB);

  Tip({
    this.reference,
    this.userName,
    this.myId,
    this.userImage,
    this.title,
    this.comments,
    this.userId,
    this.likes,
    this.hasLiked,
    this.reposts,
    this.hasReposted,
    this.hasSaved,
    this.date,
    @required this.influencer,
    @required this.isVideo,
    @required this.images,
    @required this.description,
    @required this.videoFunction,
  });

  void _toProfile(context) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  void _toComments(context) {
    Navigator.of(context)
        .pushNamed(CommentsScreen.routeName, arguments: reference);
  }

  void _toTaggedProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toHash(context, hashtag) {
    Navigator.of(context)
        .pushNamed(SearchResultsScreen.routeName, arguments: hashtag);
  }

  void _toGallery(context, position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: reference,
          galleryItems: images,
          initialIndex: position,
        ),
      ),
    );
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

  void _like(context) async {
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
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'liked': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'likes': FieldValue.arrayRemove([myId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      Provider.of<Preferences>(context, listen: false).setInteractions();
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'liked': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'likes': FieldValue.arrayUnion([myId]),
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
        'reposts': FieldValue.arrayRemove([myId]),
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
        'type': 'repost-tip',
        'user_name': userData['user_name'],
        'user_id': user.uid,
        'createdAt': Timestamp.now(),
        'title': title,
        'creator_name': userName,
        'creator_image': userImage,
        'influencer': influencer,
        'originalDate': Timestamp.fromDate(date),
        'parent': reference,
        'home': userData['followers'] ?? [],
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share() async {
    shareChallenge(reference.documentID, title);
  }

  void _flag(context) {
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
  }

  void _save(context) async {
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
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'saved': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayRemove([myId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'saved': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();

    Navigator.of(context).pop();
  }

  void _options(context) {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              if (myId != userId)
                ListTile(
                  onTap: () => _save(context),
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

  Widget _challengeGoal(context) {
    if (isVideo) return PollVideo('', images[0], videoFunction);

    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () => _toGallery(context, 0),
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
                onTap: myId == userId ? null : () => _toProfile(context),
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
                    InfluencerBadge(influencer, 16),
                  ],
                ),
                subtitle: Text(timeago.format(now.subtract(difference))),
                trailing: Transform.rotate(
                  angle: 270 * pi / 180,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => _options(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExtendedText(
                title,
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
                    _toTaggedProfile(context, toRemove);
                  } else if (parameter.toString().startsWith('#')) {
                    _toHash(context, parameter.toString());
                  }
                },
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
                    onPressed: () => _toComments(context),
                    icon: Icon(GalupFont.message),
                    label: Text(comments == 0 ? '' : '$comments'),
                  ),
                  FlatButton.icon(
                    onPressed: () => _like(context),
                    icon: Icon(GalupFont.like,
                        color: hasLiked ? Color(0xFFA4175D) : Colors.black),
                    label: Text(likes == 0 ? '' : '$likes'),
                  ),
                  FlatButton.icon(
                    onPressed: () => _repost(context),
                    icon: Icon(GalupFont.repost,
                        color: hasReposted ? Color(0xFFA4175D) : Colors.black),
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
        ),
      ),
    );
  }
}

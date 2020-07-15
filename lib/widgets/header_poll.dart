import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_options.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../providers/preferences_provider.dart';
import '../custom/galup_font_icons.dart';
import '../screens/view_profile_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/poll_gallery_screen.dart';
import '../screens/flag_screen.dart';

class HeaderPoll extends StatelessWidget with ShareContent {
  final DocumentReference reference;
  final String userId;

  final Color color = Color(0xFFF8F8FF);

  HeaderPoll(this.reference, this.userId);

  void _toProfile(context, creatorId) {
    if (creatorId != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
  }

  void _toGallery(context, images, position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          galleryItems: images,
          initialIndex: position,
          reference: reference,
          userId: userId,
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

  void _repost(context, title, userName, userImage, influencer, options, date,
      images, hasReposted) async {
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
        'type': 'repost-poll',
        'user_name': userData['user_name'],
        'user_id': user.uid,
        'createdAt': Timestamp.now(),
        'title': title,
        'creator_name': userName,
        'creator_image': userImage,
        'influencer': influencer,
        'options': options,
        'originalDate': Timestamp.fromDate(date),
        'images': images,
        'parent': reference,
        'home': userData['followers'] ?? []
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([user.uid]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share() async {
    sharePoll(reference.documentID);
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
                  title: Text(hasSaved ? 'Borrar' : 'Guardar'),
                ),
              ListTile(
                onTap: () => _flag(context),
                leading: Icon(
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

  Widget _images(context, images) {
    if (images.length == 1) {
      return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => _toGallery(context, images, 0),
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
    } else if (images.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => _toGallery(context, images, 0),
            child: Hero(
              tag: images[0],
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => _toGallery(context, images, 1),
            child: Hero(
              tag: images[1],
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => _toGallery(context, images, 0),
            child: Hero(
              tag: images[0],
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => _toGallery(context, images, 1),
            child: Hero(
              tag: images[1],
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => _toGallery(context, images, 2),
            child: Hero(
              tag: images[2],
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[2]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }
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

          int vote = -1;
          bool hasVoted = false;
          int voters = 0;
          if (document['voters'] != null) {
            voters = document['voters'].length;
            final item = (document['voters'] as List).firstWhere(
              (element) => (element as Map).containsKey(userId),
              orElse: () => null,
            );
            if (item != null) {
              hasVoted = true;
              vote = item[userId];
            }
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
          final images = document['images'] ?? [];

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
                    backgroundColor: Theme.of(context).accentColor,
                    backgroundImage: NetworkImage(userImage),
                  ),
                  title: Row(
                    children: <Widget>[
                      Text(
                        document['user_name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
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
                child: Text(
                  document['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (images.isNotEmpty) SizedBox(height: 16),
              if (images.isNotEmpty) _images(context, images),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8,
                ),
                child: PollOptions(
                  reference: reference,
                  userId: userId,
                  votes: document['results'],
                  options: document['options'],
                  hasVoted: hasVoted,
                  vote: vote,
                  voters: voters,
                ),
              ),
              if (voters > 0)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                  ),
                  child: Text(voters == 1
                      ? '$voters participante'
                      : '$voters participantes'),
                ),
              Container(
                color: color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton.icon(
                      onPressed: () => _like(context, hasLiked),
                      icon: Icon(
                        GalupFont.like,
                        color: hasLiked
                            ? Theme.of(context).accentColor
                            : Colors.black,
                      ),
                      label: Text(likes == 0 ? '' : '$likes'),
                    ),
                    FlatButton.icon(
                      onPressed: () => _repost(
                        context,
                        document['title'],
                        document['user_name'],
                        userImage,
                        document['influencer'] ?? '',
                        document['options'],
                        date,
                        images,
                        hasReposted,
                      ),
                      icon: Icon(GalupFont.repost,
                          color: hasReposted
                              ? Theme.of(context).accentColor
                              : Colors.black),
                      label: Text(reposts == 0 ? '' : '$reposts'),
                    ),
                    IconButton(
                      icon: Icon(GalupFont.share),
                      onPressed: _share,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

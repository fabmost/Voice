import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'auth_screen.dart';
import 'flag_screen.dart';
import 'view_profile_screen.dart';
import 'poll_gallery_screen.dart';
import 'search_results_screen.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../widgets/influencer_badge.dart';
import '../widgets/poll_video.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../providers/preferences_provider.dart';

class DetailCauseScreen extends StatelessWidget with ShareContent {
  static const routeName = '/cause';
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  final Color color = Color(0xFFF0F0F0);

  void _toProfile(context, creatorId) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
  }

  void _toTaggedProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toHash(context, hashtag) {
    Navigator.of(context)
        .pushNamed(SearchResultsScreen.routeName, arguments: hashtag);
  }

  void _call(contact) async {
    if (await canLaunch('tel:$contact')) {
      await launch('tel:$contact');
    } else {
      throw 'Could not launch $contact';
    }
  }

  void _launchURL(String url) async {
    String newUrl = url;
    if (!url.contains('http')) {
      newUrl = 'http://$url';
    }
    if (await canLaunch(newUrl.trim())) {
      await launch(newUrl.trim());
    } else {
      throw 'Could not launch $newUrl';
    }
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

  void _infoAlert(context, info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(info),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.black,
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _anonymousAlert(context, String text) {
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

  void _like(context, reference, myId, hasLiked) async {
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

  void _repost(
    context,
    reference,
    myId,
    title,
    creator,
    userName,
    userImage,
    influencer,
    date,
    hasReposted,
    images,
  ) async {
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
        'type': 'repost-cause',
        'user_name': userData['user_name'],
        'user_id': user.uid,
        'createdAt': Timestamp.now(),
        'title': title,
        'creator': creator,
        'originalDate': date,
        'parent': reference,
        'home': userData['followers'] ?? [],
        'info': '',
        'creator_name': userName,
        'creator_image': userImage,
        'influencer': influencer,
        'images': images,
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share(reference, title) async {
    shareCause(reference.documentID, title);
  }

  void _flag(context, reference) {
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
  }

  void _save(context, reference, myId, hasSaved) async {
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

  void _options(context, reference, myId, hasSaved) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _save(context, reference, myId, hasSaved),
                leading: Icon(
                  GalupFont.saved,
                ),
                title: Text(hasSaved
                    ? Translations.of(context).text('button_delete')
                    : Translations.of(context).text('button_save')),
              ),
              ListTile(
                onTap: () => _flag(context, reference),
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
    goal,
    likes,
    isVideo,
    images,
  ) {
    //bool goalReached = false;
    var totalPercentage = (likes == 0) ? 0.0 : likes / goal;
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
                        'Firmas',
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

  Widget _causeButton(context, reference, myId, hasLiked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: hasLiked
          ? OutlineButton(
              highlightColor: Color(0xFFA4175D),
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
              onPressed: () => _like(context, reference, myId, hasLiked),
              child: Text('No apoyo esta causa'),
            )
          : RaisedButton(
              onPressed: () => _like(context, reference, myId, hasLiked),
              color: Colors.black,
              textColor: Colors.white,
              child: Text('Apoyo esta causa'),
            ),
    );
  }

  Widget _userTile(context, DocumentSnapshot document, userId, hasSaved) {
    if (document['info'].isNotEmpty)
      return ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage: AssetImage('assets/logo.png'),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              document['creator'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: Icon(GalupFont.info_circled_alt),
              onPressed: () => _infoAlert(context, document['info']),
            )
          ],
        ),
        subtitle: Text('Por: Galup'),
        trailing: Transform.rotate(
          angle: 270 * pi / 180,
          child: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () => _options(
                    context,
                    document.reference,
                    userId,
                    hasSaved,
                  )),
        ),
      );
    String creatorId = document['user_id'];
    String userImage = document['user_image'] ?? '';
    final date = document['createdAt'].toDate();
    final now = new DateTime.now();
    final difference = now.difference(date);
    return ListTile(
      onTap: creatorId == userId ? null : () => _toProfile(context, creatorId),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).accentColor,
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
          onPressed: () => _options(
            context,
            document.reference,
            userId,
            hasSaved,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    final DocumentReference reference =
        Firestore.instance.collection('content').document(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_cause')),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: reference.snapshots(),
            builder: (ct, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final document = snapshot.data;

              int likes = 0;
              bool hasLiked = false;
              if (document['likes'] != null) {
                likes = document['likes'].length;
                hasLiked =
                    (document['likes'] as List).contains(userSnap.data.uid);
              }
              int reposts = 0;
              bool hasReposted = false;
              if (document['reposts'] != null) {
                reposts = document['reposts'].length;
                hasReposted =
                    (document['reposts'] as List).contains(userSnap.data.uid);
              }
              bool hasSaved = false;
              if (document['saved'] != null) {
                hasSaved =
                    (document['saved'] as List).contains(userSnap.data.uid);
              }

              final String description = document['description'] ?? '';
              final String contact = document['phone'] ?? '';
              final String web = document['web'] ?? '';
              final String bank = document['bank'] ?? '';

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: color,
                      child: _userTile(
                        context,
                        document,
                        userSnap.data.uid,
                        hasSaved,
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
                    if (document['goal'] != null)
                      _challengeGoal(
                        context,
                        document['goal'],
                        likes,
                        document['is_video'] ?? false,
                        document['images'],
                      ),
                    if (document['goal'] != null) SizedBox(height: 16),
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
                              String toRemove =
                                  atText.substring(start + 1, finish);
                              _toTaggedProfile(context, toRemove);
                            } else if (parameter.toString().startsWith('#')) {
                              _toHash(context, parameter.toString());
                            } else if (regex.hasMatch(parameter.toString())) {
                              _launchURL(parameter.toString());
                            }
                          },
                        ),
                      ),
                    if (description.isNotEmpty) SizedBox(height: 16),
                    _causeButton(
                      context,
                      reference,
                      userSnap.data.uid,
                      hasLiked,
                    ),
                    if (contact.isNotEmpty)
                      ListTile(
                        onTap: () => _call(contact),
                        leading: Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        title: Text('Contáctame'),
                        subtitle: Text(contact),
                      ),
                    if (web.isNotEmpty)
                      ListTile(
                        onTap: () => _launchURL(web),
                        leading: Icon(
                          Icons.open_in_browser,
                          color: Colors.black,
                        ),
                        title: Text('Visita'),
                        subtitle: Text(web),
                      ),
                    if (bank.isNotEmpty)
                      ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: Colors.black,
                        ),
                        title: Text('Donaciones'),
                        subtitle: Text(bank),
                      ),
                    SizedBox(height: 16),
                    Container(
                      color: color,
                      child: Row(
                        children: <Widget>[
                          FlatButton.icon(
                            onPressed: () => _repost(
                              context,
                              reference,
                              userSnap.data.uid,
                              document['title'],
                              document['creator'],
                              document['user_name'] ?? '',
                              document['user_image'] ?? '',
                              document['influencer'] ?? '',
                              document['createdAt'],
                              hasReposted,
                              document['images'] ?? [],
                            ),
                            icon: Icon(GalupFont.repost,
                                color: hasReposted
                                    ? Theme.of(context).primaryColor
                                    : Colors.black),
                            label: Text(reposts == 0 ? '' : '$reposts'),
                          ),
                          IconButton(
                            icon: Icon(GalupFont.share),
                            onPressed: () =>
                                _share(reference, document['title']),
                          ),
                          Expanded(child: SizedBox(height: 1)),
                          Text(likes == 0 ? '' : '$likes Votos'),
                          SizedBox(width: 16),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

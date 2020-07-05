import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../providers/preferences_provider.dart';
import '../screens/auth_screen.dart';

class DetailCauseScreen extends StatelessWidget {
  static const routeName = '/cause';

  final Color color = Color(0xFFF0F0F0);

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

  void _repost() {}

  void _share(reference) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.page.link/cause/${reference.documentID}'),
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

    Share.share('Te comparto esta Causa de Galup $url');
  }

  void _flag(context) {
    Navigator.of(context).pop();
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
    FocusScope.of(context).requestFocus(FocusNode());
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
                title: Text(hasSaved ? 'Borrar' : 'Guardar'),
              ),
              ListTile(
                onTap: () => _flag(context),
                leading: new Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  "Denunciar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _causeButton(context, reference, myId, hasLiked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        borderSide: BorderSide(
          color: Colors.black,
          width: 2,
        ),
        onPressed: () => _like(context, reference, myId, hasLiked),
        child: Text(hasLiked ? 'No apoyo esta causa' : 'Apoyo esta causa'),
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

              return Column(
                children: <Widget>[
                  Container(
                    color: color,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            document['creator'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle),
                            onPressed: () =>
                                _infoAlert(context, document['info']),
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
                                  reference,
                                  userSnap.data.uid,
                                  hasSaved,
                                )),
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
                  _causeButton(
                    context,
                    reference,
                    userSnap.data.uid,
                    hasLiked,
                  ),
                  SizedBox(height: 16),
                  Container(
                    color: color,
                    child: Row(
                      children: <Widget>[
                        FlatButton.icon(
                          onPressed: _repost,
                          icon: Icon(GalupFont.repost,
                              color: hasReposted
                                  ? Color(0xFFA4175D)
                                  : Colors.black),
                          label: Text(reposts == 0 ? '' : '$reposts'),
                        ),
                        IconButton(
                          icon: Icon(GalupFont.share),
                          onPressed: () => _share(reference),
                        ),
                        Expanded(child: SizedBox(height: 1)),
                        Text(likes == 0 ? '' : '$likes Votos'),
                        SizedBox(width: 16),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

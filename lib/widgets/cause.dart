import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../translations.dart';
import '../screens/auth_screen.dart';
import '../custom/galup_font_icons.dart';
import '../providers/preferences_provider.dart';

class Cause extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String creator;
  final String title;
  final bool hasLiked;
  final int likes;
  final bool hasReposted;
  final int reposts;
  final bool hasSaved;
  final String info;

  final Color color = Color(0xFFF0F0F0);

  Cause({
    this.reference,
    this.myId,
    this.creator,
    this.title,
    this.likes,
    this.hasLiked,
    this.reposts,
    this.hasReposted,
    this.hasSaved,
    this.info,
  });

  void _infoAlert(context) {
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
        'type': 'repost-cause',
        'user_name': userData['user_name'],
        'user_id': user.uid,
        'createdAt': Timestamp.now(),
        'title': title,
        'info': info,
        'creator': creator,
        'originalDate': Timestamp.now(),
        'parent': reference,
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://voiceinc.page.link',
      link: Uri.parse('https://voiceinc.page.link/cause/${reference.documentID}'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
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
              ListTile(
                onTap: () => _save(context),
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

  Widget _causeButton(context) {
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
        onPressed: () => _like(context),
        child: Text(hasLiked ? 'No apoyo esta causa' : 'Apoyo esta causa'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      creator,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(GalupFont.info_circled_alt),
                      onPressed: ()=> _infoAlert(context),
                    )
                  ],
                ),
                subtitle: Text('Por: Galup'),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            _causeButton(context),
            SizedBox(height: 16),
            Container(
              color: color,
              child: Row(
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: ()=> _repost(context),
                    icon: Icon(GalupFont.repost,
                        color: hasReposted ? Colors.grey : Colors.black),
                    label: Text(reposts == 0 ? '' : '$reposts'),
                  ),
                  IconButton(
                    icon: Icon(GalupFont.share),
                    onPressed: _share,
                  ),
                  Expanded(child: SizedBox(height: 1)),
                  Text(likes == 0 ? '' : '$likes Votos'),
                  SizedBox(width: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

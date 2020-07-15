import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../providers/preferences_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/flag_screen.dart';

class DetailCauseScreen extends StatelessWidget with ShareContent{
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
      context, reference, myId, title, info, creator, date, hasReposted) async {
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
        'originalDate': date,
        'parent': reference,
        'home': userData['followers'] ?? []
      });
      batch.updateData(reference, {
        'reposts': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();
  }

  void _share(reference) async {
    shareCause(reference.documentID);
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
    //FocusScope.of(context).requestFocus(FocusNode());
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
                onTap: () => _flag(context, reference),
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
                        backgroundColor: Theme.of(context).primaryColor,
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
                            icon: Icon(GalupFont.info_circled_alt),
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
                          onPressed: () => _repost(
                            context,
                            reference,
                            userSnap.data.uid,
                            document['title'],
                            document['info'],
                            document['creator'],
                            document['createdAt'],
                            hasReposted,
                          ),
                          icon: Icon(GalupFont.repost,
                              color: hasReposted
                                  ? Theme.of(context).primaryColor
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

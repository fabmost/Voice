import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/view_profile_screen.dart';

class InfluencerItem extends StatelessWidget {
  final DocumentReference reference;
  final String userName;
  final String image;
  final bool isFollowing;

  final Color color = Color(0xFFF8F8FF);

  InfluencerItem({
    this.reference,
    this.userName,
    this.image,
    this.isFollowing,
  });

  void _toProfile(context) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName,
        arguments: reference.documentID);
  }

  /*

  void _anonymousAlert(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_need_account')),
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

  void _follow(context) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(context);
      return;
    }
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    final List creations = userData['created'] ?? [];
    if (userData['reposted'] != null) {
      (userData['reposted'] as List).forEach((element) {
        creations.add(element.values.first);
      });
    }
    WriteBatch batch = Firestore.instance.batch();
    if (!isFollowing) {
      FirebaseMessaging().subscribeToTopic(reference.documentID);
      batch.updateData(
        reference,
        {
          'followers': FieldValue.arrayUnion([user.uid])
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {
          'following': FieldValue.arrayUnion([reference.documentID])
        },
      );
      creations.forEach((element) {
        batch.updateData(
          Firestore.instance.collection('content').document(element),
          {
            'home': FieldValue.arrayUnion([user.uid])
          },
        );
      });
    } else {
      FirebaseMessaging().unsubscribeFromTopic(reference.documentID);
      batch.updateData(
        reference,
        {
          'followers': FieldValue.arrayRemove([user.uid])
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {
          'following': FieldValue.arrayRemove([reference.documentID])
        },
      );
      creations.forEach((element) {
        batch.updateData(
          Firestore.instance.collection('content').document(element),
          {
            'home': FieldValue.arrayRemove([user.uid])
          },
        );
      });
    }
    batch.commit();
  }

  Widget _followButton(context) {
    if (!isFollowing) {
      return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: () => _follow(context),
          textColor: Colors.white,
          child: Text('Seguir'),
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: OutlineButton(
        onPressed: () => _follow(context),
        child: Text('Siguiendo'),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _toProfile(context),
      child: Container(
        height: 220,
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: Theme.of(context).accentColor,
            ),
            color: color),
        child: Column(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, imageProvider) => Container(
                width: double.infinity,
                height: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => Container(
                height: 125,
                width: double.infinity,
                child: Center(
                  child: Text('Ocurrió un error al cargar la imagen $error'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            /*
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: _followButton(context)
            ),*/
          ],
        ),
      ),
    );
  }
}

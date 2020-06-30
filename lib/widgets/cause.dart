import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../custom/galup_font_icons.dart';

class Cause extends StatelessWidget {
  final DocumentReference reference;
  //final String userId;
  final String myId;
  //final String userName;
  //final String userImage;
  final String title;
  final bool hasLiked;
  final int likes;
  final bool hasReposted;
  final int reposts;

  final Color color = Color(0xFFF0F0F0);

  Cause({
    this.reference,
    //this.userName,
    this.myId,
    //this.userImage,
    this.title,
    //this.userId,
    this.likes,
    this.hasLiked,
    this.reposts,
    this.hasReposted,
  });

  void _like() {
    WriteBatch batch = Firestore.instance.batch();
    if (hasLiked) {
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'liked': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'likes': FieldValue.arrayRemove([myId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
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

  void _share() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://voiceinc.page.link',
      link: Uri.parse('https://app.galup.app/cause/${reference.documentID}'),
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

  Widget _causeButton() {
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
        onPressed: _like,
        child: Text(hasLiked ? 'Ya no a favor' : 'A favor'),
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
                title: Text(
                  'Defiende tu causa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            _causeButton(),
            SizedBox(height: 16),
            Container(
              color: color,
              child: Row(
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: _repost,
                    icon: Icon(GalupFont.repost,
                        color: hasReposted ? Color(0xFFA4175D) : Colors.black),
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

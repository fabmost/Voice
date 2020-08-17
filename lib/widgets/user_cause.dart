import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_video.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/view_profile_screen.dart';
import '../screens/poll_gallery_screen.dart';
import '../screens/search_results_screen.dart';

class UserCause extends StatelessWidget with ShareContent {
  final DocumentReference reference;
  final String userId;
  final String myId;
  final String userName;
  final String userImage;
  final String title;
  final double goal;
  final bool hasLiked;
  final int likes;
  final int reposts;
  final bool hasSaved;
  final DateTime date;
  final String influencer;
  final List likesList;
  final bool isVideo;
  final List images;
  final String description;

  final Color color = Color(0xFFF0F0F0);

  UserCause({
    this.reference,
    this.userName,
    this.myId,
    this.userImage,
    this.title,
    this.goal,
    this.userId,
    this.likes,
    this.hasLiked,
    this.reposts,
    this.hasSaved,
    this.date,
    @required this.influencer,
    @required this.likesList,
    @required this.isVideo,
    @required this.images,
    @required this.description,
  });

  void _toProfile(context) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
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

  void _options(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _deleteAlert(context),
                leading: new Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('button_delete'),
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
              onTap: () => _toGallery(context, 0),
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
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
                    color: Colors.black,
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

  void _deleteAlert(context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        content: Text('¿Seguro que deseas borrar esta encuesta?'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            child: Text(
              Translations.of(context).text('button_cancel'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(ct).pop();
            },
          ),
          FlatButton(
            textColor: Colors.red,
            child: Text(
              'Borrar',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              _deleteContent();
              Navigator.of(ct).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteContent() async {
    QuerySnapshot snapArray = await Firestore.instance
        .collection('content')
        .where('parent', isEqualTo: reference)
        .getDocuments();

    WriteBatch batch = Firestore.instance.batch();

    batch.delete(reference);
    snapArray.documents.forEach((element) {
      batch.delete(element.reference);
    });

    batch.updateData(Firestore.instance.collection('users').document(myId), {
      'created': FieldValue.arrayRemove([reference.documentID])
    });

    likesList.forEach((element) {
      batch.updateData(
        Firestore.instance.collection('users').document(element),
        {
          'liked': FieldValue.arrayRemove([reference.documentID]),
        },
      );
    });

    batch.commit();
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
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
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
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(userImage),
                ),
                title: Row(
                  children: <Widget>[
                    Text(
                      userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          ],
        ),
      ),
    );
  }
}

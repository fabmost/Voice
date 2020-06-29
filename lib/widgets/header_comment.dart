import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';

class HeaderComment extends StatelessWidget {
  final DocumentReference reference;
  final String userId;

  HeaderComment(this.reference, this.userId);

  void _upVote(hasUp) {
    WriteBatch batch = Firestore.instance.batch();
    if (hasUp) {
      batch.updateData(reference, {
        'up': FieldValue.arrayRemove([userId]),
      });
    } else {
      batch.updateData(reference, {
        'up': FieldValue.arrayUnion([userId]),
        'down': FieldValue.arrayRemove([userId])
      });
    }
    batch.commit();
  }

  void _downVote(hasDown) {
    WriteBatch batch = Firestore.instance.batch();
    if (hasDown) {
      batch.updateData(reference, {
        'down': FieldValue.arrayRemove([userId]),
      });
    } else {
      batch.updateData(reference, {
        'down': FieldValue.arrayUnion([userId]),
        'up': FieldValue.arrayRemove([userId])
      });
    }
    batch.commit();
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

        int ups = 0;
        bool hasUp = false;
        int downs = 0;
        bool hasDown = false;

        if (document['up'] != null) {
          ups = document['up'].length;
          hasUp = document['up'].contains(userId);
        }
        if (document['down'] != null) {
          downs = document['down'].length;
          hasDown = document['down'].contains(userId);
        }

        return Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(document['userImage'] ?? ''),
              ),
              title: Text(document['username']),
              subtitle: Text(document['text']),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(
                    GalupFont.like,
                    color: hasUp ? Theme.of(context).accentColor : Colors.black,
                  ),
                  label: Text(ups == 0 ? '' : '$ups'),
                  onPressed: () => _upVote(hasUp),
                ),
                FlatButton.icon(
                  icon: Icon(
                    GalupFont.dislike,
                    color: hasDown ? Theme.of(context).accentColor : Colors.black,
                  ),
                  label: Text(downs == 0 ? '' : '$downs'),
                  onPressed: () => _downVote(hasDown),
                ),
              ],
            ),
            Divider(),
          ],
        );
      },
    );
  }
}

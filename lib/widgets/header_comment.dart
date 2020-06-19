import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HeaderComment extends StatelessWidget {
  final DocumentReference reference;
  final String userId;

  HeaderComment(this.reference, this.userId);

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
                backgroundImage: NetworkImage(document['userImage']),
              ),
              title: Text(document['username']),
              subtitle: Text(document['text']),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.arrow_upward),
                  label: Text(ups == 0 ? '' : '$ups'),
                  onPressed: null,
                ),
                FlatButton.icon(
                  icon: Icon(Icons.arrow_downward),
                  label: Text(downs == 0 ? '' : '$downs'),
                  onPressed: null,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';

class ViewProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  void _toChat(context, userId) {
    Navigator.of(context)
        .pushNamed(ChatScreen.routeName, arguments: {'userId': userId});
  }

  void _toFollowers() {}

  void _toFollowing() {}

  void _follow(userId, myId, isFollowing) {
    WriteBatch batch = Firestore.instance.batch();
    if (!isFollowing) {
      batch.updateData(
        Firestore.instance.collection('users').document(userId),
        {
          'followers': FieldValue.arrayUnion([myId])
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(myId),
        {
          'following': FieldValue.arrayUnion([userId])
        },
      );
    } else {
      batch.updateData(
        Firestore.instance.collection('users').document(userId),
        {
          'followers': FieldValue.arrayRemove([myId])
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(myId),
        {
          'following': FieldValue.arrayRemove([userId])
        },
      );
    }
    batch.commit();
  }

  Widget _usersWidget(amount, type, action) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: action,
        child: Column(
          children: <Widget>[
            Text(
              '$amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget _followButton(userId, myId, followers) {
    if (followers == null || !followers.contains(myId)) {
      return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: () => _follow(userId, myId, false),
          textColor: Colors.white,
          child: Text('Seguir'),
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: OutlineButton(
        onPressed: () => _follow(userId, myId, true),
        child: Text('Siguiendo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_profile')),
        actions: <Widget>[
          IconButton(
            icon: Icon(GalupFont.message),
            onPressed: () => _toChat(context, profileId),
          )
        ],
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ct, AsyncSnapshot<FirebaseUser> userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(profileId)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final document = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(document['image'] ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${document['name']} ${document['last_name']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      '@${document['user_name']}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      document['bio'] ?? '',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _usersWidget(
                          document['following'] != null
                              ? document['following'].length
                              : 0,
                          Translations.of(context).text('label_following'),
                          _toFollowing,
                        ),
                        _usersWidget(
                          document['followers'] != null
                              ? document['followers'].length
                              : 0,
                          Translations.of(context).text('label_followers'),
                          _toFollowers,
                        ),
                        _followButton(profileId, userSnap.data.uid,
                            document['followers']),
                        SizedBox(width: 16)
                      ],
                    ),
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

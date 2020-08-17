import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'view_profile_screen.dart';
import '../translations.dart';
import '../widgets/influencer_badge.dart';

class FollowingScreen extends StatefulWidget {
  final userId;

  FollowingScreen(this.userId);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  TextEditingController _controller = new TextEditingController();
  List documents;
  bool _isLoading = false;
  String _filter;
  String userId;

  void _toProfile(userId) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.uid != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId)
          .then((value) {
        if (value) {
          _getData();
        }
      });
    }
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseAuth.instance.currentUser();
    userId = user.uid;
    QuerySnapshot usersSnap = await Firestore.instance
        .collection('users')
        .where('followers', arrayContains: widget.userId)
        .orderBy('user_name')
        .getDocuments();
    setState(() {
      documents = usersSnap.documents;
      _isLoading = false;
    });
  }

  void _follow(context, userId, myId, isFollowing) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(context);
      return;
    }
    final userData =
        await Firestore.instance.collection('users').document(userId).get();
    final List creations = userData['created'] ?? [];
    if (userData['reposted'] != null) {
      (userData['reposted'] as List).forEach((element) {
        creations.add(element.values.first);
      });
    }
    WriteBatch batch = Firestore.instance.batch();
    if (!isFollowing) {
      FirebaseMessaging().subscribeToTopic(userId);
      batch.updateData(
        Firestore.instance.collection('users').document(userId),
        {
          'followers': FieldValue.arrayUnion([myId]),
          'followers_count': FieldValue.increment(1)
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(myId),
        {
          'following': FieldValue.arrayUnion([userId])
        },
      );
      creations.forEach((element) {
        batch.updateData(
          Firestore.instance.collection('content').document(element),
          {
            'home': FieldValue.arrayUnion([myId])
          },
        );
      });
    } else {
      FirebaseMessaging().unsubscribeFromTopic(userId);
      batch.updateData(
        Firestore.instance.collection('users').document(userId),
        {
          'followers': FieldValue.arrayRemove([myId]),
          'followers_count': FieldValue.increment(-1)
        },
      );
      batch.updateData(
        Firestore.instance.collection('users').document(myId),
        {
          'following': FieldValue.arrayRemove([userId])
        },
      );
      creations.forEach((element) {
        batch.updateData(
          Firestore.instance.collection('content').document(element),
          {
            'home': FieldValue.arrayRemove([myId])
          },
        );
      });
    }
    await batch.commit();
    _getData();
  }

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

  @override
  void initState() {
    super.initState();
    _getData();
    _controller.addListener(() {
      setState(() {
        _filter = _controller.text;
      });
    });
  }

  Widget _userTile(doc) {
    return ListTile(
      onTap: () => _toProfile(doc.documentID),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(doc['image'] ?? ''),
      ),
      title: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '${doc['name']} ${doc['last_name']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(doc['influencer'] ?? '', 16),
        ],
      ),
      subtitle: Text('@${doc['user_name']}'),
      trailing: _followButton(doc.documentID, doc['followers']),
    );
  }

  Widget _followButton(profileId, followers) {
    if (profileId == userId) {
      return Text('');
    }
    if (followers == null || !followers.contains(userId)) {
      return RaisedButton(
        onPressed: () => _follow(context, profileId, userId, false),
        textColor: Colors.white,
        child: Text('Seguir'),
      );
    }
    return OutlineButton(
      onPressed: () => _follow(context, profileId, userId, true),
      child: Text('Siguiendo'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('label_following')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (documents.isEmpty)
              ? Center(
                  child: Text(Translations.of(context).text('empty_following')),
                )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText:
                                Translations.of(context).text('hint_search')),
                        controller: _controller,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (ctx, i) {
                          final doc = documents[i];

                          return _filter == null || _filter == ""
                              ? Column(
                                  children: <Widget>[
                                    _userTile(doc),
                                    Divider(),
                                  ],
                                )
                              : doc['user_name']
                                      .toLowerCase()
                                      .contains(_filter.toLowerCase())
                                  ? _userTile(doc)
                                  : Container();
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

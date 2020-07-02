import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'chat_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';

import '../widgets/poll_list.dart';
import '../widgets/challenge_list.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';

class ViewProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  void _toChat(context, userId) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(context);
      return;
    }
    Navigator.of(context)
        .pushNamed(ChatScreen.routeName, arguments: {'userId': userId});
  }

  void _toFollowers(context, id) {
    Navigator.of(context).pushNamed(FollowersScreen.routeName, arguments: id);
  }

  void _toFollowing(context, id) {
    Navigator.of(context).pushNamed(FollowingScreen.routeName, arguments: id);
  }

  void _follow(context, userId, myId, isFollowing) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(context);
      return;
    }
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

  Widget _usersWidget(amount, type, action) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: action,
        child: Column(
          children: <Widget>[
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget _followButton(context, userId, myId, followers) {
    if (followers == null || !followers.contains(myId)) {
      return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: () => _follow(context, userId, myId, false),
          textColor: Colors.white,
          child: Text('Seguir'),
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: OutlineButton(
        onPressed: () => _follow(context, userId, myId, true),
        child: Text('Siguiendo'),
      ),
    );
  }

  Widget _newHeader(context, profileId) {
    return FutureBuilder(
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
            return Container(
              //padding: new EdgeInsets.only(top: statuBar + 50),
              color: Colors.white,
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
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '@${document['user_name']}',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if ((document['tiktok'] ?? '').toString().isNotEmpty)
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            GalupFont.tik_tok,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      SizedBox(width: 8),
                      if ((document['facebook'] ?? '').toString().isNotEmpty)
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            GalupFont.facebook,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      SizedBox(width: 8),
                      if ((document['instagram'] ?? '').toString().isNotEmpty)
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            GalupFont.instagram,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _usersWidget(
                        document['following'] != null
                            ? document['following'].length
                            : 0,
                        Translations.of(context).text('label_following'),
                        () => _toFollowing(context, profileId),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey,
                        height: 32,
                      ),
                      _usersWidget(
                        document['followers'] != null
                            ? document['followers'].length
                            : 0,
                        Translations.of(context).text('label_followers'),
                        () => _toFollowers(context, profileId),
                      ),
                      _followButton(
                        context,
                        profileId,
                        userSnap.data.uid,
                        document['followers'],
                      ),
                      SizedBox(width: 16)
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ModalRoute.of(context).settings.arguments as String;
    //final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, isScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                title: Text(Translations.of(context).text('title_profile')),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(GalupFont.message),
                    onPressed: () => _toChat(context, profileId),
                  ),
                  //_header(context, profileId),
                ],
                //flexibleSpace: _header(context, statusBarHeight, profileId),
              ),
              SliverPersistentHeader(
                pinned: false,
                delegate: _SliverHeaderDelegate(
                  360,
                  360,
                  _newHeader(context, profileId),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(context).accentColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 52),
                    tabs: [
                      Tab(icon: Icon(GalupFont.survey)),
                      Tab(icon: Icon(GalupFont.challenge)),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              PollList(profileId),
              ChallengeList(profileId),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate(
    this.minHeight,
    this.maxHeight,
    this.child,
  );

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return false;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Divider(
            indent: 0,
            endIndent: 0,
            height: 1,
            color: Colors.grey,
          ),
          _tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

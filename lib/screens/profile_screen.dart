import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';

import '../custom/galup_font_icons.dart';
import '../widgets/poll_list.dart';
import '../widgets/challenge_list.dart';
import '../translations.dart';

class ProfileScreen extends StatelessWidget {
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _toFollowers(context, id) {
    Navigator.of(context).pushNamed(FollowersScreen.routeName, arguments: id);
  }

  void _toFollowing(context, id) {
    Navigator.of(context).pushNamed(FollowingScreen.routeName, arguments: id);
  }

  void _toEdit(context) {
    Navigator.of(context).pushNamed(EditProfileScreen.routeName);
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

  Widget _anonymousView(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_profile')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.person,
              color: Theme.of(context).accentColor,
              size: 120,
            ),
            SizedBox(height: 22),
            Text(
              'Registrate para tener un perfil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 22),
            Container(
              height: 42,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: RaisedButton(
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
                child: Text('Registrarse'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _header(context, userId) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection('users').document(userId).snapshots(),
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
                    () => _toFollowing(context, userId),
                  ),
                  _usersWidget(
                    document['followers'] != null
                        ? document['followers'].length
                        : 0,
                    Translations.of(context).text('label_followers'),
                    () => _toFollowers(context, userId),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ct, AsyncSnapshot<FirebaseUser> userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (userSnap.data.isAnonymous) {
          return _anonymousView(context);
        }
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
                        icon: Icon(Icons.edit),
                        onPressed: () => _toEdit(context),
                      )
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _SliverHeaderDelegate(
                      350,
                      350,
                      _header(context, userSnap.data.uid),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).accentColor,
                        unselectedLabelColor: Colors.grey,
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
                  PollList(userSnap.data.uid),
                  ChallengeList(userSnap.data.uid),
                ],
              ),
            ),
          ),
        );
      },
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
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_screen.dart';
import 'chat_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';

import '../widgets/poll_list.dart';
import '../widgets/challenge_list.dart';
import '../widgets/influencer_badge.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';

class ViewProfileScreen extends StatelessWidget with ShareContent {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          id,
        ),
      ),
    );
  }

  void _toFollowing(context, id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingScreen(
          id,
        ),
      ),
    );
  }

  void _menu(context, userId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                Translations.of(context).text('button_share_profile'),
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => shareProfile(userId),
            ),
            SimpleDialogOption(
              child: Text(
                Translations.of(context).text('button_block'),
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onPressed: () => _blockUser(context, userId),
            ),
            SimpleDialogOption(
              child: Text(
                Translations.of(context).text('button_cancel'),
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _blockUser(context, userId) async {
    Navigator.of(context).pop();
    bool willClose = false;
    await showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_block')),
        content: Text(Translations.of(context).text('dialog_block_content')),
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
              Translations.of(context).text('button_block'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              willClose = true;
              Navigator.of(ct).pop();
            },
          ),
        ],
      ),
    );
    if (willClose) _blockContent(context, userId);
  }

  void _blockContent(context, userId) async {
    final myUser = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(userId).get();

    WriteBatch batch = Firestore.instance.batch();
    final List creations = userData['created'] ?? [];
    if (userData['reposted'] != null) {
      (userData['reposted'] as List).forEach((element) {
        creations.add(element.values.first);
      });
    }
    batch.updateData(
      Firestore.instance.collection('users').document(userId),
      {
        'followers': FieldValue.arrayRemove([myUser.uid])
      },
    );
    batch.updateData(
      Firestore.instance.collection('users').document(myUser.uid),
      {
        'following': FieldValue.arrayRemove([userId])
      },
    );
    creations.forEach((element) {
      batch.updateData(
        Firestore.instance.collection('content').document(element),
        {
          'home': FieldValue.arrayRemove([myUser.uid]),
          'flag': FieldValue.arrayUnion([myUser.uid])
        },
      );
    });
    await batch.commit();
    Navigator.of(context).pop();
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
          'followers': FieldValue.arrayUnion([myId])
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
          'followers': FieldValue.arrayRemove([myId])
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

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
            final screenWidth = MediaQuery.of(context).size.width;
            final containerHeight = (screenWidth * 8) / 25;
            return Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    height: containerHeight + 60,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: containerHeight,
                          decoration: BoxDecoration(
                            color: Color(0xFFECECEC),
                            image: document['cover'] != null
                                ? DecorationImage(
                                    image: NetworkImage(document['cover']),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                NetworkImage(document['image'] ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${document['name']} ${document['last_name']}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      InfluencerBadge(document['influencer'] ?? '', 20),
                    ],
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
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AutoSizeText(
                      document['bio'] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if ((document['tiktok'] ?? '').toString().isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchURL(
                              'https://www.tiktok.com/${document['tiktok'].replaceAll('@', '')}'),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              GalupFont.tik_tok,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      if ((document['facebook'] ?? '').toString().isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchURL(
                              'https://www.facebook.com/${document['facebook'].replaceAll('@', '')}'),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              GalupFont.facebook,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      if ((document['instagram'] ?? '').toString().isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchURL(
                              'https://www.instagram.com/${document['instagram'].replaceAll('@', '')}'),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              GalupFont.instagram,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      if ((document['youtube'] ?? '').toString().isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchURL(
                              'https://www.youtube.com/c/${document['youtube']}'),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              GalupFont.youtube,
                              color: Colors.white,
                              size: 20,
                            ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 8) / 25;
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
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () => _menu(context, profileId),
                  ),
                  //_header(context, profileId),
                ],
                //flexibleSpace: _header(context, statusBarHeight, profileId),
              ),
              SliverPersistentHeader(
                pinned: false,
                delegate: _SliverHeaderDelegate(
                  378 + containerHeight - 70,
                  378 + containerHeight - 70,
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
                      Tab(
                        icon: Icon(GalupFont.survey),
                        text: 'Encuestas',
                      ),
                      Tab(
                        icon: Icon(GalupFont.challenge),
                        text: 'Retos',
                      ),
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

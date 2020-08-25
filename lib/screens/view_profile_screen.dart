import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/models/user_model.dart';

import 'auth_screen.dart';
import 'chat_screen.dart';

import '../providers/user_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/poll_list.dart';
import '../widgets/challenge_list.dart';
import '../widgets/tip_list.dart';
import '../widgets/influencer_badge.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';

class ViewProfileScreen extends StatelessWidget with ShareContent {
  static const routeName = '/profile';
  final ScrollController _scrollController = new ScrollController();

  void _toChat(context, userId) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      _anonymousAlert(context);
      return;
    }
    Navigator.of(context)
        .pushNamed(ChatScreen.routeName, arguments: {'userId': userId});
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
  Widget build(BuildContext context) {
    final profileId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: Provider.of<UserProvider>(context).getProfile(profileId),
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          UserModel user = snapshot.data;
          bool hasSocialMedia = false;

          double containerHeight = 420;
          if (user.biography != null && user.biography.isNotEmpty) {
            containerHeight += 66;
          }
          if ((user.tiktok ?? '').isNotEmpty ||
              (user.facebook ?? '').isNotEmpty ||
              (user.instagram ?? '').isNotEmpty ||
              (user.youtube ?? '').isNotEmpty) {
            hasSocialMedia = true;
            containerHeight += 60;
          }
          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (ctx, isScrolled) {
                return <Widget>[
                  SliverAppBar(
                    pinned: true,
                    title: Text(Translations.of(context).text('title_profile')),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(GalupFont.message),
                        onPressed: () => _toChat(context, user.hash),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => _menu(context, profileId),
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _SliverHeaderDelegate(
                      containerHeight,
                      containerHeight,
                      ProfileHeader(
                        hasSocialMedia: hasSocialMedia,
                        user: user,
                      ),
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
                          Tab(
                            icon: Icon(GalupFont.tips),
                            text: 'Tips',
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
                  PollList(profileId, _scrollController),
                  ChallengeList(profileId, _scrollController),
                  TipList(profileId, _scrollController, null),
                ],
              ),
            ),
          );
        },
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/models/user_model.dart';

import 'auth_screen.dart';
import 'chat_screen.dart';
import '../providers/user_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/promo_poll_list.dart';
import '../widgets/private_poll_list.dart';
import '../widgets/poll_list.dart';
import '../widgets/tip_list.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';

class ViewProfileScreen extends StatelessWidget with ShareContent {
  static const routeName = '/profile';
  final ScrollController _scrollController = new ScrollController();

  void _toChat(context, userHash) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      _anonymousAlert(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userHash: userHash,
        ),
      ),
    );
  }

  void _menu(context, userId, image) {
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
              onPressed: () => shareProfile(context, userId, image),
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

          double containerHeight = 410;
          if (user.biography != null && user.biography.isNotEmpty) {
            containerHeight += 26;
          }
          if ((user.tiktok ?? '').isNotEmpty ||
              (user.facebook ?? '').isNotEmpty ||
              (user.instagram ?? '').isNotEmpty ||
              (user.twitter ?? '').isNotEmpty ||
              (user.linkedin ?? '').isNotEmpty ||
              (user.youtube ?? '').isNotEmpty) {
            hasSocialMedia = true;
            containerHeight += 50;
          }
          return DefaultTabController(
            length: 4,
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
                          onPressed: () =>
                              _menu(context, profileId, user.icon)),
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
                        isScrollable: true,
                        labelColor: Theme.of(context).accentColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 22),
                        tabs: [
                          Tab(
                            icon: Icon(GalupFont.survey),
                            text: 'Encuestas',
                          ),
                          Tab(
                            icon: Icon(GalupFont
                                .icono_encuesta_grupal_mesa_de_trabajo_1),
                            text: 'Encuestas\nGrupales',
                          ),
                          Tab(
                            icon: Icon(GalupFont.encuesta_patrocinada),
                            text: 'Encuestas\nPublicitarias',
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
                  PollList(user.userName, _scrollController),
                  PrivatePollList(user.userName, _scrollController),
                  PromoPollList(user.userName, _scrollController),
                  TipList(user.userName, _scrollController, null),
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
  double get minExtent => _tabBar.preferredSize.height + 9;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 9;

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
          const SizedBox(height: 8),
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

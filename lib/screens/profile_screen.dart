import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'auth_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/poll_user_list.dart';
import '../widgets/challenge_user_list.dart';
import '../widgets/tip_user_list.dart';
import '../widgets/cause_user_list.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final Function stopVideo;

  ProfileScreen({Key key, this.stopVideo}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = new ScrollController();
  VideoPlayerController _controller;

  void _toEdit(context) {
    Navigator.of(context).pushNamed(EditProfileScreen.routeName);
  }

  void _playVideo(VideoPlayerController controller) {
    if (_controller != null) {
      _controller.pause();
    }
    _controller = controller;
    widget.stopVideo(_controller);
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
              textAlign: TextAlign.center,
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
            ),
            SizedBox(height: 22),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(Translations.of(context).text('label_have_account')),
                  SizedBox(width: 8),
                  Text(
                    Translations.of(context).text('button_login'),
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.getUser == null) {
            return _anonymousView(context);
          }
          if (provider.getUserModel == null) {
            provider.userProfile();
            return Center(child: CircularProgressIndicator());
          }
          bool hasSocialMedia = false;

          double containerHeight = 410;
          if (provider.getUserModel.biography != null &&
              provider.getUserModel.biography.isNotEmpty) {
            containerHeight += 66;
          }
          if ((provider.getUserModel.tiktok ?? '').isNotEmpty ||
              (provider.getUserModel.facebook ?? '').isNotEmpty ||
              (provider.getUserModel.instagram ?? '').isNotEmpty ||
              (provider.getUserModel.twitter ?? '').isNotEmpty ||
              (provider.getUserModel.youtube ?? '').isNotEmpty) {
            hasSocialMedia = true;
            containerHeight += 60;
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
                      FlatButton(
                        textColor: Colors.white,
                        child: Text(Translations.of(context)
                            .text('button_edit_profile')),
                        onPressed: () => _toEdit(context),
                      )
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _SliverHeaderDelegate(
                      containerHeight,
                      containerHeight,
                      UserProfileHeader(
                        hasSocialMedia: hasSocialMedia,
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).accentColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 22),
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
                          Tab(
                            icon: Icon(GalupFont.cause),
                            text: 'Causas',
                          ),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: child,
            ),
          );
        },
        child: TabBarView(
          children: [
            PollUserList(
              _scrollController,
              _playVideo,
            ),
            ChallengeUserList(
              _scrollController,
              _playVideo,
            ),
            TipUserList(
              _scrollController,
              _playVideo,
            ),
            CauseUserList(
              _scrollController,
            ),
          ],
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
  double get minExtent => minHeight + 4;
  @override
  double get maxExtent => maxHeight + 4;

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

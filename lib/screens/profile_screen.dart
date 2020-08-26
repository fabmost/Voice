import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'auth_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'poll_gallery_screen.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../widgets/app_drawer.dart';
import '../widgets/poll_user_list.dart';
import '../widgets/challenge_user_list.dart';
import '../widgets/tip_user_list.dart';
import '../widgets/cause_user_list.dart';
import '../widgets/influencer_badge.dart';

class ProfileScreen extends StatelessWidget {
  final Function stopVideo;
  VideoPlayerController _controller;

  ProfileScreen({Key key, this.stopVideo}) : super(key: key);

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

  void _toEdit(context) {
    Navigator.of(context).pushNamed(EditProfileScreen.routeName);
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toGallery(context, image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: null,
          galleryItems: [image],
          initialIndex: 0,
        ),
      ),
    );
  }

  void _playVideo(VideoPlayerController controller) {
    if (_controller != null) {
      _controller.pause();
    }
    _controller = controller;
    stopVideo(_controller);
  }

  void _imageOptions(context, isProfile) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                onTap: () => _openCamera(context, isProfile),
                leading: new Icon(
                  Icons.camera_alt,
                ),
                title: Text("Cámara"),
              ),
              new ListTile(
                onTap: () => _openGallery(context, isProfile),
                leading: new Icon(
                  Icons.image,
                ),
                title: Text("Galería"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCamera(context, isProfile) {
    Navigator.of(context).pop();
    _takePicture(isProfile);
  }

  void _openGallery(context, isProfile) {
    Navigator.of(context).pop();
    _getPicture(isProfile);
  }

  Future<void> _takePicture(isProfile) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path, isProfile);
    }
  }

  Future<void> _getPicture(isProfile) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path, isProfile);
    }
  }

  void _cropImage(pathFile, isProfile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: isProfile
          ? CropAspectRatio(ratioX: 1, ratioY: 1)
          : CropAspectRatio(ratioX: 16, ratioY: 9),
    );
    if (cropped != null) {
      _saveCover(cropped, isProfile);
    }
  }

  void _saveCover(file, isProfile) async {
    final user = await FirebaseAuth.instance.currentUser();
    StorageReference ref;

    if (isProfile) {
      ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(user.uid + '.jpg');
    } else {
      ref = FirebaseStorage.instance
          .ref()
          .child('user_covers')
          .child(user.uid + '.jpg');
    }

    await ref.putFile(file).onComplete;

    final url = await ref.getDownloadURL();

    WriteBatch batch = Firestore.instance.batch();
    if (isProfile) {
      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {'image': url},
      );

      batch.updateData(
        Firestore.instance.collection('hash').document(user.uid),
        {'user_image': url},
      );
    } else {
      batch.updateData(
        Firestore.instance.collection('users').document(user.uid),
        {'cover': url},
      );
    }

    await batch.commit();
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

  Widget _header(context, userId) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection('users').document(userId).snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final document = snapshot.data;
        final screenWidth = MediaQuery.of(context).size.width;
        final containerHeight = (screenWidth * 9) / 16;
        return Column(
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
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 8,
                        top: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () => _imageOptions(context, false),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 122,
                      width: 122,
                      child: Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () =>  document['image'] == null ? null : _toGallery(context, document['image']),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(document['image'] ?? ''),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _imageOptions(context, true),
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 15,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
            if (document['bio'] != null && document['bio'].isNotEmpty)
              SizedBox(height: 16),
            Container(
              height: 50,
              child: AutoSizeText(
                document['bio'] ?? '',
                textAlign: TextAlign.center,
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
                GestureDetector(
                  onTap: () => (document['tiktok'] ?? '').toString().isNotEmpty
                      ? _launchURL(
                          'https://www.tiktok.com/${document['tiktok']}')
                      : null,
                  child: CircleAvatar(
                    backgroundColor:
                        (document['tiktok'] ?? '').toString().isEmpty
                            ? Colors.grey
                            : Colors.black,
                    child: Icon(
                      GalupFont.tik_tok,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => (document['facebook'] ?? '')
                          .toString()
                          .isNotEmpty
                      ? _launchURL(
                          'https://www.facebook.com/${document['facebook'].replaceAll('@', '')}')
                      : null,
                  child: CircleAvatar(
                    backgroundColor:
                        (document['facebook'] ?? '').toString().isEmpty
                            ? Colors.grey
                            : Colors.black,
                    child: Icon(
                      GalupFont.facebook,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => (document['instagram'] ?? '')
                          .toString()
                          .isNotEmpty
                      ? _launchURL(
                          'https://www.instagram.com/${document['instagram'].replaceAll('@', '')}')
                      : null,
                  child: CircleAvatar(
                    backgroundColor:
                        (document['instagram'] ?? '').toString().isEmpty
                            ? Colors.grey
                            : Colors.black,
                    child: Icon(
                      GalupFont.instagram,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => (document['youtube'] ?? '').toString().isNotEmpty
                      ? _launchURL(
                          'https://www.youtube.com/c/${document['youtube']}')
                      : null,
                  child: CircleAvatar(
                    backgroundColor:
                        (document['youtube'] ?? '').toString().isEmpty
                            ? Colors.grey
                            : Colors.black,
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
                  () => _toFollowing(context, userId),
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
                  () => _toFollowers(context, userId),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 8) / 25;
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
          drawer: AppDrawer(),
          body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
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
                      465 + containerHeight - 80,
                      465 + containerHeight - 80,
                      _header(context, userSnap.data.uid),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).accentColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 32),
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
              body: TabBarView(
                children: [
                  PollUserList(userSnap.data.uid, _playVideo),
                  ChallengeUserList(userSnap.data.uid),
                  TipUserList(userSnap.data.uid),
                  CauseUserList(userSnap.data.uid),
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

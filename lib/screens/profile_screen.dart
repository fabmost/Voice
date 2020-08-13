import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
import '../widgets/saved_list.dart';
import '../widgets/influencer_badge.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  final Function stopVideo;
  VideoPlayerController _controller;

  ProfileScreen({Key key, this.stopVideo}) : super(key: key);

  void _toEdit(context) {
    Navigator.of(context).pushNamed(EditProfileScreen.routeName);
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
          : CropAspectRatio(ratioX: 25, ratioY: 8),
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

    if (isProfile) {
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData(
        {'image': url},
      );
    } else {
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData(
        {'cover': url},
      );
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.getUser == null) {
            return _anonymousView(context);
          }
          return FutureBuilder(
            future: provider.userProfile(),
            builder: (context, AsyncSnapshot<UserModel> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              UserModel user = snapshot.data;
              bool hasSocialMedia = false;

              double containerHeight = 410;
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
                  headerSliverBuilder: (ctx, isScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        pinned: true,
                        title: Text(
                            Translations.of(context).text('title_profile')),
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
                            user: user,
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            labelColor: Theme.of(context).accentColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorPadding:
                                EdgeInsets.symmetric(horizontal: 42),
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
                                icon: Icon(GalupFont.saved),
                                text: 'Guardados',
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
                      PollUserList(user.userName, _playVideo),
                      ChallengeUserList(user.userName),
                      SavedList(_playVideo),
                    ],
                  ),
                ),
              );
            },
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

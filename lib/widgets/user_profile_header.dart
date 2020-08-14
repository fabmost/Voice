import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voice_inc/providers/content_provider.dart';
import 'package:voice_inc/providers/user_provider.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../models/user_model.dart';
import '../screens/followers_screen.dart';
import '../screens/following_screen.dart';

class UserProfileHeader extends StatelessWidget {
  final bool hasSocialMedia;
  final UserModel user;

  UserProfileHeader({this.hasSocialMedia, this.user});

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toFollowers(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          user.userName,
        ),
      ),
    );
  }

  void _toFollowing(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingScreen(
          user.userName,
        ),
      ),
    );
  }

  void _imageOptions(context, isProfile) {
    //FocusScope.of(context).requestFocus(FocusNode());
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
    _takePicture(context, isProfile);
  }

  void _openGallery(context, isProfile) {
    Navigator.of(context).pop();
    _getPicture(context, isProfile);
  }

  Future<void> _takePicture(context, isProfile) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path, isProfile);
    }
  }

  Future<void> _getPicture(context, isProfile) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path, isProfile);
    }
  }

  void _cropImage(context, pathFile, isProfile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: isProfile
          ? CropAspectRatio(ratioX: 1, ratioY: 1)
          : CropAspectRatio(ratioX: 16, ratioY: 9),
    );
    if (cropped != null) {
      _saveImage(context, cropped, isProfile);
    }
  }

  void _saveImage(context, file, isProfile) async {
    String idResource =
        await Provider.of<ContentProvider>(context, listen: false)
            .uploadResourceGetUrl(
      file.path,
      'I',
      'U',
    );

    await Provider.of<UserProvider>(context, listen: false)
        .editProfile(cover: idResource);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 9) / 16;
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
                    image: DecorationImage(
                        image: user.cover == null
                            ? null
                            : NetworkImage(user.cover),
                        fit: BoxFit.cover),
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
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: user.icon == null
                              ? null
                              : NetworkImage(user.icon),
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
                '${user.name} ${user.lastName}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 8),
              //InfluencerBadge(document['influencer'] ?? '', 20),
            ],
          ),
          Text(
            '@${user.userName}',
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          if (user.biography != null && user.biography.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AutoSizeText(
                user.biography,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          if (user.biography != null && user.biography.isNotEmpty)
            SizedBox(height: 16),
          if (hasSocialMedia)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if ((user.tiktok ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.tiktok.com/${user.tiktok.replaceAll('@', '')}'),
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
                if ((user.facebook ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.facebook.com/${user.facebook.replaceAll('@', '')}'),
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
                if ((user.instagram ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.instagram.com/${user.instagram.replaceAll('@', '')}'),
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
                if ((user.youtube ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        _launchURL('https://www.youtube.com/c/${user.youtube}'),
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
          if (hasSocialMedia) SizedBox(height: 16),
          Row(
            children: <Widget>[
              _usersWidget(
                user.following,
                Translations.of(context).text('label_following'),
                () => _toFollowing(context),
              ),
              Container(
                width: 1,
                color: Colors.grey,
                height: 32,
              ),
              _usersWidget(
                user.followers,
                Translations.of(context).text('label_followers'),
                () => _toFollowers(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../screens/poll_gallery_screen.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class UserIcon extends StatefulWidget {
  final String url;

  UserIcon(this.url);

  @override
  _UserIconState createState() => _UserIconState();
}

class _UserIconState extends State<UserIcon> {
  String _url;
  bool _isLoading = false;

  void _openImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: null,
          galleryItems: [widget.url],
          initialIndex: 0,
        ),
      ),
    );
  }

  void _imageOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                onTap: () => _openCamera(context),
                leading: new Icon(
                  Icons.camera_alt,
                ),
                title: Text("Cámara"),
              ),
              new ListTile(
                onTap: () => _openGallery(context),
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

  void _openCamera(context) {
    Navigator.of(context).pop();
    _takePicture(context);
  }

  void _openGallery(context) {
    Navigator.of(context).pop();
    _getPicture(context);
  }

  Future<void> _takePicture(context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path);
    }
  }

  Future<void> _getPicture(context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path);
    }
  }

  void _cropImage(context, pathFile) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: pathFile,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
    if (cropped != null) {
      _saveImage(context, cropped);
    }
  }

  void _saveImage(context, file) async {
    setState(() {
      _isLoading = true;
    });
    String idResource =
        await Provider.of<ContentProvider>(context, listen: false)
            .uploadResourceGetUrl(
      file.path,
      'I',
      'U',
    );

    await Provider.of<UserProvider>(context, listen: false)
        .editProfile(icon: idResource);

    setState(() {
      _isLoading = false;
      _url = idResource;
    });
  }

  @override
  void initState() {
    _url = widget.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: _url == null ? null : _openImage,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _url == null ? null : NetworkImage(_url),
          ),
        ),
        if (_isLoading) Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _imageOptions(context),
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
    );
  }
}

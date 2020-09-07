import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class UserCover extends StatefulWidget {
  final String url;

  UserCover(this.url);

  @override
  _UserCoverState createState() => _UserCoverState();
}

class _UserCoverState extends State<UserCover> {
  String _url;
  bool _isLoading = false;

  void _imageOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _openCamera(context),
                leading: Icon(
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
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path);
    }
  }

  Future<void> _getPicture(context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(context, imageFile.path);
    }
  }

  void _cropImage(context, pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
    );
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
        .editProfile(cover: idResource);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 9) / 16;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: containerHeight,
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
            image:  _url == null ? null : DecorationImage(
                image: NetworkImage(_url),
                fit: BoxFit.cover),
          ),
        ),
        if (_isLoading) Center(child: CircularProgressIndicator()),
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
              onPressed: () => _imageOptions(context),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class SignUpIconScreen extends StatefulWidget {
  static const String routeName = '/sign-up-icon';

  @override
  _SignUpIconScreenState createState() => _SignUpIconScreenState();
}

class _SignUpIconScreenState extends State<SignUpIconScreen> {
  bool _isLoading = false;

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
    Map idResource =
        await Provider.of<ContentProvider>(context, listen: false)
            .uploadResourceGetUrl(
      file.path,
      'I',
      'U',
    );

    await Provider.of<UserProvider>(context, listen: false)
        .editProfile(icon: idResource['url']);

    setState(() {
      _isLoading = false;
      //_url = idResource;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Omitir'),
          )
        ],
      ),
      body: Column(
        children: [
          Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'Queremos conocerte más, sube tu foto de perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 42),
          Stack(
            children: [
              Image.asset('assets/background.png'),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 52),
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 68,
                        child: Icon(
                          Icons.person,
                          size: 120,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _isLoading ? null : _imageOptions(context),
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
            ],
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}

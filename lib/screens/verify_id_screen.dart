import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class VerifyIdScreen extends StatefulWidget {
  static const routeName = '/verify-id';

  @override
  _VerifyIdScreenState createState() => _VerifyIdScreenState();
}

class _VerifyIdScreenState extends State<VerifyIdScreen> {
  bool _isLoading = false;
  String type;
  String category;
  File _imageFile;

  void _imageOptions() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                onTap: () => _openCamera(),
                leading: new Icon(
                  Icons.camera_alt,
                ),
                title: Text("Cámara"),
              ),
              new ListTile(
                onTap: () => _openGallery(),
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

  void _openCamera() {
    Navigator.of(context).pop();
    _takePicture();
  }

  void _openGallery() {
    Navigator.of(context).pop();
    _getPicture();
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (imageFile != null) {
      /*
      final appDir = await provider.getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      */
      _cropImage(imageFile.path);
    }
  }

  Future<void> _getPicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path);
    }
  }

  void _cropImage(pathFile) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: pathFile,
        aspectRatio: CropAspectRatio(ratioX: 1.14, ratioY: 1));
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  void _save() async {
    setState(() {
      _isLoading = true;
    });

    String idResource =
        await Provider.of<ContentProvider>(context, listen: false)
            .uploadResourceGetUrl(
      _imageFile.path,
      'I',
      'U',
    );

    await Provider.of<UserProvider>(context, listen: false).verifyUser(
      type: type,
      idCategory: category,
      idResource: idResource,
    );

    _showAlert();
    setState(() {
      _isLoading = false;
    });
  }

  void _showAlert() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Hemos recibido tu solicitud y en breve con comunicaremos contigo'),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context)
                  .popUntil(ModalRoute.withName('/'));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    type = args['type'];
    category = args['category'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Identificación',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Toma una foto de tu identificación oficial',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Expanded(flex: 1, child: Container()),
            AspectRatio(
              aspectRatio: 1.4 / 1,
              child: InkWell(
                onTap: _imageOptions,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile),
                              fit: BoxFit.cover,
                            )
                          : null),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_a_photo,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    height: 42,
                    child: RaisedButton(
                      textColor: Colors.white,
                      child: Text(
                          Translations.of(context).text('button_continue')),
                      onPressed: _imageFile == null ? null : _save,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

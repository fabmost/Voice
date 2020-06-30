import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NewChallengeScreen extends StatefulWidget {
  static const routeName = '/new-challenge';

  @override
  _NewChallengeScreenState createState() => _NewChallengeScreenState();
}

class _NewChallengeScreenState extends State<NewChallengeScreen> {
  bool _isLoading = false;
  String metric = 'Likes';
  double goal = 0;
  TextEditingController _titleController = TextEditingController();
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
    final imageFile = await ImagePicker.pickImage(
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
    final imageFile = await ImagePicker.pickImage(
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
    );
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  void _metricSelected() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Selecciona el tipo de meta'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Likes',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Likes'),
            ),
            SimpleDialogOption(
              child: Text(
                'Comentarios',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Comentarios'),
            ),
            SimpleDialogOption(
              child: Text(
                'Regalups',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Regalups'),
            ),
          ],
        );
      },
    );
  }

  void _optionSelected(value) {
    Navigator.of(context).pop();
    setState(() {
      metric = value;
    });
  }

  void _validate() {
    if (_titleController.text.isNotEmpty && _imageFile != null && goal > 0) {
      _saveChallenge();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debes llenar todos los campos'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _saveChallenge() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    WriteBatch batch = Firestore.instance.batch();
    String challengeId =
        Firestore.instance.collection('content').document().documentID;

    final ref = FirebaseStorage.instance
        .ref()
        .child('challenges')
        .child(challengeId + '.jpg');

    await ref.putFile(_imageFile).onComplete;

    final url = await ref.getDownloadURL();
    batch.updateData(
      Firestore.instance.collection('users').document(user.uid),
      {
        'created': FieldValue.arrayUnion([challengeId])
      },
    );

    batch.setData(
        Firestore.instance.collection('content').document(challengeId), {
      'type': 'challenge',
      'title': _titleController.text,
      'user_name': userData['user_name'],
      'user_id': user.uid,
      'user_image': userData['image'],
      'createdAt': Timestamp.now(),
      'images': [url],
      'metric_type': metric.toLowerCase(),
      'metric_goal': goal,
      'comments': 0,
      'endDate': Timestamp.now(),
      'category': 'Política',
      'tags': ['test', 'politica', 'algomas'],
      'interactions': 0,
    });
    await batch.commit();
    Navigator.of(context).pop();
  }

  Widget _title(text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                autofocus: true,
                maxLines: null,
                maxLength: 120,
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Has tu reto',
                ),
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 16),
              _title('Imágen a revelar'),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  child: RawMaterialButton(
                    onPressed: () => _imageOptions(),
                    child: _imageFile != null
                        ? Image.file(_imageFile)
                        : Icon(
                            Icons.camera_alt,
                          ),
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _title('Meta a cumplir'),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Slider(
                      activeColor: Color(0xFFA4175D),
                      value: goal,
                      onChanged: (newValue) {
                        setState(() {
                          goal = newValue;
                        });
                      },
                      min: 0,
                      max: 10000,
                      divisions: 4,
                      label: '${NumberFormat.compact().format(goal)}',
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: _metricSelected,
                    child: Container(
                      height: 42,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: <Widget>[
                          Text(metric),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 42,
                      child: RaisedButton(
                        color: Color(0xFFA4175D),
                        textColor: Colors.white,
                        child: Text('Guardar'),
                        onPressed: () => _validate(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

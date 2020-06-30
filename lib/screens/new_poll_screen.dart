import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../custom/galup_font_icons.dart';

class NewPollScreen extends StatefulWidget {
  static const routeName = '/new-poll';

  @override
  _NewPollScreenState createState() => _NewPollScreenState();
}

class _NewPollScreenState extends State<NewPollScreen> {
  bool _isLoading = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _secondController = TextEditingController();
  TextEditingController _thirdController = TextEditingController();

  bool moreOptions = false;
  File _option1, _option2, _option3;

  void _imageOptions(file) {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                onTap: ()=> _openCamera(file),
                leading: new Icon(
                  Icons.camera_alt,
                ),
                title: Text("Cámara"),
              ),
              new ListTile(
                onTap: ()=> _openGallery(file),
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

  void _openCamera(file) {
    Navigator.of(context).pop();
    _takePicture(file);
  }

  void _openGallery(file) {
    Navigator.of(context).pop();
    _getPicture(file);
  }

  Future<void> _takePicture(file) async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile != null) {
      /*
      final appDir = await provider.getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      */
      _cropImage(file, imageFile.path);
    }
  }

  Future<void> _getPicture(file) async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(file,imageFile.path);
    }
  }

  void _cropImage(file, pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (cropped != null) {
      setState(() {
        file = cropped;
      });
    }
  }

  void _addOption() {
    setState(() {
      moreOptions = !moreOptions;
    });
  }

  void _selectDuration() {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text('Selecciona una duración'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Infinito',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(0),
            ),
            SimpleDialogOption(
              child: Text(
                '1 mes',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(1),
            ),
            SimpleDialogOption(
              child: Text(
                '3 meses',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(2),
            ),
            SimpleDialogOption(
              child: Text(
                '6 meses',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(3),
            ),
          ],
        );
      },
    );
  }

  void _optionSelected(position) {
    Navigator.of(context).pop();
  }

  void _validate() {
    if (_titleController.text.isNotEmpty &&
        _firstController.text.isNotEmpty &&
        _secondController.text.isNotEmpty) {
      if (!moreOptions || (moreOptions && _thirdController.text.isNotEmpty)) {
        _savePoll();
        return;
      }
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

  void _savePoll() async {
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    WriteBatch batch = Firestore.instance.batch();
    String pollId =
        Firestore.instance.collection('content').document().documentID;
    batch.updateData(
      Firestore.instance.collection('users').document(user.uid),
      {
        'created': FieldValue.arrayUnion([pollId])
      },
    );
    var pollOptions = [];
    var results = [];
    pollOptions.add({'text': _firstController.text});
    results.add({'votes': 0});
    pollOptions.add({'text': _secondController.text});
    results.add({'votes': 0});
    if (moreOptions) {
      pollOptions.add({'text': _thirdController.text});
      results.add({'votes': 0});
    }
    batch.setData(Firestore.instance.collection('content').document(pollId), {
      'type': 'poll',
      'title': _titleController.text,
      'user_name': userData['user_name'],
      'user_id': user.uid,
      'user_image': userData['image'],
      'createdAt': Timestamp.now(),
      'options': pollOptions,
      'results': results,
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

  Widget _optionField(controller, text) {
    return TextField(
      controller: controller,
      maxLength: 25,
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _firstOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_firstController, 'Opción 1')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: ()=> _imageOptions(_option1),
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _secondOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_secondController, 'Opción 2')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: ()=> _imageOptions(_option2),
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thirdOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_thirdController, 'Opción 3')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: ()=> _imageOptions(_option3),
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: _addOption,
          ),
        )
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  hintText: 'Has una pregunta',
                ),
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 16),
              _title('Imágenes (opcional)'),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    child: RawMaterialButton(
                      onPressed: ()=> _imageOptions(null),
                      child: Icon(
                        Icons.camera_alt,
                      ),
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _title('Respuestas'),
              SizedBox(height: 16),
              _firstOption(),
              SizedBox(height: 8),
              _secondOption(),
              if (moreOptions) SizedBox(height: 8),
              if (moreOptions) _thirdOption(),
              if (!moreOptions)
                FlatButton.icon(
                  onPressed: _addOption,
                  icon: Icon(GalupFont.add),
                  label: Text('Agregar opción'),
                ),
              SizedBox(height: 16),
              _title('Duración'),
              ListTile(
                onTap: _selectDuration,
                title: Text('Infinito'),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 42,
                      child: RaisedButton(
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

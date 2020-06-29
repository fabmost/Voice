import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'countries_screen.dart';
import '../translations.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastController = TextEditingController();
  TextEditingController _birthController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  FocusNode _birthFocus = FocusNode();
  FocusNode _genderFocus = FocusNode();
  FocusNode _countryFocus = FocusNode();

  String userId;
  String _currentUrl;
  File _imageFile;
  bool _isLoading = false;

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
                onTap: _openCamera,
                leading: new Icon(
                  Icons.camera_alt,
                ),
                title: Text("Cámara"),
              ),
              new ListTile(
                onTap: _openGallery,
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
      maxWidth: 600,
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
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  void _genderSelected() {
    if (_genderFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Selecciona tu genero'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Masculino',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => _optionSelected('Masculino'),
              ),
              SimpleDialogOption(
                child: Text(
                  'Femenino',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => _optionSelected('Femenino'),
              ),
              SimpleDialogOption(
                child: Text(
                  'Otro',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => _optionSelected('Otro'),
              ),
            ],
          );
        },
      );
    }
  }

  void _birthSelected() async {
    if (_birthFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      final selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (selected != null) {
        _birthController.text = DateFormat('yyyy-MM-dd').format(selected);
      }
    }
  }

  void _countrySelected() {
    if (_countryFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pushNamed(CountriesScreen.routeName).then((value) {
        if (value != null) {
          _countryController.text = value;
        }
      });
    }
  }

  void _optionSelected(value) {
    Navigator.of(context).pop();
    _genderController.text = value;
  }

  void _validate(ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_imageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(userId + '.jpg');

          await ref.putFile(_imageFile).onComplete;

          _currentUrl = await ref.getDownloadURL();
        }
        await Firestore.instance.collection('users').document(userId).setData(
          {
            'image': _currentUrl,
            'name': _nameController.text,
            'last_name': _lastController.text,
            'gender': _genderController.text,
            'country': _countryController.text,
            'birthday': _birthController.text,
            'bio': _bioController.text,
          },
          merge: true,
        );
        Navigator.of(context).pop();
      } on PlatformException catch (err) {
        var message = 'An error ocurred';
        if (err.message != null) {
          message = err.message;
        }
        Scaffold.of(ctx).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
        setState(() {
          _isLoading = true;
        });
      } catch (err) {
        print(err);

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _birthFocus.addListener(_birthSelected);
    _genderFocus.addListener(_genderSelected);
    _countryFocus.addListener(_countrySelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_edit_profile')),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ct, AsyncSnapshot<FirebaseUser> userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          userId = userSnap.data.uid;
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(userSnap.data.uid)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final DocumentSnapshot document = snapshot.data;
              _nameController.text = document['name'];
              _lastController.text = document['last_name'];
              _birthController.text = document['birthday'];
              _genderController.text = document['gender'];
              _countryController.text = document['country'];
              if(document['bio'] != null){
                _bioController.text = document['bio'];
              }
              _currentUrl = document['image'];
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 52,
                              backgroundImage: _imageFile == null
                                  ? NetworkImage(document['image'] ?? '')
                                  : FileImage(_imageFile),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 42,
                                child: RaisedButton(
                                  onPressed: _imageOptions,
                                  textColor: Colors.white,
                                  child: Text('Cambiar foto'),
                                ),
                              ),
                            )
                          ],
                        ),
                        TextFormField(
                          controller: _nameController,
                          maxLength: 32,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText:
                                Translations.of(context).text('hint_name'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _lastController,
                          maxLength: 32,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText:
                                Translations.of(context).text('hint_last_name'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingresa tu apellido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _birthController,
                          focusNode: _birthFocus,
                          decoration: InputDecoration(
                            labelText:
                                Translations.of(context).text('hint_birth'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingresa tu fecha de nacimiento';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _genderController,
                          focusNode: _genderFocus,
                          decoration: InputDecoration(
                            labelText:
                                Translations.of(context).text('hint_gender'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingresa tu genero';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _countryController,
                          focusNode: _countryFocus,
                          decoration: InputDecoration(
                            labelText:
                                Translations.of(context).text('hint_country'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingresa tu país';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _bioController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          maxLength: 120,
                          decoration: InputDecoration(
                            labelText:
                                Translations.of(context).text('hint_bio'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                                  onPressed: () => _validate(context),
                                ),
                              ),
                      ],
                    ),
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

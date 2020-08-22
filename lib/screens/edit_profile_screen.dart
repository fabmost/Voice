import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'user_name_screen.dart';
import 'countries_screen.dart';
import 'verify_type_screen.dart';
import '../translations.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _birthController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _tiktokController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _youtubeController = TextEditingController();
  FocusNode _userFocus = FocusNode();
  FocusNode _birthFocus = FocusNode();
  FocusNode _genderFocus = FocusNode();
  FocusNode _countryFocus = FocusNode();

  FocusNode _tiktokFocus = FocusNode();
  FocusNode _facebookFocus = FocusNode();
  FocusNode _instagramFocus = FocusNode();

  String userId;
  String _currentUrl;
  File _imageFile;
  bool _loadingView = false;
  bool _isLoading = false;
  bool _changedImage = false;
  int _isValidated;
  UserModel userData;

  void _toValidate(context) {
    Navigator.of(context).pushNamed(VerifyTypeScreen.routeName);
  }

  void _imageOptions() {
    //FocusScope.of(context).requestFocus(FocusNode());
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
    final imageFile = await ImagePicker().getImage(
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
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  void _userSelected() {
    if (_userFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      Navigator.of(context)
          .pushNamed(
        UserNameScreen.routeName,
        arguments: _userController.text,
      )
          .then((value) {
        if (value != null) {
          setState(() {
            _userController.text = value;
          });
        }
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
      final selected = await DatePicker.showSimpleDatePicker(
        context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1960),
        lastDate: DateTime.now(),
        dateFormat: "dd-MMMM-yyyy",
        looping: true,
      );
      if (selected != null) {
        setState(() {
          _birthController.text = DateFormat('dd-MM-yyyy').format(selected);
        });
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

  void _editingTiktok() {
    if (_tiktokFocus.hasFocus && _tiktokController.text.isEmpty) {
      _tiktokController.text = '@';
    } else if (!_tiktokFocus.hasFocus &&
        _tiktokController.text.length == 1 &&
        _tiktokController.text.contains('@')) {
      _tiktokController.text = '';
    }
  }

  void _editingFacebook() {
    if (_facebookFocus.hasFocus && _facebookController.text.isEmpty) {
      _facebookController.text = '@';
    } else if (!_facebookFocus.hasFocus &&
        _facebookController.text.length == 1 &&
        _facebookController.text.contains('@')) {
      _facebookController.text = '';
    }
  }

  void _editingInstagram() {
    if (_instagramFocus.hasFocus && _instagramController.text.isEmpty) {
      _instagramController.text = '@';
    } else if (!_instagramFocus.hasFocus &&
        _instagramController.text.length == 1 &&
        _instagramController.text.contains('@')) {
      _instagramController.text = '';
    }
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

          _changedImage = true;
        }

        final String editName =
            userData.name != _nameController.text ? _nameController.text : null;
        final String editLastName = userData.lastName != _lastController.text
            ? _lastController.text
            : null;
        final String editBio = userData.biography != _bioController.text
            ? _bioController.text
            : null;
        final String editFacebook =
            userData.facebook != _facebookController.text
                ? _facebookController.text
                : null;
        final String editTiktok = userData.tiktok != _tiktokController.text
            ? _tiktokController.text
            : null;
        final String editInstagram =
            userData.instagram != _instagramController.text
                ? _instagramController.text
                : null;

        Map result =
            await Provider.of<UserProvider>(context, listen: false).editProfile(
          name: editName,
          lastName: editLastName,
          bio: editBio,
          tiktok: editTiktok,
          facebook: editFacebook,
          instagram: editInstagram,
        );

        if (result['result']) {
          Navigator.of(context).pop();
        } else {
          var message = result['message'] ?? 'Ocurrió un error';
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }

/*
        WriteBatch batch = Firestore.instance.batch();
        batch.updateData(
            Firestore.instance.collection('users').document(userId), {
          'image': _currentUrl,
          'name': _nameController.text,
          'last_name': _lastController.text,
          'gender': _genderController.text,
          'country': _countryController.text,
          'birthday': _birthController.text,
          'bio': _bioController.text,
          'tiktok': _tiktokController.text,
          'facebook': _facebookController.text,
          'instagram': _instagramController.text,
          'youtube': _youtubeController.text,
        });
        batch.updateData(
            Firestore.instance.collection('hash').document(userId), {
          'user_name': '${_nameController.text} ${_lastController.text}',
          'user_image': _currentUrl,
          'influencer': userData['influencer'] ?? ''
        });

        if (_changedImage) {
          if (userData['created'] != null) {
            (userData['created'] as List).forEach((element) {
              batch.updateData(
                Firestore.instance.collection('content').document(element),
                {'user_image': _currentUrl},
              );
            });
          }
          if (userData['comments'] != null) {
            (userData['comments'] as List).forEach((element) {
              batch.updateData(
                Firestore.instance.collection('comments').document(element),
                {'userImage': _currentUrl},
              );
            });
          }
          if (userData['chats'] != null) {
            (userData['chats'] as List).forEach((element) {
              batch.updateData(
                Firestore.instance.collection('chats').document(element),
                {
                  'participants.$userId': {
                    'user_image': _currentUrl,
                    'user_name': userData['user_name']
                  }
                },
              );
            });
          }
        }

        await batch.commit();
        */
      } on PlatformException catch (err) {
        var message = 'An error ocurred';
        if (err.message != null) {
          message = err.message;
        }
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        print(err);

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _getData() async {
    setState(() {
      _loadingView = true;
    });
    final user =
        await Provider.of<UserProvider>(context, listen: false).userProfile();

    setState(() {
      _loadingView = false;
      userId = user.userName;
      userData = user;
      _isValidated = 0;
      _userController.text = user.userName;
      _nameController.text = user.name;
      _lastController.text = user.lastName;
      _birthController.text = user.birthday ?? '';
      _genderController.text = user.gender ?? '';
      _countryController.text = user.country ?? '';

      if (user.biography != null) {
        _bioController.text = user.biography;
      }
      if (user.tiktok != null) {
        _tiktokController.text = user.tiktok;
      }
      if (user.facebook != null) {
        _facebookController.text = user.facebook;
      }
      if (user.instagram != null) {
        _instagramController.text = user.instagram;
      }
      if (user.youtube != null) {
        _youtubeController.text = user.youtube;
      }
      _currentUrl = user.icon;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _userFocus.addListener(_userSelected);
    _birthFocus.addListener(_birthSelected);
    _genderFocus.addListener(_genderSelected);
    _countryFocus.addListener(_countrySelected);

    _tiktokFocus.addListener(_editingTiktok);
    _facebookFocus.addListener(_editingFacebook);
    _instagramFocus.addListener(_editingInstagram);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_edit_profile')),
      ),
      body: _loadingView
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 52,
                            backgroundImage: _imageFile == null
                                ? _currentUrl == null
                                    ? null
                                    : NetworkImage(_currentUrl)
                                : FileImage(_imageFile),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 42,
                              child: RaisedButton(
                                onPressed: _imageOptions,
                                textColor: Colors.white,
                                child: Text(Translations.of(context)
                                    .text('button_change_image')),
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
                          labelText: Translations.of(context).text('hint_name'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return Translations.of(context)
                                .text('error_missing_name');
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
                            return Translations.of(context)
                                .text('error_missing_last_name');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _userController,
                        focusNode: _userFocus,
                        maxLength: 22,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9_.]")),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          labelText:
                              Translations.of(context).text('hint_user_name'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _birthController,
                        focusNode: _birthFocus,
                        decoration: InputDecoration(
                          labelText:
                              Translations.of(context).text('hint_birth'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _genderController,
                        focusNode: _genderFocus,
                        decoration: InputDecoration(
                          labelText:
                              Translations.of(context).text('hint_gender'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _countryController,
                        focusNode: _countryFocus,
                        decoration: InputDecoration(
                          labelText:
                              Translations.of(context).text('hint_country'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _bioController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        maxLength: 120,
                        decoration: InputDecoration(
                          labelText: Translations.of(context).text('hint_bio'),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Redes sociales',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _tiktokController,
                        focusNode: _tiktokFocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[@_.a-zA-Z0-9]")),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Tiktok',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _facebookController,
                        focusNode: _facebookFocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[@_.a-zA-Z0-9]")),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Facebook',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _instagramController,
                        focusNode: _instagramFocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[@_.a-zA-Z0-9]")),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Instagram',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _youtubeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[@_.a-zA-Z0-9]")),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Youtube (canal)',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if ((_isValidated ?? 0) != 2) SizedBox(height: 16),
                      if ((_isValidated ?? 0) != 2)
                        Container(
                          width: double.infinity,
                          height: 42,
                          child: FlatButton(
                            textColor: Theme.of(context).accentColor,
                            child: Text(((_isValidated ?? 0) == 0)
                                ? Translations.of(context)
                                    .text('button_verify_account')
                                : 'Verificando cuenta'),
                            onPressed: () => ((_isValidated ?? 0) == 0)
                                ? _toValidate(context)
                                : null,
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
                                child: Text(Translations.of(context)
                                    .text('button_save')),
                                onPressed: () => _validate(context),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

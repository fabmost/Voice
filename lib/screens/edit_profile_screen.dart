import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/providers/database_provider.dart';

import 'user_name_screen.dart';
import 'countries_screen.dart';
import 'verify_type_screen.dart';
import '../translations.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../models/country_model.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey keyFace = GlobalKey();
  final GlobalKey keyTik = GlobalKey();
  final GlobalKey keyInsta = GlobalKey();
  final GlobalKey keyYt = GlobalKey();
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
  bool _loadingView = false;
  bool _isLoading = false;
  int _isValidated;
  UserModel userData;
  CountryModel _selectedCountry;

  Map _serverGender = {'Masculino': 'M', 'Femenino': 'F', 'Otro': 'O'};
  Map _appGender = {'M': 'Masculino', 'F': 'Femenino', 'O': 'Otro'};

  void _toValidate(context) {
    Navigator.of(context).pushNamed(VerifyTypeScreen.routeName);
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
          _birthController.text = DateFormat('yyyy-MM-dd').format(selected);
        });
      }
    }
  }

  void _countrySelected() {
    if (_countryFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pushNamed(CountriesScreen.routeName).then((value) {
        if (value != null) {
          _selectedCountry = value;
          _countryController.text = _selectedCountry.name;
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
        final String editName =
            userData.name != _nameController.text ? _nameController.text : null;
        final String editLastName = userData.lastName != _lastController.text
            ? _lastController.text
            : null;
        final String editBirth = userData.birthday != _birthController.text
            ? _birthController.text
            : null;
        final String editGender =
            userData.gender != _serverGender[_genderController.text]
                ? _serverGender[_genderController.text]
                : null;
        final String editCountry = _selectedCountry == null
            ? null
            : userData.country != _selectedCountry.code
                ? _selectedCountry.code
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
          birth: editBirth,
          gender: editGender,
          country: editCountry,
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
    
    final serverCounrty = user.country ?? '';
    if (serverCounrty.isNotEmpty) {
      _countryController.text =
          await Provider.of<DatabaseProvider>(context, listen: false)
              .getCountryName(serverCounrty);
    } else {
      _countryController.text = user.country ?? '';
    }
    setState(() {
      _loadingView = false;
      userId = user.userName;
      userData = user;
      _isValidated = 2;
      _userController.text = user.userName;
      _nameController.text = user.name;
      _lastController.text = user.lastName;
      _birthController.text = user.birthday ?? '';
      final serverGender = user.gender ?? '';
      if (serverGender.isNotEmpty) {
        _genderController.text = _appGender[user.gender];
      } else {
        _genderController.text = serverGender;
      }

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
    });
  }

  Widget _infoButton(key, tooltip) {
    return Tooltip(
      key: key,
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          final dynamic tooltip = key.currentState;
          tooltip.ensureTooltipVisible();
        },
        child: Icon(
          Icons.info_outline,
        ),
      ),
    );
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
                          suffixIcon: _infoButton(keyTik,
                              'Introduce tu username, ejemplo @miusuario'),
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
                          suffixIcon: _infoButton(keyFace,
                              'Introduce tu username, ejemplo @miusuario'),
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
                          suffixIcon: _infoButton(keyInsta,
                              'Introduce tu username, ejemplo @miusuario'),
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
                          suffixIcon: _infoButton(keyYt,
                              'Introduce el nombre de tu canal sin espacios'),
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

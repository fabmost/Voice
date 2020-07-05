import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'menu_screen.dart';
import 'login_screen.dart';
import 'countries_screen.dart';
import '../translations.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/signup';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  bool _isChecked = false;
  TextEditingController _birthController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _birthFocus = FocusNode();
  FocusNode _genderFocus = FocusNode();
  FocusNode _countryFocus = FocusNode();

  String _name, _last, _userName, _email;

  final String termsUrl = 'https://galup.app/terminos-y-condiciones';

  void _genderSelected() {
    if (_genderFocus.hasFocus) {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(Translations.of(context).text('dialog_gender')),
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

  void _validate() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid && _isChecked) {
      _formKey.currentState.save();
      _validateUserName();
    }
  }

  void _validateUserName() async {
    setState(() {
      _isLoading = true;
    });
    final result = await Firestore.instance
        .collection('users')
        .where('user_name', isEqualTo: _userName)
        .getDocuments();
    if (result.documents.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Ese username ya existe'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } else {
      _submitForm();
    }
  }

  void _submitForm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final credential = EmailAuthProvider.getCredential(
          email: _email, password: _passwordController.text);
      final user = await _auth.currentUser();
      await user.linkWithCredential(credential);

      WriteBatch batch = Firestore.instance.batch();

      batch.setData(
        Firestore.instance.collection('users').document(user.uid),
        {
          'name': _name,
          'last_name': _last,
          'user_name': _userName,
          'gender': _genderController.text,
          'email': _email,
          'country': _countryController.text,
          'birthday': _birthController.text,
        },
        merge: true,
      );
      batch.setData(
        Firestore.instance.collection('hash').document(user.uid),
        {
          'name': _userName,
          'user_name': '$_name $_last',
        },
        merge: true,
      );

      await batch.commit();

      Navigator.of(context).pushNamedAndRemoveUntil(
          MenuScreen.routeName, (Route<dynamic> route) => false);
    } on PlatformException catch (err) {
      var message = 'An error ocurred';
      if (err.message != null) {
        message = err.message;
      }
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
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
      key: _scaffoldKey,
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
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  Translations.of(context).text('label_signup_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  Translations.of(context).text('label_signup_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
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
                  onSaved: (value) {
                    _name = value;
                  },
                ),
                TextFormField(
                  maxLength: 32,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: Translations.of(context).text('hint_last_name'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_missing_last_name');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _last = value;
                  },
                ),
                TextFormField(
                  maxLength: 22,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_.]")),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: Translations.of(context).text('hint_user_name'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_mising_username');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userName = value;
                  },
                ),
                TextFormField(
                  controller: _birthController,
                  focusNode: _birthFocus,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('hint_birth'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_missing_birth');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _genderController,
                  focusNode: _genderFocus,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('hint_gender'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_missing_gender');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _countryController,
                  focusNode: _countryFocus,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('hint_country'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_missing_country');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('hint_email'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Translations.of(context)
                          .text('error_missing_email');
                    }
                    Pattern pattern =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return Translations.of(context)
                          .text('error_invalid_email');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('hint_password'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return Translations.of(context)
                          .text('error_password_length');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText:
                        Translations.of(context).text('hint_repeat_password'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty || _passwordController.text != value) {
                      return Translations.of(context)
                          .text('error_password_mismatch');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value;
                        });
                      },
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Acepto los ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunch(termsUrl)) {
                                await launch(
                                  termsUrl,
                                );
                              }
                            },
                          text: 'Términos y Condiciones',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ]),
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
                          textColor: Colors.white,
                          child: Text(
                              Translations.of(context).text('button_signup')),
                          onPressed: _validate,
                        ),
                      ),
                ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(Translations.of(context).text('label_have_account')),
                      SizedBox(width: 8),
                      Text(
                        Translations.of(context).text('button_login'),
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ],
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

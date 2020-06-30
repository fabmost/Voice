import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';
import 'countries_screen.dart';
import '../translations.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/signup';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  TextEditingController _birthController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _birthFocus = FocusNode();
  FocusNode _genderFocus = FocusNode();
  FocusNode _countryFocus = FocusNode();

  String _name, _last, _userName, _email;

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

  void _validate(ctx) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      _validateUserName(ctx);
    }
  }

  void _validateUserName(ctx) async {
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
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Ese username ya existe'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } else {
      _submitForm(ctx);
    }
  }

  void _submitForm(ctx) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final credential = EmailAuthProvider.getCredential(
          email: _email, password: _passwordController.text);
      final user = await _auth.currentUser();
      await user.linkWithCredential(credential);

      await Firestore.instance.collection('users').document(user.uid).setData(
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

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } on PlatformException catch (err) {
      var message = 'An error ocurred';
      if (err.message != null) {
        message = err.message;
      }
      Scaffold.of(ctx).showSnackBar(
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
                  'Regístrate en Galup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '¡Crea un perfil, sigue otras cuentas, crea tus propias encuestas y retos!',
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
                      return 'Ingresa tu nombre';
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
                      return 'Ingresa tu apellido';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _last = value;
                  },
                ),
                TextFormField(
                  maxLength: 22,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: Translations.of(context).text('hint_user_name'),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Ingresa tu nombre de usuario';
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
                      return 'Ingresa tu fecha de nacimiento';
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
                      return 'Ingresa tu genero';
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
                      return 'Ingresa tu país';
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
                      return 'Ingresa tu correo';
                    }
                    Pattern pattern =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Ingresa un correo válido';
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
                      return 'Tu contraseña debe tener al menos 7 caracteres';
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
                      return 'Las contraseñas deben coincidir';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        width: double.infinity,
                        height: 42,
                        child: RaisedButton(
                          textColor: Colors.white,
                          child: Text('Registrar'),
                          onPressed: () => _validate(context),
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
                      Text('¿Ya tienes cuenta?'),
                      SizedBox(width: 8),
                      Text(
                        'Ingresa',
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

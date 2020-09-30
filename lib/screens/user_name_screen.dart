import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/user_provider.dart';

class UserNameScreen extends StatefulWidget {
  static const routeName = '/username';
  @override
  _UserNameScreenState createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userController = TextEditingController();

  bool hasData = false;
  bool _isLoading = false;
  String _userName;

  void _validate() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      _validateUserName();
    }
  }

  void _validateUserName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map result = await Provider.of<UserProvider>(context, listen: false)
          .editProfile(userName: _userName);

      if (result['result']) {
        Navigator.of(context).pop(_userName);
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
  Widget build(BuildContext context) {
    String userName = ModalRoute.of(context).settings.arguments;
    if (!hasData) {
      hasData = true;
      _userController.text = userName;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Username'),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _userController,
                  maxLength: 22,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9_.]")),
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
                SizedBox(height: 16),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        width: double.infinity,
                        height: 42,
                        child: RaisedButton(
                          textColor: Colors.white,
                          child: Text(
                              Translations.of(context).text('button_save')),
                          onPressed: _validate,
                        ),
                      ),
              ],
            ),
          )),
    );
  }
}

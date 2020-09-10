import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  bool _isLoading = false;

  void _validate() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      _sendEmail();
    }
  }

  void _sendEmail() async {
    setState(() {
      _isLoading = true;
    });
    final result = await Provider.of<AuthProvider>(context, listen: false)
        .recoverPassword(_email);
    setState(() {
      _isLoading = false;
    });

    if (result) {
      _sendAlert(
          'Te hemos enviado un correo de verificación para completar el proceso');
    } else {
      _sendAlert('No tenemos ese correo registrado');
    }
  }

  void _sendAlert(message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Theme.of(context).accentColor,
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_forgot')),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Text(
                Translations.of(context).text('label_forgot'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: Translations.of(context).text('hint_email'),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return Translations.of(context).text('error_missing_email');
                  }
                  Pattern pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return Translations.of(context).text('error_invalid_email');
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
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
                        child:
                            Text(Translations.of(context).text('button_send')),
                        onPressed: _validate,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

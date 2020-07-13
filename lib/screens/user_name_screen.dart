import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../translations.dart';

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
      _saveUserName();
    }
  }

  void _saveUserName() async {
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    WriteBatch batch = Firestore.instance.batch();
    batch.updateData(
      Firestore.instance.collection('users').document(user.uid),
      {'user_name': _userName},
    );
    batch.updateData(
      Firestore.instance.collection('hash').document(user.uid),
      {'name': _userName},
    );
    if (userData['created'] != null) {
      (userData['created'] as List).forEach((element) {
        batch.updateData(
          Firestore.instance.collection('content').document(element),
          {'user_name': _userName},
        );
      });
    }
    if (userData['comments'] != null) {
      (userData['comments'] as List).forEach((element) {
        batch.updateData(
          Firestore.instance.collection('comments').document(element),
          {'username': _userName},
        );
      });
    }
    if (userData['chats'] != null) {
      (userData['chats'] as List).forEach((element) {
        batch.updateData(
          Firestore.instance.collection('chats').document(element),
          {
            'participants.${user.uid}': {'user_name': _userName}
          },
        );
      });
    }
    await batch.commit();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String userName = ModalRoute.of(context).settings.arguments;
    if(!hasData){
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';
import '../models/category.dart';
import '../widgets/category_tile.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isLoading = false;
  List<String> _categories = [];

  void _signIn(context) async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseAuth.instance.signInAnonymously();
  }

  void _setSelected(value) {
    if (_categories.contains(value)) {
      setState(() {
        _categories.remove(value);
      });
    } else {
      setState(() {
        _categories.add(value);
      });
    }
  }

  void _saveCategories() async {
    setState(() {
      _isLoading = true;
    });
    final authResult = await FirebaseAuth.instance.signInAnonymously();
    await Firestore.instance
        .collection('users')
        .document(authResult.user.uid)
        .setData({
      'categories': _categories,
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = Category.categoriesList;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(''),
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            child: Text(Translations.of(context).text('button_skip')),
            onPressed: () => _signIn(context),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translations.of(context).text('label_preferences_title'),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    Translations.of(context).text('label_preferences_subtitle'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categoryList.length,
                      itemBuilder: (ctx, i) => CategoryTile(
                        categoryList[i].name,
                        categoryList[i].icon,
                        _categories.contains(categoryList[i].name),
                        _setSelected,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      bottom: 16,
                      right: 16,
                    ),
                    height: 42,
                    width: double.infinity,
                    child: RaisedButton(
                      textColor: Colors.white,
                      child: Text(
                          Translations.of(context).text('button_continue')),
                      onPressed: _categories.isEmpty ? null : _saveCategories,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

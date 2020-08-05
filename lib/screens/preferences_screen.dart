import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/auth_provider.dart';
import '../providers/config_provider.dart';
import '../widgets/category_tile.dart';
import '../models/category_model.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isLoading = false;
  List<CategoryModel> _selected = [];
  List<CategoryModel> _categories = [];

  void _signIn(context) async {
    Provider.of<AuthProvider>(context, listen: false).registerAnonymous();
  }

  void _setSelected(value) {
    if (_selected.contains(value)) {
      setState(() {
        _selected.remove(value);
      });
    } else {
      setState(() {
        _selected.add(value);
      });
    }
  }

  void _saveCategories() async {
    setState(() {
      _isLoading = true;
    });
    List categories = _categories.map((e) {
      Map map = {};
      map['id'] = e.id;
      return map;
    }).toList();
    Provider.of<AuthProvider>(context, listen: false)
        .savePreferences(categories);
  }

  void getCategories() async {
    setState(() {
      _isLoading = true;
    });
    final cats =
        await Provider.of<AuthProvider>(context, listen: false).installation();
    setState(() {
      _isLoading = false;
      _categories = cats;
    });
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
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
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) => CategoryTile(
                        _categories[i],
                        _selected.contains(_categories[i]),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'category_tile.dart';
import '../translations.dart';
import '../providers/auth_provider.dart';
import '../models/category_model.dart';

class PreferencesList extends StatefulWidget {
  final List<CategoryModel> categories;

  PreferencesList(this.categories);

  @override
  _PreferencesListState createState() => _PreferencesListState();
}

class _PreferencesListState extends State<PreferencesList> {
  bool _isLoading = false;
  List<CategoryModel> _categories = [];

  void _setSelected(value) {
    if (!_isLoading) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: widget.categories.length,
            itemBuilder: (ctx, i) => CategoryTile(
              widget.categories[i],
              _categories.contains(widget.categories[i]),
              _setSelected,
            ),
          ),
        ),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  bottom: 16,
                  right: 16,
                ),
                height: 42,
                width: double.infinity,
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Text(Translations.of(context).text('button_continue')),
                  onPressed: _categories.isEmpty ? null : _saveCategories,
                ),
              ),
      ],
    );
  }
}

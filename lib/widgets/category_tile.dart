import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel _name;
  final bool _isSelected;
  final Function _action;

  CategoryTile(this._name, this._isSelected, this._action);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _action(_name),
      child: Align(
        alignment: FractionalOffset.centerLeft,
        child: Card(
          elevation: 0,
          color: _isSelected ? Theme.of(context).accentColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _name.name,
              style: TextStyle(
                fontSize: 18,
                color: _isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

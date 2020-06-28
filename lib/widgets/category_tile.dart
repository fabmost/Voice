import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String _name;
  final IconData _icon;
  final bool _isSelected;
  final Function _action;

  CategoryTile(this._name, this._icon, this._isSelected, this._action);

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(_icon),
                ),
                SizedBox(width: 8),
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isSelected ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

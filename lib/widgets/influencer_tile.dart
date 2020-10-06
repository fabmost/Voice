import 'package:flutter/material.dart';

class InfluencerTile extends StatelessWidget {
  final String _id;
  final String _name;
  final String type;
  final String icon;
  final Function _action;

  InfluencerTile(this._id, this._name, this.icon, this.type, this._action);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _action(context, type, _id),
      child: Align(
        alignment: FractionalOffset.centerLeft,
        child: Card(
          elevation: 0,
          color: Color(0xFFF1F1FE),
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
                  child: Image.network(
                    icon,
                    height: 24,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
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

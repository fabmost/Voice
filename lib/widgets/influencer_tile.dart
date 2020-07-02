import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';

class InfluencerTile extends StatelessWidget {
  final String _name;
  final String type;
  final int color;
  final Function _action;

  InfluencerTile(this._name, this.color, this.type, this._action);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _action(context, type, _name),
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
                  child: Icon(
                    GalupFont.certification,
                    color: Color(color),
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

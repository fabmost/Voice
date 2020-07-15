import 'package:flutter/material.dart';

import '../screens/detail_cause_screen.dart';

class CauseTile extends StatelessWidget {
  final objId;
  final String title;

  CauseTile(this.objId, this.title);

  final Color color = Color(0xFFE0E0E0);

  void _toDetail(context) {
    Navigator.of(context).pushNamed(
      DetailCauseScreen.routeName,
      arguments: objId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: Colors.black,
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(19),
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Container(
            height: 84,
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              title,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: ListTile(
              title: OutlineButton(
                textColor: Colors.black,
                borderSide: BorderSide(color: Colors.black),
                onPressed: () => _toDetail(context),
                child: Text('Ver más'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

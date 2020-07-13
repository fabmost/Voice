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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 50,
            color: color,
            alignment: Alignment.center,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(19),
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            height: 80,
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
            color: color,
            child: ListTile(
              title: OutlineButton(
                textColor: Colors.white,
                borderSide: BorderSide(color: Colors.white),
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

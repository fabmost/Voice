import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/detail_cause_screen.dart';
import '../providers/content_provider.dart';
import '../models/cause_model.dart';

class CauseCard extends StatelessWidget {
  final String id;
  final String title;
  final bool liked;

  CauseCard({this.id, this.title, this.liked});

  final Color color = Color(0xFFE0E0E0);

  void _toDetail(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCauseScreen(
          id: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(builder: (context, value, child) {
      CauseModel cause = value.getCausesList[id];
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
                color: cause.hasLiked ? Color(0xAA722282) : color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
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
                color: cause.hasLiked ? Color(0xAA722282) : color,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: ListTile(
                title: OutlineButton(
                  textColor: cause.hasLiked ? Colors.white : Colors.black,
                  borderSide: BorderSide(
                      color: cause.hasLiked ? Colors.white : Colors.black),
                  onPressed: () => _toDetail(context),
                  child: Text('Ver más'),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

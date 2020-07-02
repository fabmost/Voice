import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/detail_cause_screen.dart';

class SearchCause extends StatelessWidget {
  final DocumentReference reference;
  final String myId;
  final String creator;
  final String title;
  final String info;
  final String userName;

  final Color color = Color(0xFFF0F0F0);

  SearchCause({
    this.reference,
    this.myId,
    this.creator,
    this.title,
    this.info,
    this.userName,
  });

  void _toDetail(context) {
    Navigator.of(context).pushNamed(DetailCauseScreen.routeName,
        arguments: reference.documentID);
  }

  void _infoAlert(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(info),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  Widget _causeButton(context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      width: double.infinity,
      child: OutlineButton(
        highlightColor: Color(0xFFA4175D),
        borderSide: BorderSide(
          color: Colors.black,
          width: 2,
        ),
        onPressed: () => null,
        child: Text('Apoyo esta causa'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => _toDetail(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: color,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        creator,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () => _infoAlert(context),
                      )
                    ],
                  ),
                  subtitle: Text('Por: Galup'),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _causeButton(context),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

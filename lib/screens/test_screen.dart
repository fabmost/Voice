import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/screens/detail_tip_screen.dart';

import '../providers/auth_provider.dart';

import 'detail_poll_screen.dart';
import 'detail_challenge_screen.dart';
import 'detail_cause_screen.dart';
import '../widgets/alert_promo.dart';

class TestScreen extends StatelessWidget {
  static const routeName = '/test';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: Text('Cerrar sesión'),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .renewToken();
                },
                child: Text('Renew token'),
              ),
              RaisedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertPromo(),
                  );
                },
                child: Text('Promo dialog'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPollScreen(
                        id: '624',
                      ),
                    ),
                  );
                },
                child: Text('Get Poll'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailChallengeScreen(
                        id: '10',
                      ),
                    ),
                  );
                },
                child: Text('Get Challenge'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailTipScreen(
                        id: '1',
                      ),
                    ),
                  );
                },
                child: Text('Get Tip'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailCauseScreen(
                        id: '1',
                      ),
                    ),
                  );
                },
                child: Text('Get Cause'),
              ),
              RaisedButton(
                onPressed: () {
                  FirebaseMessaging().getToken().then((token) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .setFCM(token);
                  });
                },
                child: Text('Get Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';

import 'detail_poll_screen.dart';
import 'detail_challenge_screen.dart';
import 'detail_cause_screen.dart';

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
                  Provider.of<AuthProvider>(context, listen: false).signUp(
                      name: 'Test',
                      last: 'Amazon',
                      email: 'test_server@galup.com',
                      password: API().getSalt('holamundo'),
                      user: 'test_server');
                },
                child: Text('SignUp'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).login(
                    email: 'fabmost@gmail.com',
                    password: API().getSalt('holamundo'),
                  );
                },
                child: Text('Login'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .renewToken();
                },
                child: Text('Renew token'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPollScreen(
                        id: '6',
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
                      builder: (context) => DetailCauseScreen(
                        id: '3',
                      ),
                    ),
                  );
                },
                child: Text('Get Cause'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .saveContent('3', 'P');
                },
                child: Text('Save content'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .newChallenge(
                    name: 'Un reto de prueba',
                    description: 'Reto de un anónimo',
                    category: 3,
                    resource: '593',
                    parameter: 'L',
                    goal: 100,
                  );
                },
                child: Text('New Challege'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false).newPoll(
                    name: 'Una encuesta de prueba',
                    description: 'Encuesta de prueba',
                    category: 3,
                    answers: [
                      {
                        'text': 'Respuesta 1',
                        'id_resource': null,
                      },
                      {
                        'text': 'Respuesta 2',
                        'id_resource': null,
                      }
                    ],
                  );
                },
                child: Text('New Poll'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .getPollStatistics(6);
                },
                child: Text('Statistics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

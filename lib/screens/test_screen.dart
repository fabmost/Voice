import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';

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
                    user: 'test_server'
                  );
                },
                child: Text('SignUp'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).login(
                    email: 'fabmost@gmail.com',
                    password: 'holamundo',
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
                  Provider.of<ContentProvider>(context, listen: false)
                      .getContent('P', '6');
                },
                child: Text('Get Poll'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .getContent('C', '10');
                },
                child: Text('Get Challenge'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .getContent('CA', '3');
                },
                child: Text('Get Cause'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .likeContent('P', '6');
                },
                child: Text('Like'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .getComments('P', '6');
                },
                child: Text('Get Comments'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .newRegalup('6', 'P');
                },
                child: Text('Regalup poll'),
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
                      .likeComment('760', 'L');
                },
                child: Text('Like comment'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .votePoll('6', '10');
                },
                child: Text('Vote poll'),
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
                  Provider.of<ContentProvider>(context, listen: false)
                      .newComment(
                    comment: 'Un nuevo comentario de prueba',
                    type: 'P',
                    id: '6',
                  );
                },
                child: Text('New Comment'),
              ),
              RaisedButton(
                onPressed: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .getPollStatistics(6);
                  /*
                  Provider.of<ContentProvider>(context, listen: false).newPoll(
                      name: 'Soy una encuesta de prueba',
                      description: 'Soy de un anónimo',
                      category: '1',
                      answers: [
                        {
                          'text': 'Respuesta 1',
                          'id_resource': null,
                        },
                        {
                          'text': 'Respuesta 2',
                          'id_resource': null,
                        }
                      ]);*/
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

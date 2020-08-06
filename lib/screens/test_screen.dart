import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Provider.of<ContentProvider>(context, listen: false).saveContent('3', 'P');
              },
              child: Text('Save content'),
            ),
            RaisedButton(
              onPressed: () {
                Provider.of<ContentProvider>(context, listen: false).newChallenge(
                  name: 'Un reto de prueba',
                  description: 'Reto de un anónimo',
                  category: '1',
                  resource: '1',
                  parameter: 'L',
                  goal: '100',
                );
              },
              child: Text('New Challege'),
            ),
            RaisedButton(
              onPressed: () {
                Provider.of<ContentProvider>(context, listen: false).getPollStatistics(3);
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
              child: Text('Test'),
            ),
          ],
        ),
      ),
    );
  }
}

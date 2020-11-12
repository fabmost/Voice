import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../widgets/user_profile_cover.dart';

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
      body: UserProfileCover([]),
    );
  }
}

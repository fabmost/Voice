import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'test_screen.dart';
import '../providers/content_provider.dart';
import '../widgets/home_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed(TestScreen.routeName);
            },
            child: Text('Test'),
          )
        ],
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, child) {
          if (provider.getHome.isEmpty) {
            provider.getBaseTimeline(0, null);
            return Container();
          }
          return HomeList(provider.getHome);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Provider.of<ContentProvider>(context, listen: false).getBaseTimeline(0, null);
          },
          child: Text('Test'),
        ),
      ),
    );
  }
}

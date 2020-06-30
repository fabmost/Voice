import 'package:flutter/material.dart';

class DetailPollScreen extends StatelessWidget {
  static const routeName = '/poll';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuesta'),
      ),
    );
  }
}

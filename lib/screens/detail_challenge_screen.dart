import 'package:flutter/material.dart';

import '../translations.dart';

class DetailChallengeScreen extends StatelessWidget {
  static const routeName = '/challenge';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_challenge')),
      ),
    );
  }
}
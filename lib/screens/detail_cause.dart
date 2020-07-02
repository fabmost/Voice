import 'package:flutter/material.dart';

import '../translations.dart';

class DetailCauseScreen extends StatelessWidget {
  static const routeName = '/cause';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_cause')),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../translations.dart';

class DetailPollScreen extends StatelessWidget {
  static const routeName = '/poll';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_poll')),
      ),
    );
  }
}

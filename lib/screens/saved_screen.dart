import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/saved_list.dart';

class SavedScreen extends StatelessWidget {
  static const routeName = '/saved';
  
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_saved')),
      ),
      body: SavedList(scrollController, null),
    );
  }
}

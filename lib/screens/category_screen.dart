import 'package:flutter/material.dart';

import '../widgets/filtered_content.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/category';

  @override
  Widget build(BuildContext context) {
    String category = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FilteredContent(category),
    );
  }
}

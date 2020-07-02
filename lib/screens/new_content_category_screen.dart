import 'package:flutter/material.dart';

import '../models/category.dart';

class NewContentCategoryScreen extends StatelessWidget {
  static const routeName = '/content-category';

  void _setSelected(value, context) {
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = Category.categoriesList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Categoría'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: categoryList.length,
        itemBuilder: (ctx, i) => ListTile(
          onTap: () => _setSelected(categoryList[i].name, context),
          title: Text(categoryList[i].name),
        ),
      ),
    );
  }
}

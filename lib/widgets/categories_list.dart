import 'package:flutter/material.dart';

import '../screens/category_screen.dart';
import '../models/category.dart';

class CategoriesList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final categoryList = Category.categoriesList;
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: categoryList.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(categoryList[i].name),
          onTap: () {
            Navigator.of(context).pushNamed(CategoryScreen.routeName, arguments: categoryList[i].name);
          },
        );
      },
    );
  }
}

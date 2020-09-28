import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/category_screen.dart';
import '../providers/database_provider.dart';

class CategoriesList extends StatelessWidget {
  Widget _categoriesList(list) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: list.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(list[i].name),
          onTap: () {
            Navigator.of(context)
                .pushNamed(CategoryScreen.routeName, arguments: list[i]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list =
        Provider.of<DatabaseProvider>(context, listen: false).getCategories;
    if (list.isNotEmpty) {
      return _categoriesList(list);
    }
    return FutureBuilder(
      future:
          Provider.of<DatabaseProvider>(context, listen: false).getCatalogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return _categoriesList(
            Provider.of<DatabaseProvider>(context, listen: false)
                .getCategories);
      },
    );
  }
}

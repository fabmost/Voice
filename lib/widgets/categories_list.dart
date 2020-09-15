import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/category_screen.dart';
import '../providers/database_provider.dart';
import '../providers/auth_provider.dart';

class CategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<DatabaseProvider>(context, listen: false).getCategories(),
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.isEmpty) {
          Provider.of<AuthProvider>(context, listen: false).getCatalogs();
          return Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: snapshot.data.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(snapshot.data[i].name),
              onTap: () {
                Navigator.of(context).pushNamed(CategoryScreen.routeName,
                    arguments: snapshot.data[i]);
              },
            );
          },
        );
      },
    );
  }
}

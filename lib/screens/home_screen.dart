import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../widgets/home_list.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController homeController;

  HomeScreen(this.homeController);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, provider, child) {
        return HomeList(
          homeController,
          provider.getHome,
          provider.getCauses,
          provider.getUsers,
        );
      },
    );
  }
}

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
        if (provider.getHome.isEmpty) {
          provider.getBaseTimeline(0, null);
          return Center(child: CircularProgressIndicator());
        }
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

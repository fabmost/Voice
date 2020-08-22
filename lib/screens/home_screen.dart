import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/home_list.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController homeController;

  HomeScreen(this.homeController);

  void _scrollToTop() {
    homeController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        GestureDetector(
          onTap: _scrollToTop,
          child: Image.asset(
            'assets/logo.png',
            width: 42,
          ),
        ),
        true,
      ),
      body: Consumer<ContentProvider>(
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
      ),
    );
  }
}

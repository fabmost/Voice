import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget _title;
  final bool _isCentered;

  CustomAppBar(this._title, [this._isCentered = false]);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _toProfile(context) {
    Navigator.of(context).pushNamed(ProfileScreen.routeName);
  }

  void _toNotifications(context) {
    Navigator.of(context).pushNamed(NotificationsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _title,
      centerTitle: _isCentered,
      leading: IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () => _toProfile(context),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: ()=> _toNotifications(context),
        ),
      ],
    );
  }
}

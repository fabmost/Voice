import 'package:flutter/material.dart';

import '../screens/notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget _title;
  final bool _isCentered;

  CustomAppBar(this._title, [this._isCentered = false]);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void _toNotifications(context) {
    Navigator.of(context).pushNamed(NotificationsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _title,
      centerTitle: _isCentered,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: ()=> _toNotifications(context),
        ),
      ],
    );
  }
}

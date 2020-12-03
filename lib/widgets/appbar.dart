import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget _title;
  final bool _isCentered;
  final bool showBadge;
  final Function _toNotifications;

  CustomAppBar(this._title, this.showBadge, this._toNotifications, [this._isCentered = false]);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _title,
      centerTitle: _isCentered,
      actions: <Widget>[
        Badge(
          showBadge: showBadge,
          badgeContent: Text(
            '',
            style: TextStyle(color: Colors.white),
          ),
          position: BadgePosition(top: 8, end: 12),
          child: IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _toNotifications,
          ),
        ),
      ],
    );
  }
}

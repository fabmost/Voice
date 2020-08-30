import 'package:flutter/material.dart';

class NoAppBar extends StatelessWidget implements PreferredSizeWidget {
  NoAppBar();

  @override
  Size get preferredSize => Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).primaryColorDark,);
  }
}

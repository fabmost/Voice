import 'package:flutter/material.dart';

class ContentTypeIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  ContentTypeIcon({
    this.name,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final mKey = new GlobalKey();
    return Tooltip(
      key: mKey,
      message: '$name',
      child: GestureDetector(
        onTap: () {
          final dynamic tooltip = mKey.currentState;
          tooltip.ensureTooltipVisible();
        },
        child: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

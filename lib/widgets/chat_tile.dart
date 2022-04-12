import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../translations.dart';
import '../screens/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String userName;
  final String userHash;
  final String icon;
  final String message;
  final DateTime date;

  ChatTile({
    @required this.userName,
    @required this.userHash,
    @required this.icon,
    @required this.message,
    @required this.date,
  });

  void _toChat(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName),
        builder: (context) => ChatScreen(
          userHash: userHash,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(date);
    final newDate = now.subtract(difference).toLocal();

    return ListTile(
      onTap: () => _toChat(context),
      leading: CircleAvatar(
        backgroundImage:
            (icon == null || icon == '') ? null : CachedNetworkImageProvider(icon),
      ),
      title: Text(userName),
      subtitle: Text(
        message,
        maxLines: 2,
      ),
      trailing: Text(
        timeago.format(newDate,
            locale: Translations.of(context).currentLanguage),
      ),
    );
  }
}

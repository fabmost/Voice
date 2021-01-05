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
    this.userName,
    this.userHash,
    this.icon,
    this.message,
    this.date,
  });

  void _toChat(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(userHash),
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
        backgroundImage: icon == null ? null : NetworkImage(icon),
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

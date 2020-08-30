import 'package:flutter/material.dart';

import '../screens/view_profile_screen.dart';

class MessageBubble extends StatelessWidget {
  final Key key;
  final String message;
  final String userId;
  final String username;
  final String userimage;
  final bool isMe;

  MessageBubble(
    this.message,
    this.userId,
    this.username,
    this.userimage,
    this.isMe, {
    this.key,
  });

  void _toProfile(context) {
    if (!isMe) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(minWidth: 100, maxWidth: width - 50),
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!isMe) SizedBox(width: 32),
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe
                              ? Colors.black
                              : Theme.of(context)
                                  .accentTextTheme
                                  .headline1
                                  .color,
                        ),
                      ),
                      if (isMe) SizedBox(width: 32),
                    ],
                  ),
                  Text(
                    message,
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline1.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: isMe ? null : 10,
          right: isMe ? 10 : null,
          child: GestureDetector(
            onTap: () => _toProfile(context),
            child: CircleAvatar(
              backgroundImage: userimage == null ? null : NetworkImage(userimage),
            ),
          ),
        )
      ],
    );
  }
}

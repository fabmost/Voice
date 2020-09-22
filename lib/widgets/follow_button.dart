import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mixins/alert_mixin.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class FollowButton extends StatelessWidget with AlertMixin {
  final String userName;
  final bool isFollowing;

  FollowButton({this.userName, this.isFollowing});

  void _follow(context) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    await Provider.of<UserProvider>(context, listen: false)
        .followUser(userName);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, value, child) {
      UserModel mUser = value.getUsers[userName];
      if (!mUser.isFollowing) {
        return RaisedButton(
          onPressed: () => _follow(context),
          textColor: Colors.white,
          child: Text('Seguir'),
        );
      }
      return OutlineButton(
        onPressed: () => _follow(context),
        child: Text('Siguiendo'),
      );
    });
  }
}

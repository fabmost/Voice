import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mixins/alert_mixin.dart';
import '../providers/user_provider.dart';

class FollowButton extends StatefulWidget {
  final String userName;
  final bool isFollowing;

  FollowButton({this.userName, this.isFollowing});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> with AlertMixin{
  bool _isFollowing;
  bool _isLoading = false;

  void _follow() async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    bool result = await Provider.of<UserProvider>(context, listen: false)
        .followUser(widget.userName);
    setState(() {
      _isLoading = false;
      _isFollowing = result;
    });
  }

  @override
  void initState() {
    _isFollowing = widget.isFollowing;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) CircularProgressIndicator();
    if (!_isFollowing) {
      return RaisedButton(
        onPressed: _follow,
        textColor: Colors.white,
        child: Text('Seguir'),
      );
    }
    return OutlineButton(
      onPressed: _follow,
      child: Text('Siguiendo'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/user_provider.dart';
import '../screens/auth_screen.dart';

class FollowButton extends StatefulWidget {
  final String userName;
  final bool isFollowing;

  FollowButton({this.userName, this.isFollowing});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing;
  bool _isLoading = false;

  void _follow() async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      _anonymousAlert();
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

  void _anonymousAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_need_account')),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text(Translations.of(context).text('button_cancel')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text(Translations.of(context).text('button_create_account')),
          ),
        ],
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../screens/followers_screen.dart';
import '../screens/following_screen.dart';
import '../providers/user_provider.dart';

class UserFollowers extends StatefulWidget {
  final String userName;
  final int followers;
  final int following;
  final bool isFollowing;

  UserFollowers({
    this.userName,
    this.followers,
    this.following,
    this.isFollowing,
  });

  @override
  _UserFollowersState createState() => _UserFollowersState();
}

class _UserFollowersState extends State<UserFollowers> {
  int _followers;
  bool _isFollowing;
  bool _isLoading = false;

  void _toFollowers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          widget.userName,
        ),
      ),
    );
  }

  void _toFollowing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingScreen(
          widget.userName,
        ),
      ),
    );
  }

  void _follow() async {
    setState(() {
      _isLoading = true;
    });
    bool result = await Provider.of<UserProvider>(context, listen: false).followUser(widget.userName);
    setState(() {
      _isLoading = false;
      if(_isFollowing && !result){
        _followers--;
      }
      if(!_isFollowing && result){
        _followers++;
      }
      _isFollowing = result;
    });
  }

  Widget _usersWidget(amount, type, action) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: action,
        child: Column(
          children: <Widget>[
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget _followButton() {
    if (_isLoading)
      return Expanded(
        flex: 1,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    if (!_isFollowing) {
      return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: _follow,
          textColor: Colors.white,
          child: Text('Seguir'),
        ),
      );
    }
    return Expanded(
      flex: 1,
      child: OutlineButton(
        onPressed: _follow,
        child: Text('Siguiendo'),
      ),
    );
  }

  @override
  void initState() {
    _followers = widget.followers;
    _isFollowing = widget.isFollowing;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _usersWidget(
          widget.following,
          Translations.of(context).text('label_following'),
          _toFollowing,
        ),
        Container(
          width: 1,
          color: Colors.grey,
          height: 32,
        ),
        _usersWidget(
          _followers,
          Translations.of(context).text('label_followers'),
          _toFollowers,
        ),
        _followButton(),
        SizedBox(width: 16)
      ],
    );
  }
}

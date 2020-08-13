import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_screen.dart';
import 'view_profile_screen.dart';
import '../translations.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../widgets/influencer_badge.dart';
import '../widgets/follow_button.dart';

class FollowingScreen extends StatefulWidget {
  final userId;

  FollowingScreen(this.userId);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  TextEditingController _controller = new TextEditingController();
  List<UserModel> _userList = [];
  bool _isLoading = false;
  bool _hasMore = false;
  int page = 0;
  String _filter;

  void _toProfile(userId) async {
    //final user = await FirebaseAuth.instance.currentUser();
    //if (user.uid != userId) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    //  }
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    final users = await Provider.of<UserProvider>(context, listen: false)
        .getFollowing(widget.userId, page);
    setState(() {
      _userList = users;
      _isLoading = false;
    });
  }

  void _anonymousAlert(context) {
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
    super.initState();
    _getData();
    _controller.addListener(() {
      setState(() {
        _filter = _controller.text;
      });
    });
  }

  Widget _userTile(UserModel user) {
    return ListTile(
      onTap: () => _toProfile(user.userName),
      leading: CircleAvatar(
        backgroundImage: user.icon == null ? null : NetworkImage(user.icon),
      ),
      title: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '${user.name} ${user.lastName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          //InfluencerBadge(doc['influencer'] ?? '', 16),
        ],
      ),
      subtitle: Text('@${user.userName}'),
      trailing: FollowButton(
        userName: user.userName,
        isFollowing: user.isFollowing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('label_following')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_userList.isEmpty)
              ? Center(
                  child: Text(Translations.of(context).text('empty_following')),
                )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText:
                                Translations.of(context).text('hint_search')),
                        controller: _controller,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _userList.length,
                        itemBuilder: (ctx, i) {
                          final doc = _userList[i];

                          return _filter == null || _filter == ""
                              ? Column(
                                  children: <Widget>[_userTile(doc), Divider()],
                                )
                              : doc.userName
                                      .toLowerCase()
                                      .contains(_filter.toLowerCase())
                                  ? _userTile(doc)
                                  : Container();
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

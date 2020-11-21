import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_profile_screen.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupMembersScreen(this.groupId, this.groupName);

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  bool _isLoading = false;
  List<UserModel> _members = [];

  void _toProfile(userId) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  void _getMembers() async {
    setState(() {
      _isLoading = true;
    });
    final users = await Provider.of<UserProvider>(context, listen: false)
        .getMembers(widget.groupId, 0);
    setState(() {
      _isLoading = false;
      _members = users;
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
          //SizedBox(width: 8),
          //InfluencerBadge(user.userName, user.certificate, 16),
        ],
      ),
      subtitle: Text('@${user.userName}'),
    );
  }

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: _members.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, i) => _userTile(_members[i]),
            ),
    );
  }
}

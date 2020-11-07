import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../widgets/influencer_badge.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class NewGroupScreen extends StatefulWidget {
  static const String routeName = '/new-group';
  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _searchController = new TextEditingController();
  List<UserModel> _searchList = [];
  List<UserModel> _added = [];
  Timer _debounce;
  bool _isLoading = false;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length > 2)
        _searchUsers();
      else {
        setState(() {
          _searchList.clear();
        });
      }
    });
  }

  void _searchUsers() async {
    setState(() {
      _searchList.clear();
    });
    final users = await Provider.of<UserProvider>(context, listen: false)
        .getAutocomplete(_searchController.text);
    _added.forEach((element) {
      users['users'].removeWhere((entry) {
        return entry.userName == element.userName;
      });
    });
    setState(() {
      _searchList = users['users'];
    });
  }

  void _validate() {
    if (_titleController.text.isNotEmpty && _added.isNotEmpty) {
      _saveGroup();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('error_missing')),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _saveGroup() async {
    setState(() {
      _isLoading = true;
    });
    List members = [];
    _added.forEach((e) {
      members.add({'user_name': e.userName});
    });
    await Provider.of<UserProvider>(context, listen: false).newGroup(
      title: _titleController.text,
      members: members,
    );
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Iterable<Widget> get chipWidgets sync* {
    for (final UserModel user in _added) {
      yield Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          backgroundColor: Theme.of(context).accentColor,
          avatar: CircleAvatar(
            backgroundImage: user.icon == null ? null : NetworkImage(user.icon),
          ),
          label: Text(
            user.userName,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          deleteIconColor: Colors.white,
          onDeleted: () {
            setState(() {
              _added.removeWhere((entry) {
                return entry.userName == user.userName;
              });
            });
          },
        ),
      );
    }
  }

  Widget _userTile(UserModel user) {
    return ListTile(
      onTap: () {
        if (_added.length < 10) {
          FocusScope.of(context).unfocus();
          setState(() {
            _searchController.text = '';
            _added.add(user);
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('No puedes agregar más de 10 miembros al grupo'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'),
                )
              ],
            ),
          );
        }
      },
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
          InfluencerBadge(user.userName, user.certificate, 16),
        ],
      ),
      subtitle: Text('@${user.userName}'),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_groups')),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: Translations.of(context).text('hint_group'),
                    ),
                    maxLength: 50,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (_added.isNotEmpty) Text('Miembros (máx. 10)'),
                  Wrap(
                    children: chipWidgets.toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: Translations.of(context).text('hint_search'),
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide:
                            BorderSide(color: Color(0xFFBBBBBB), width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide:
                            BorderSide(color: Color(0xFFBBBBBB), width: 2),
                      ),
                    ),
                  ),
                  for (var i in _searchList) _userTile(i),
                  const SizedBox(height: 58),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _isLoading
                ? CircularProgressIndicator()
                : Container(
                    width: double.infinity,
                    height: 42,
                    margin: const EdgeInsets.all(16),
                    child: RaisedButton(
                      onPressed: _validate,
                      textColor: Colors.white,
                      child: Text(Translations.of(context).text('button_save')),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

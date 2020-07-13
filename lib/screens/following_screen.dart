import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'view_profile_screen.dart';
import '../translations.dart';

class FollowingScreen extends StatefulWidget {
  final userId;

  FollowingScreen(this.userId);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  TextEditingController _controller = new TextEditingController();
  List documents;
  bool _isLoading = false;
  String _filter;

  void _toProfile(userId) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.uid != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot usersSnap = await Firestore.instance
        .collection('users')
        .where('followers', arrayContains: widget.userId)
        .orderBy('user_name')
        .getDocuments();

    setState(() {
      documents = usersSnap.documents;
      _isLoading = false;
    });
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

  Widget _userTile(doc) {
    return ListTile(
      onTap: () => _toProfile(doc.documentID),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(doc['image'] ?? ''),
      ),
      title: Text('${doc['name']} ${doc['last_name']}'),
      subtitle: Text('@${doc['user_name']}'),
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
          : (documents.isEmpty)
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
                        itemCount: documents.length,
                        itemBuilder: (ctx, i) {
                          final doc = documents[i];

                          return _filter == null || _filter == ""
                              ? Column(
                                  children: <Widget>[
                                    _userTile(doc),
                                    Divider(),
                                  ],
                                )
                              : doc['user_name']
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import '../translations.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _toFollowers() {}

  void _toFollowing() {}

  void _toEdit() {}

  Widget _usersWidget(amount, type, action) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: action,
        child: Column(
          children: <Widget>[
            Text(
              '$amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget _anonymousView(context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.person,
            color: Theme.of(context).accentColor,
            size: 120,
          ),
          SizedBox(height: 22),
          Text(
            'Registrate para tener un perfil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 22),
          Container(
            height: 42,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            child: RaisedButton(
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(AuthScreen.routeName);
              },
              child: Text('Registrarse'),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_profile')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _toEdit,
          )
        ],
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ct, AsyncSnapshot<FirebaseUser> userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnap.data.isAnonymous) {
            return _anonymousView(context);
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(userSnap.data.uid)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final document = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(document['image'] ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${document['name']} ${document['last_name']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      '@${document['user_name']}',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    Text(document['bio'] ?? ''),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _usersWidget(
                          50,
                          Translations.of(context).text('label_following'),
                          _toFollowing,
                        ),
                        _usersWidget(
                          120,
                          Translations.of(context).text('label_followers'),
                          _toFollowers,
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

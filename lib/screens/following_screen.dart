import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'view_profile_screen.dart';
import '../translations.dart';

class FollowingScreen extends StatelessWidget {
  static const routeName = '/following';

  void _toProfile(context, userId) {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('label_following')),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .where('followers', arrayContains: userId)
            .orderBy('user_name')
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data.documents;
          if (documents.isEmpty) {
            return Center(
              child: Text(Translations.of(context).text('empty_following')),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: documents.length,
            itemBuilder: (ctx, i) {
              final doc = documents[i];

              return ListTile(
                onTap: () => _toProfile(context, doc.documentID),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(doc['image'] ?? ''),
                ),
                title: Text('${doc['name']} ${doc['last_name']}'),
                subtitle: Text('@${doc['user_name']}'),
              );
            },
          );
        },
      ),
    );
  }
}

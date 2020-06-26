import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';
import '../widgets/appbar.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Text(Translations.of(context).text('title_messages')),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('messages')
                //.where('users', arrayContains: userSnap.data.uid)
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final documents = snapshot.data.documents;
              if (documents.isEmpty) {
                return Center(
                  child: Text(Translations.of(context).text('empty_messages')),
                );
              }

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (ctx, i) => Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      title: Text(documents[i]['title']),
                      subtitle: Text(documents[i]['content']),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/appbar.dart';
import '../widgets/poll.dart';

class PollsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Image.asset(
          'assets/logo.png',
          width: 42,
        ),
        true,
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: Firestore.instance
                .collection('polls')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final documents = snapshot.data.documents;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (ctx, i) {
                  final doc = documents[i];
                  int vote = -1;
                  bool hasVoted = false;
                  int voters = 0;
                  if (doc['voters'] != null) {
                    voters = doc['voters'].length;
                    final item = (doc['voters'] as List).firstWhere(
                      (element) =>
                          (element as Map).containsKey(userSnap.data.uid),
                      orElse: () => null,
                    );
                    if (item != null) {
                      hasVoted = true;
                      vote = item[userSnap.data.uid];
                    }
                  }
                  return Poll(
                    userId: userSnap.data.uid,
                    reference: doc.reference,
                    title: doc['title'],
                    comments: doc['comments'],
                    options: doc['options'],
                    votes: doc['results'],
                    hasVoted: hasVoted,
                    vote: vote,
                    voters: voters,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

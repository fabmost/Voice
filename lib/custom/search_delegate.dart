import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/search_poll.dart';
import '../widgets/search_challenge.dart';
import '../widgets/search_cause.dart';
import '../screens/view_profile_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  Algolia algolia;
  List<AlgoliaObjectSnapshot> items;
  String userId;

  CustomSearchDelegate() {
    FirebaseAuth.instance.currentUser().then((value) {
      userId = value.uid;
    });
    algolia = Algolia.init(
      applicationId: 'J3C3F33D3S',
      apiKey: '70469e6182ac069696c17d836c210780',
    );
  }

  Widget _pollWidget(id, doc) {
    final time = Timestamp(doc['createdAt']['_seconds'], doc['createdAt']['_nanoseconds']);
    return SearchPoll(
      reference: Firestore.instance.collection('content').document(id),
      myId: userId,
      userId: doc['user_id'],
      creatorName: doc['user_name'],
      creatorImage: doc['user_image'] ?? '',
      title: doc['title'],
      options: doc['options'],
      images: doc['images'] ?? [],
      date: time.toDate()
    );
  }

  Widget _challengeWidget(id, doc) {
    final time = Timestamp(doc['createdAt']['_seconds'], doc['createdAt']['_nanoseconds']);
    return SearchChallenge(
      reference: Firestore.instance.collection('content').document(id),
      myId: userId,
      userId: doc['user_id'],
      creatorName: doc['user_name'],
      creatorImage: doc['user_image'] ?? '',
      title: doc['title'],
      metric: doc['metric_type'],
      date: time.toDate(),
    );
  }

  Widget _causeWidget(id, doc) {
    return SearchCause(
      reference: Firestore.instance.collection('content').document(id),
      myId: userId,
      title: doc['title'],
      creator: doc['creator'],
      info: doc['info'],
    );
  }

  Widget _tagTile(context, doc) {
    return ListTile(
      onTap: () {
        query = doc['name'];
        showResults(context);
      },
      leading: CircleAvatar(
        child: Text('#'),
      ),
      title: Text(
        doc['name'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text('${doc['interactions']} objetos'),
    );
  }

  Widget _userTile(context, id, doc) {
    return ListTile(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ViewProfileScreen.routeName, arguments: id);
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(doc['user_image'] ?? ''),
      ),
      title: Text(
        doc['name'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(doc['user_name']),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    AlgoliaQuery searchQuery = algolia.instance.index('content');
    searchQuery = searchQuery.search(query);

    return FutureBuilder(
      future: searchQuery.getObjects(),
      builder: (ct, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.hits.length == 0) {
          return Center(
            child: Text('Sin resultados'),
          );
        }
        var results = snapshot.data.hits;
        items = snapshot.data.hits;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            AlgoliaObjectSnapshot result = results[index];
            switch (result.data['type']) {
              case 'poll':
                return _pollWidget(result.objectID, result.data);
              case 'challenge':
                return _challengeWidget(result.objectID, result.data);
              case 'cause':
                return _causeWidget(result.objectID, result.data);
              default:
                return SizedBox();
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return Container();
    }

    AlgoliaQuery searchQuery = algolia.instance.index('suggestions');
    searchQuery = searchQuery.search(query);

    return FutureBuilder(
      future: searchQuery.getObjects(),
      builder: (ct, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.hits.length == 0) {
          return Center(
            child: Text('Sin resultados'),
          );
        }
        var results = snapshot.data.hits;
        items = snapshot.data.hits;
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            AlgoliaObjectSnapshot result = results[index];
            if (result.data['interactions'] != null) {
              return _tagTile(context, result.data);
            } else {
              return _userTile(context, result.objectID, result.data);
            }
          },
        );
      },
    );
  }
}

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/search_poll.dart';
import '../widgets/search_challenge.dart';
import '../widgets/search_cause.dart';

class SearchResultsScreen extends StatelessWidget {
  static const routeName = '/search-results';

  Widget _pollWidget(id, doc) {
    final time = Timestamp(
        doc['createdAt']['_seconds'], doc['createdAt']['_nanoseconds']);
    return SearchPoll(
        reference: Firestore.instance.collection('content').document(id),
        userId: doc['user_id'],
        creatorName: doc['user_name'],
        creatorImage: doc['user_image'] ?? '',
        title: doc['title'],
        description: doc['description'] ?? '',
        options: doc['options'],
        images: doc['images'] ?? [],
        influencer: doc['influencer'] ?? '',
        date: time.toDate());
  }

  Widget _challengeWidget(id, doc) {
    final time = Timestamp(
        doc['createdAt']['_seconds'], doc['createdAt']['_nanoseconds']);
    return SearchChallenge(
      reference: Firestore.instance.collection('content').document(id),
      userId: doc['user_id'],
      creatorName: doc['user_name'],
      creatorImage: doc['user_image'] ?? '',
      title: doc['title'],
      description: doc['description'] ?? '',
      metric: doc['metric_type'],
      influencer: doc['influencer'] ?? '',
      date: time.toDate(),
    );
  }

  Widget _causeWidget(id, doc) {
    return SearchCause(
      reference: Firestore.instance.collection('content').document(id),
      title: doc['title'],
      creator: doc['creator'],
      info: doc['info'],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String query = ModalRoute.of(context).settings.arguments;
    Algolia algolia = Algolia.init(
      applicationId: 'J3C3F33D3S',
      apiKey: '70469e6182ac069696c17d836c210780',
    );
    AlgoliaQuery searchQuery = algolia.instance.index('content');
    searchQuery = searchQuery.search(query);
    return Scaffold(
      appBar: AppBar(
        title: Text(query),
      ),
      body: FutureBuilder(
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
          //items = snapshot.data.hits;
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
      ),
    );
  }
}

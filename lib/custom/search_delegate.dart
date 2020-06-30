import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  Algolia algolia;
  List<AlgoliaObjectSnapshot> items;

  CustomSearchDelegate() {
    algolia = Algolia.init(
      applicationId: 'J3C3F33D3S',
      apiKey: '70469e6182ac069696c17d836c210780',
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
    if (items == null) {
      return Container();
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        AlgoliaObjectSnapshot result = items[index];
        return ListTile(
          title: Text(result.data['name']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return Container();
    }

    AlgoliaQuery searchQuery = algolia.instance.index('Tags');
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
            return ListTile(
              title: Text(result.data['name']),
            );
          },
        );
      },
    );
  }
}

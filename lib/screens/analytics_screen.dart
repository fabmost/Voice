import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'view_profile_screen.dart';
import '../widgets/vote_card.dart';

class AnalyticsScreen extends StatefulWidget {
  static const routeName = '/analytics';

  final pollId;

  AnalyticsScreen(this.pollId);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = false;
  int _selection = -1;
  String _title;
  List _options;
  //List _votes;
  List _results;
  List _voters;

  void _toProfile(userId) async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.uid != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userId);
    }
  }

  void _getAllData() async {
    DocumentSnapshot pollDoc = await Firestore.instance
        .collection('content')
        .document(widget.pollId)
        .get();

    QuerySnapshot usersSnap = await Firestore.instance
        .collection('users')
        .where('voted', arrayContains: widget.pollId)
        .getDocuments();

    setState(() {
      _isLoading = false;
      _title = pollDoc.data['title'];
      _options = pollDoc.data['options'];
      //_votes = pollDoc.data['results'];
      _results = pollDoc.data['voters'] ?? [];
      _voters = usersSnap.documents ?? [];
    });
  }

  void _selectOption(position) {
    setState(() {
      if (_selection == position) {
        _selection = -1;
      } else {
        _selection = position;
      }
    });
  }

  @override
  void initState() {
    _getAllData();
    setState(() {
      _isLoading = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Estadísticos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemCount: _options.length,
                    itemBuilder: (context, i) {
                      Map option = _options[i];
                      int amount = 0;
                      _results.forEach((element) {
                        int vote =
                            int.parse((element as Map).values.first.toString());
                        if (vote == i) {
                          amount++;
                        }
                      });
                      return VoteCard(
                        option['text'],
                        amount,
                        _selection == i,
                        () => _selectOption(i),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Votantes',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _voters.length,
                    itemBuilder: (context, i) {
                      final user = _voters[i];
                      final userId = user.documentID;

                      int votePos;
                      String vote;

                      final item = _results.firstWhere(
                        (element) => (element as Map).containsKey(userId),
                        orElse: () => null,
                      );
                      if (item != null) {
                        votePos = item[userId];
                        vote = _options[votePos]['text'];
                      }

                      if (user.data['user_name'] == null) {
                        if (_selection == -1 || votePos == _selection) {
                          return ListTile(
                            title: Text('Anónimo'),
                            subtitle: Text('Votó - $vote'),
                          );
                        }
                        return Container();
                      }

                      final userName = user.data['user_name'];
                      final userImage = user.data['image'] ?? '';

                      if (_selection == -1 || votePos == _selection) {
                        return ListTile(
                          onTap: () => _toProfile(userId),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(userImage),
                          ),
                          title: Text(userName),
                          subtitle: Text('Votó - $vote'),
                        );
                      }
                      return Container();
                    },
                  ),
                )
              ],
            ),
    );
  }
}

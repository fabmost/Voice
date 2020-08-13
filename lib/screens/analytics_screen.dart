import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_profile_screen.dart';
import '../providers/content_provider.dart';
import '../widgets/vote_card.dart';
import '../models/poll_answer_model.dart';
import '../models/user_model.dart';

class AnalyticsScreen extends StatefulWidget {
  final String pollId;
  final String title;
  final List<PollAnswerModel> answers;

  AnalyticsScreen({this.pollId, this.title, this.answers});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = false;
  int _selection = -1;
  List<UserModel> _voters = [];
  Map _answersString = {};

  void _toProfile(userId) async {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  void _getAllData() async {
    final results = await Provider.of<ContentProvider>(context, listen: false).getPollStatistics(
      idPoll: widget.pollId,
      page: 0,
      idAnswer: null,
    );
    setState(() {
      _isLoading = false;
      _voters = results;
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
    widget.answers.forEach((element) { 
      _answersString[element.id] = element.answer;
    });
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
      body: ListView.builder(
        itemCount: _isLoading ? _voters.length + 4 : _voters.length + 3,
        itemBuilder: (context, i) {
          if (i == 0)
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          if (i == 1)
            return Container(
              height: 80,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemCount: widget.answers.length,
                itemBuilder: (context, i) {
                  PollAnswerModel option = widget.answers[i];
                  return VoteCard(
                    option.answer,
                    option.count,
                    _selection == i,
                    () => _selectOption(i),
                  );
                },
              ),
            );
          if (i == 2)
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Votantes',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel user = _voters[i - 3];
          return ListTile(
            onTap: () => _toProfile(user.userName),
            leading: CircleAvatar(
              backgroundImage:
                  user.icon == null ? null : NetworkImage(user.icon),
            ),
            title: Text(user.userName),
            subtitle: Text('Votó - ${_answersString[user.idAnswer]}'),
          );

/*
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
                      */
        },
      ),
    );
  }
}

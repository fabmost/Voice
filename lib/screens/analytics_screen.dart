import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_profile_screen.dart';
import '../providers/content_provider.dart';
import '../widgets/vote_card.dart';
import '../widgets/vote_card_satisfaction.dart';
import '../models/poll_answer_model.dart';
import '../models/user_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class AnalyticsScreen extends StatefulWidget {
  final String pollId;
  final String title;
  final List<PollAnswerModel> answers;
  final bool isSatisfaction;

  AnalyticsScreen({
    this.pollId,
    this.title,
    this.answers,
    @required this.isSatisfaction,
  });

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  ScrollController _scrollController = ScrollController();
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  bool _isLoading = false;
  int _selection = -1;
  int _page;
  List<UserModel> _voters = [];
  Map _answersString = {};
  Map _caritasString = {};
  bool _hasMore = true;

  final images = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
  ];

  void _toProfile(userId) async {
    Navigator.of(context)
        .pushNamed(ViewProfileScreen.routeName, arguments: userId);
  }

  void _getAllData() async {
    loadMoreStatus = LoadMoreStatus.LOADING;
    _voters.clear();
    _page = 0;
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });
    final results = await Provider.of<ContentProvider>(context, listen: false)
        .getPollStatistics(
      idPoll: widget.pollId,
      page: _page,
      idAnswer: _selection == -1 ? null : widget.answers[_selection].id,
    );
    setState(() {
      if (results.isEmpty || results.length < 10) {
        _hasMore = false;
      }
      _isLoading = false;
      _voters = results;
      loadMoreStatus = LoadMoreStatus.STABLE;
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
    _getAllData();
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (_scrollController.position.maxScrollExtent >
              _scrollController.offset &&
          _scrollController.position.maxScrollExtent -
                  _scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _page++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ContentProvider>(context, listen: false)
              .getPollStatistics(
            idPoll: widget.pollId,
            page: _page,
            idAnswer: _selection == -1 ? null : widget.answers[_selection].id,
          )
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
              } else {
                if (newObjects.length < 10) {
                  _hasMore = false;
                }
                _voters.addAll(newObjects);
              }
            });
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  @override
  void initState() {
    int pos = 0;
    widget.answers.forEach((element) {
      _answersString[element.id] = element.answer;
      _caritasString[element.id] = images[pos];
      pos++;
    });
    _getAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Estadísticos'),
      ),
      body: NotificationListener(
        onNotification: onNotification,
        child: ListView.builder(
          controller: _scrollController,
          itemCount:
              _isLoading || _hasMore ? _voters.length + 4 : _voters.length + 3,
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
                height: 100,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 8),
                  itemCount: widget.answers.length,
                  itemBuilder: (context, i) {
                    PollAnswerModel option = widget.answers[i];
                    return widget.isSatisfaction
                        ? VoteCardSatisfaction(
                            widget.pollId,
                            option.id,
                            i,
                            _selection == i,
                            () => _selectOption(i),
                          )
                        : VoteCard(
                            widget.pollId,
                            option.id,
                            option.answer,
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
            if (_isLoading || i == _voters.length + 3) {
              return Center(child: CircularProgressIndicator());
            }
            if (!_isLoading && _voters.isEmpty) {
              return Center(child: Text('Nadie ha votado por esta opción'));
            }
            UserModel user = _voters[i - 3];
            bool isAnon = user.userName.contains('ANONIMO');
            return ListTile(
              onTap: () => isAnon ? null : _toProfile(user.userName),
              leading: CircleAvatar(
                backgroundImage:
                    user.icon == null ? null : NetworkImage(user.icon),
              ),
              title: isAnon ? Text('Usuario anónimo') : Text(user.userName),
              subtitle: widget.isSatisfaction
                  ? Row(
                      children: [
                        const Text('Votó'),
                        const SizedBox(width: 5),
                        Image.asset(_caritasString[user.idAnswer], width: 16),
                      ],
                    )
                  : Text('Votó - ${_answersString[user.idAnswer]}'),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poll_model.dart';
import '../models/poll_answer_model.dart';
import '../providers/content_provider.dart';

class VoteCardSatisfaction extends StatelessWidget {
  final _pollId;
  final _answerId;
  final _position;
  final _selected;
  final _action;

  final images = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
  ];

  VoteCardSatisfaction(this._pollId, this._answerId, this._position,
      this._selected, this._action);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _selected ? Colors.grey : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).accentColor, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _action,
        child: Container(
          width: 150,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                images[_position],
                width: 52,
              ),
              Consumer<ContentProvider>(builder: (context, value, child) {
                PollModel poll = value.getPolls[_pollId];
                PollAnswerModel mAnswer = poll.answers
                    .firstWhere((element) => element.id == _answerId);
                return Text(
                  '${mAnswer.count}',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

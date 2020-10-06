import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poll_model.dart';
import '../models/poll_answer_model.dart';
import '../providers/content_provider.dart';

class VoteCard extends StatelessWidget {
  final _pollId;
  final _answerId;
  final _title;
  final _selected;
  final _action;

  VoteCard(this._pollId, this._answerId, this._title, this._selected, this._action);

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
              Consumer<ContentProvider>(
                builder: (context, value, child) {
                  PollModel poll = value.getPolls[_pollId];
                  PollAnswerModel mAnswer = poll.answers.firstWhere((element) => element.id == _answerId);
                  return Text(
                    '${mAnswer.count}',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              ),
              AutoSizeText(
                'Votos por $_title',
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

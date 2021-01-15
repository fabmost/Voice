import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/poll_model.dart';
import '../models/poll_answer_model.dart';
import '../providers/content_provider.dart';

class PollAnswersFaces extends StatelessWidget {
  final String id;
  final bool isMine;
  final Function setVote;

  final images = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
  ];

  PollAnswersFaces(this.id, this.isMine, this.setVote);

  Widget _option(idAnswer, position, width) {
    return InkWell(
      onTap: () => setVote(idAnswer, position),
      child: Image.asset(
        images[position],
        width: width - 8,
      ),
    );
  }

  Widget _optionVoted(context, votes, position, isVote, amount, width) {
    var totalPercentage = (amount == 0.0) ? 0.0 : amount / votes;
    if (totalPercentage > 1) {
      totalPercentage = 1;
    }
    final format = NumberFormat('###.##');
    return Column(
      children: [
        Image.asset(
          images[position],
          width: width - 8,
        ),
        const SizedBox(height: 5),
        Text(
          '${format.format(totalPercentage * 100)}%',
          style: TextStyle(
            color: isVote ? Theme.of(context).primaryColor : Colors.black,
            fontWeight: isVote ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _getOptions(
    context,
    votes,
    _hasVoted,
    List<PollAnswerModel> _answers,
    width,
  ) {
    int pos = -1;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _answers.map((option) {
          pos++;
          return _hasVoted
              ? _optionVoted(
                  context, votes, pos, option.isVote, option.count, width)
              : _option(option.id, pos, width);
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    final caritaWidth = (MediaQuery.of(context).size.width - 96) / 5;
    return Consumer<ContentProvider>(builder: (context, value, child) {
      PollModel poll = value.getPolls[id];
      return _getOptions(
        context,
        poll.votes,
        isMine ? isMine : poll.hasVoted,
        poll.answers,
        caritaWidth,
      );
    });
  }
}

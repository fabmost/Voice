import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_answers.dart';
import '../mixins/alert_mixin.dart';
import '../providers/content_provider.dart';
import '../providers/auth_provider.dart';

class PollOptions extends StatefulWidget {
  final String id;
  final bool isMine;

  PollOptions({
    @required this.id,
    @required this.isMine,
  });

  @override
  _PollOptionsState createState() => _PollOptionsState();
}

class _PollOptionsState extends State<PollOptions> with AlertMixin {
  bool _isLoading = false;
  
  void _setVote(idAnswer, position) async {
    bool canInteract =
        await Provider.of<AuthProvider>(context, listen: false).canInteract();
    if (!canInteract) {
      anonymousAlert(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ContentProvider>(context, listen: false)
        .votePoll(widget.id, idAnswer);
    /*
    final selected = _answers.firstWhere((element) => element.id == idAnswer);
    final newAnswer = PollAnswerModel(
      id: idAnswer,
      answer: selected.answer,
      count: selected.count + 1,
      isVote: true,
      url: selected.url,
    );
    */
    setState(() {
      // _votes++;
      // _answers[position] = newAnswer;
      // _hasVoted = true;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : PollAnswers(
            widget.id,
            widget.isMine,
            _setVote,
          );
  }
}

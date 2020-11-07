import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_answers.dart';
import 'alert_promo.dart';
import '../mixins/alert_mixin.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class PollOptions extends StatefulWidget {
  final String id;
  final bool isMine;
  final String terms;
  final String promoUrl;
  final String message;
  final bool isSecret;
  final Function function;

  PollOptions({
    @required this.id,
    @required this.isMine,
    this.terms,
    this.promoUrl,
    this.message,
    this.isSecret = false,
    this.function,
  });

  @override
  _PollOptionsState createState() => _PollOptionsState();
}

class _PollOptionsState extends State<PollOptions> with AlertMixin {
  bool _isLoading = false;

  void _setVote(idAnswer, position) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ContentProvider>(context, listen: false).votePoll(
      widget.id,
      idAnswer,
    );

    if(widget.isSecret){
      widget.function();
    }

    setState(() {
      _isLoading = false;
    });

    if (widget.message != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertPromo(
          terms: widget.terms,
          message: widget.message,
          url: widget.promoUrl,
        ),
      );
    }
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

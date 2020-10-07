import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_answers.dart';
import 'alert_promo.dart';
import '../mixins/alert_mixin.dart';
import '../providers/content_provider.dart';
import '../providers/auth_provider.dart';

class PollOptions extends StatefulWidget {
  final String id;
  final bool isMine;
  final String company;
  final String promoUrl;
  final String message;
  final String prize;

  PollOptions({
    @required this.id,
    @required this.isMine,
    this.company,
    this.promoUrl,
    this.message,
    this.prize,
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

    setState(() {
      _isLoading = false;
    });

    if (widget.company != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertPromo(
          business: widget.company,
          message: widget.message,
          prize: widget.prize,
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

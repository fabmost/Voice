import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/poll_answer_model.dart';
import '../providers/preferences_provider.dart';
import '../providers/content_provider.dart';
import '../screens/auth_screen.dart';

class PollOptions extends StatefulWidget {
  final String id;
  final int votes;
  final bool hasVoted;
  final List<PollAnswerModel> answers;

  PollOptions({
    @required this.id,
    @required this.votes,
    @required this.hasVoted,
    @required this.answers,
  });

  @override
  _PollOptionsState createState() => _PollOptionsState();
}

class _PollOptionsState extends State<PollOptions> {
  bool _hasVoted;
  bool _isLoading = false;
  List<PollAnswerModel> _answers;

  void _anonymousAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Para seguir utilizando Galup debes crear una cuenta'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text('Cancelar'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }

  void _setVote(idAnswer, position) async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ContentProvider>(context, listen: false)
        .votePoll(widget.id, idAnswer);
    final selected = _answers.firstWhere((element) => element.id == idAnswer);
    final newAnswer = PollAnswerModel(
      id: idAnswer,
      answer: selected.answer,
      count: selected.count + 1,
      isVote: true,
      url: selected.url,
    );
    setState(() {
      _answers[position] = newAnswer;
      _hasVoted = true;
      _isLoading = false;
    });
  }

  Widget _getOptions() {
    int pos = -1;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _answers.map(
          (option) {
            pos++;
            if (option.url != null) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(option.url),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _hasVoted
                            ? _voted(option.answer, option.isVote, pos)
                            : _poll(
                                option.answer,
                                option.id,
                                pos,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: _hasVoted
                      ? _voted(option.answer, option.isVote, option.count)
                      : _poll(
                          option.answer,
                          option.id,
                          pos,
                        ),
                ),
                SizedBox(height: 8),
              ],
            );
          },
        ).toList());
  }

  Widget _poll(option, idAnswer, position) {
    return FlatButton(
      child: Text(option),
      onPressed: () => _setVote(idAnswer, position),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Theme.of(context).primaryColor)),
    );
  }

  Widget _voted(answer, isVote, amount) {
    var totalPercentage = (amount == 0.0) ? 0.0 : amount / widget.votes;
    if (totalPercentage > 1) {
      totalPercentage = 1;
    }
    final format = NumberFormat('###.##');
    return Container(
      height: 42,
      child: Stack(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: totalPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xAA6767CB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  topRight:
                      totalPercentage == 1 ? Radius.circular(12) : Radius.zero,
                  bottomRight:
                      totalPercentage == 1 ? Radius.circular(12) : Radius.zero,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ListTile(
              dense: true,
              title: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVote)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                ],
              ),
              trailing: Text(
                '${format.format(totalPercentage * 100)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _hasVoted = widget.hasVoted;
    _answers = widget.answers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _getOptions();
  }
}

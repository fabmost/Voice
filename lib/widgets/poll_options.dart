import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/poll_answer_model.dart';
import '../providers/preferences_provider.dart';
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
  bool _isLoading = false;

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

  void _setVote(position) async {
    /*
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      final interactions =
          await Provider.of<Preferences>(context, listen: false)
              .getInteractions();
      if (interactions >= 5) {
        _anonymousAlert();
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });

    WriteBatch batch = Firestore.instance.batch();

    batch
        .updateData(Firestore.instance.collection('users').document(user.uid), {
      'voted': FieldValue.arrayUnion(
        [widget.reference.documentID],
      )
    });
    batch.updateData(widget.reference, {
      'interactions': FieldValue.increment(1),
      'voters': FieldValue.arrayUnion([
        {widget.userId: position}
      ]),
    });

    await batch.commit();
    /*
    await Firestore.instance.runTransaction((transaction) {
      return transaction.get(widget.reference).then((value) {
        List results = value.data['results'];
        Map result = results[position];
        result['votes']++;
        transaction.update(widget.reference, {
          "results": results,
        });
      });
    });
    */
    Provider.of<Preferences>(context, listen: false).setInteractions();
    setState(() {
      _isLoading = false;
    });
    */
  }

  Widget _getOptions() {
    int pos = -1;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.answers.map(
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
                        child: widget.hasVoted
                            ? _voted(option.answer, option.isVote, pos)
                            : _poll(option.answer, pos),
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
                  child: widget.hasVoted
                      ? _voted(option.answer, option.isVote, pos)
                      : _poll(
                          option.answer,
                          pos,
                        ),
                ),
                SizedBox(height: 8),
              ],
            );
          },
        ).toList());
  }

  Widget _poll(option, position) {
    return FlatButton(
      child: Text(option),
      onPressed: () => _setVote(position),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Theme.of(context).primaryColor)),
    );
  }

  Widget _voted(answer, isVote, position) {
    int amount = 0;
    widget.answers.forEach((element) {
      int vote = element.count;
      if (vote == position) {
        amount++;
      }
    });
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
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _getOptions();
  }
}

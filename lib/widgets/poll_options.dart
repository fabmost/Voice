import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/preferences_provider.dart';
import '../screens/auth_screen.dart';

class PollOptions extends StatefulWidget {
  final DocumentReference reference;
  final String userId;
  final List options;
  final List votes;
  final bool hasVoted;
  final int vote;
  final int voters;

  PollOptions({
    this.reference,
    this.userId,
    this.options,
    this.votes,
    this.hasVoted,
    this.vote,
    this.voters,
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
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    await Firestore.instance.collection('users').document(user.uid).updateData({
      'voted': FieldValue.arrayUnion(
        [widget.reference.documentID],
      )
    });
    await widget.reference.updateData({
      'interactions': FieldValue.increment(1),
      "voters": FieldValue.arrayUnion([
        {widget.userId: position}
      ])
    });
    await Firestore.instance.runTransaction((transaction) {
      return transaction.get(widget.reference).then((value) {
        List results = value.data['results'];
        Map result = results[position];
        result['votes']++;
        if (userData.data['country'] != null &&
            userData.data['country'].isNotEmpty) {
          if (result['countries'].containsKey(userData.data['country'])) {
            result['countries'][userData.data['country']]++;
          } else {
            result['countries'][userData.data['country']] = 1;
          }
        }
        if (userData.data['gender'] != null &&
            userData.data['gender'].isNotEmpty) {
          if (result['gender'].containsKey(userData.data['gender'])) {
            result['gender'][userData.data['gender']]++;
          } else {
            result['gender'][userData.data['gender']] = 1;
          }
        }
        if (userData.data['birthday'] != null &&
            userData.data['birthday'].isNotEmpty) {
          DateTime userDate =
              DateFormat('dd-MM-yyyy').parse(userData.data['birthday']);
          int years =
              ((DateTime.now().difference(userDate).inDays) / 365).floor();
          String yearsString;
          if (years <= 18) {
            yearsString = '-18';
          } else if (years > 18 && years <= 30) {
            yearsString = '18-30';
          } else if (years > 30 && years <= 40) {
            yearsString = '30-40';
          } else {
            yearsString = '40+';
          }
          if (result['age'].containsKey(yearsString)) {
            result['age'][yearsString]++;
          } else {
            result['age'][yearsString] = 1;
          }
        }
        transaction.update(widget.reference, {
          "results": results,
        });
      });
    });
    Provider.of<Preferences>(context, listen: false).setInteractions();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _getOptions() {
    int pos = -1;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.options.map(
          (option) {
            pos++;
            if (option.containsKey('image')) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(option['image']),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: widget.hasVoted
                            ? _voted(option['text'], pos)
                            : _poll(option['text'], pos),
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
                      ? _voted(option['text'], pos)
                      : _poll(
                          option['text'],
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

  Widget _voted(option, position) {
    final int amount = widget.votes[position]['votes'];
    var totalPercentage = (amount == 0.0) ? 0.0 : amount / widget.voters;
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
                      option,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.vote == position)
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

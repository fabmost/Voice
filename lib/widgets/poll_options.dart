import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                      CircleAvatar(backgroundImage: NetworkImage(option['image']),),
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
                          option['text'], pos,
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
      onPressed: ()=> _setVote(position),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).primaryColor)
      ),
    );
  }

  Widget _voted(option, position) {
    final int amount = widget.votes[position]['votes'];
    final totalPercentage = amount / widget.voters;
    final format = NumberFormat('###.##');
    return Container(
      height: 42,
      child: Stack(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: totalPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(option),
                  Text('${format.format(totalPercentage * 100)}%')
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _setVote(position){
    setState(() {
      _isLoading = true;
    });

    //WriteBatch batch;
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

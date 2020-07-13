import 'package:flutter/material.dart';

class VoteCard extends StatelessWidget {
  final _title;
  final _votes;
  final _selected;
  final _action;

  VoteCard(this._title, this._votes, this._selected, this._action);

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
              Text(
                '$_votes',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Votos por $_title',
                textAlign: TextAlign.center,
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

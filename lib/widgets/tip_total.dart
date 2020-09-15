import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'tip_rating.dart';

class TipTotal extends StatefulWidget {
  final String id;
  final double total;
  final bool hasRated;

  TipTotal({this.id, this.total, this.hasRated});

  @override
  _TipTotalState createState() => _TipTotalState();
}

class _TipTotalState extends State<TipTotal> {
  double _rating;
  bool _hasRated;

  void _rateAlert(context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: TipRating(widget.id, _saveRate),
      ),
    );
  }

  void _saveRate(context, newTotal) {
    Navigator.of(context).pop();
    setState(() {
      _rating = newTotal;
      _hasRated = true;
    });
  }

  @override
  void initState() {
    _rating = widget.total;
    _hasRated = widget.hasRated;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('###.#');
    return GestureDetector(
      onTap: () => _hasRated ? null : _rateAlert(context),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.star,
            color: _hasRated ? Theme.of(context).primaryColor : Colors.grey,
            size: 42,
          ),
          Container(
            margin: const EdgeInsets.only(top: 3),
            child: Text(
              '${format.format(_rating)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

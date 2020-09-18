import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'tip_rating.dart';
import '../models/tip_model.dart';
import '../providers/content_provider.dart';

class TipTotal extends StatelessWidget {
  final String id;
  final double total;
  final bool hasRated;

  TipTotal({this.id, this.total, this.hasRated});

  void _rateAlert(context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: TipRating(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('###.#');
    return Consumer<ContentProvider>(builder: (context, value, child) {
      TipModel tip = value.getTips[id];
      return GestureDetector(
        onTap: () => tip.hasRated ? null : _rateAlert(context),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.star,
              color:
                  tip.hasRated ? Theme.of(context).primaryColor : Colors.grey,
              size: 42,
            ),
            Container(
              margin: const EdgeInsets.only(top: 3),
              child: Text(
                '${format.format(tip.total)}',
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
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/cause_model.dart';

class CauseMeter extends StatelessWidget {
  final String id;

  CauseMeter(this.id);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, value, child) {
        CauseModel cause = value.getCausesList[id];
        var totalPercentage =
            (cause.likes == 0) ? 0.0 : cause.likes / cause.goal;
        if (totalPercentage > 1) totalPercentage = 1;
        final format = NumberFormat('###.##');
        return Container(
          height: 42,
          margin: EdgeInsets.all(16),
          child: Stack(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: totalPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                      bottomRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
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
                    children: <Widget>[
                      Text(
                        'Firmas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '${format.format(totalPercentage * 100)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

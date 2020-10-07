import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'alert_promo.dart';
import '../models/poll_model.dart';
import '../providers/content_provider.dart';

class PromoButton extends StatelessWidget {
  final String id;

  PromoButton(this.id);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, value, child) {
        PollModel poll = value.getPolls[id];
        if (poll.hasVoted) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: RaisedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertPromo(
                    business: poll.company,
                    message: poll.message,
                    prize: poll.prize,
                    url: poll.promoUrl,
                  ),
                );
              },
              color: Color(0xFFE56F0E),
              textColor: Colors.white,
              child: Text('Ver premio'),
            ),
          );
        }
        return Container();
      },
    );
  }
}

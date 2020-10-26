import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../mixins/alert_mixin.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class TipRating extends StatefulWidget {
  final String id;

  TipRating(this.id);

  @override
  _TipRatingState createState() => _TipRatingState();
}

class _TipRatingState extends State<TipRating> with AlertMixin {
  double _rating = 0;
  bool _isLoading = false;

  void _saveRate() async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ContentProvider>(context, listen: false)
        .rateTip(widget.id, _rating);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width / 9;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            Translations.of(context).text('dialog_rate'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          RatingBar(
            minRating: 1,
            maxRating: 5,
            allowHalfRating: true,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Theme.of(context).primaryColor,
            ),
            itemCount: 5,
            itemSize: size,
            unratedColor: Theme.of(context).primaryColor.withAlpha(50),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RaisedButton(
                    onPressed: _rating > 0 ? _saveRate : null,
                    textColor: Colors.white,
                    child: Text(Translations.of(context).text('button_save')),
                  ),
          ),
          Container(
            width: double.infinity,
            height: 42,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(Translations.of(context).text('button_cancel')),
            ),
          )
        ],
      ),
    );
  }
}

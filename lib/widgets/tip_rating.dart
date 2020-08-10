import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TipRating extends StatefulWidget {
  final DocumentReference reference;
  final Function saveRate;

  TipRating(this.reference, this.saveRate);

  @override
  _TipRatingState createState() => _TipRatingState();
}

class _TipRatingState extends State<TipRating> {
  double _rating = 0;
  bool _isLoading = false;

  void _saveRate() async {
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseAuth.instance.currentUser();
    await widget.reference.updateData({
      'rates': FieldValue.arrayUnion([
        {user.uid: _rating}
      ])
    });
    setState(() {
      _isLoading = false;
    });
    widget.saveRate(context);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width / 9;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
                    onPressed: _saveRate,
                    textColor: Colors.white,
                    child: Text('Guardar'),
                  ),
          ),
        ],
      ),
    );
  }
}

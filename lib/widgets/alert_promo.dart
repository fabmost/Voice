import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class AlertPromo extends StatelessWidget {
  final String business;
  final String url;
  final String prize;
  final String message;

  AlertPromo({
    @required this.business,
    @required this.url,
    @required this.message,
    @required this.prize,
  });

  static const double padding = 16.0;
  static const double avatarRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 22,
              bottom: avatarRadius + 22,
              right: 22,
              left: 22,
            ),
            margin: EdgeInsets.only(
              top: avatarRadius,
              left: padding,
              right: padding,
            ),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.network(
                    url,
                    height: 120,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '¡Gracias por responder la encuesta de $business!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'USERNAME: $user',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Premio: $prize',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              mini: true,
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

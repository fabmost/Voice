import 'package:flutter/material.dart';

class AlertPromo extends StatelessWidget {
  static const double padding = 16.0;
  static const double avatarRadius = 24.0;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.network(
                  'https://1000logos.net/wp-content/uploads/2017/05/Pepsi-Logo.png',
                  height: 120,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '¡Gracias por responder la encuesta de WOLF!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Presenta tu username en caja y solicita tu recompensa',
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
                    'USERNAME',
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
                  'Premio: Orden de alitas',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

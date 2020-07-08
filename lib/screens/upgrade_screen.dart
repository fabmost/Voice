import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeScreen extends StatelessWidget {
  static const routeName = '/upgrade';

  void _toStore(context) async {
    String url;
    if(Platform.isAndroid){
      url = 'https://play.google.com/store/apps/details?id=com.galup.app';
    }else if(Platform.isIOS){
      url = 'https://apps.apple.com/app/galup/id1521345975';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(42),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Image.asset('assets/splash.png', width: 120,),
            SizedBox(height: 42),
            Text(
              'Es necesario realizar una actualización',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Para continuar disfrutando de las encuestas, retos, diversión y todo lo que tenemos para ti es necesario realizar una actualización en el sistema',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 42),
            Container(
              width: double.infinity,
              height: 42,
              child: RaisedButton(
                onPressed: () => _toStore(context),
                textColor: Colors.white,
                child: Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

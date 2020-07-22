import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../translations.dart';
import '../providers/preferences_provider.dart';

class AppDrawer extends StatelessWidget {
  final String termsUrl = 'https://galup.app/terminos-y-condiciones';

  void _toTerms() async {
    if (await canLaunch(termsUrl)) {
      await launch(
        termsUrl,
      );
    }
  }

  void _signOut(context) {
    Provider.of<Preferences>(context, listen: false).setAccount();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 52),
          ListTile(
            onTap: _toTerms,
            title: Text(Translations.of(context).text('label_terms')),
          ),
          Divider(),
          ListTile(
            onTap: ()=> _signOut(context),
            title: Text(Translations.of(context).text('button_sign_out')),
          )
        ],
      ),
    );
  }
}

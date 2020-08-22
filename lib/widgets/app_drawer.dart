import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../translations.dart';
import '../providers/auth_provider.dart';
import '../mixins/share_mixin.dart';

class AppDrawer extends StatelessWidget with ShareContent {
  final String termsUrl = 'https://galup.app/terminos-y-condiciones';

  void _shareProfile() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    shareProfile(user.uid);
  }

  void _toTerms() async {
    if (await canLaunch(termsUrl)) {
      await launch(
        termsUrl,
      );
    }
  }

  void _signOut(context) async {
    Provider.of<AuthProvider>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 52),
          ListTile(
            onTap: _shareProfile,
            title: Text(Translations.of(context).text('button_share_profile')),
          ),
          ListTile(
            onTap: _toTerms,
            title: Text(Translations.of(context).text('label_terms')),
          ),
          Divider(),
          ListTile(
            onTap: () => _signOut(context),
            title: Text(Translations.of(context).text('button_sign_out')),
          )
        ],
      ),
    );
  }
}

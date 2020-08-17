import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../translations.dart';
import '../providers/preferences_provider.dart';
import '../mixins/share_mixin.dart';
import '../screens/saved_screen.dart';

class AppDrawer extends StatelessWidget with ShareContent {
  final String termsUrl = 'https://galup.app/terminos-y-condiciones';

  void _toSaved(context) async {
    Navigator.of(context).pushNamed(SavedScreen.routeName);
  }

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
    Provider.of<Preferences>(context, listen: false).setAccount();
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    List following = userData['following'] ?? [];
    following.forEach((element) async {
      await FirebaseMessaging().unsubscribeFromTopic(element);
    });
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 52),
          ListTile(
            onTap: ()=> _toSaved(context),
            title: Text('Guardados'),
          ),
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

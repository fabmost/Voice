import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../mixins/share_mixin.dart';
import '../screens/saved_screen.dart';
import '../screens/groups_screen.dart';

class AppDrawer extends StatelessWidget with ShareContent {
  final String termsUrl = 'https://galup.app/terminos-y-condiciones';

  void _toSaved(context) {
    Navigator.of(context).pushNamed(SavedScreen.routeName);
  }

  void _toGroups(context) {
    Navigator.of(context).pushNamed(GroupsScreen.routeName);
  }

  void _shareProfile(context) async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    shareProfile(context, user, null);
  }

  void _toTerms() async {
    if (await canLaunch(termsUrl)) {
      await launch(
        termsUrl,
      );
    }
  }

  void _signOut(context) async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 52),
          ListTile(
            onTap: () => _toSaved(context),
            leading: Icon(GalupFont.saved),
            title: Text(Translations.of(context).text('title_saved')),
          ),
          ListTile(
            onTap: () => _toGroups(context),
            leading: Icon(Icons.group),
            title: Text(Translations.of(context).text('title_groups')),
          ),
          ListTile(
            onTap: () => _shareProfile(context),
            leading: Icon(Icons.share),
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

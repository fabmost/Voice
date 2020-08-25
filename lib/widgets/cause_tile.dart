import 'package:flutter/material.dart';

import 'menu_content.dart';
import 'cause_button.dart';
import 'regalup_content.dart';
import '../mixins/share_mixin.dart';
import '../translations.dart';
import '../screens/auth_screen.dart';
import '../screens/flag_screen.dart';
import '../custom/galup_font_icons.dart';

class CauseTile extends StatelessWidget with ShareContent {
  final String id;
  final String userName;
  final String userImage;
  final DateTime date;
  final String title;
  final int likes;
  final int regalups;
  final bool hasLiked;
  final bool hasRegalup;
  final bool hasSaved;

  final Color color = Color(0xFFF0F0F0);

  CauseTile({
    this.id,
    this.userName,
    this.userImage,
    this.title,
    this.likes,
    this.hasLiked,
    this.regalups,
    this.hasRegalup,
    this.hasSaved,
    this.date,
  });

  void _infoAlert(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('info'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _anonymousAlert(context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text(Translations.of(context).text('button_cancel')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text(Translations.of(context).text('button_create_account')),
          ),
        ],
      ),
    );
  }

  void _share() async {
    shareCause(id, title);
  }

  void _flag(context) {
    /*
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
        */
  }

  void _setVote(test){

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: color,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'creator',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(width: 2),
                    IconButton(
                      icon: Icon(GalupFont.info_circled_alt),
                      onPressed: () => _infoAlert(context),
                    )
                  ],
                ),
                subtitle: Text('Por: Galup'),
                trailing: MenuContent(
                  id: id,
                  isSaved: hasSaved,
                  type: 'CA',
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            CauseButton(
              id: id,
              hasLike: hasLiked,
              setVotes: _setVote,
            ),
            SizedBox(height: 16),
            Container(
              color: color,
              child: Row(
                children: <Widget>[
                  RegalupContent(
                    id: id,
                    type: 'CA',
                    regalups: regalups,
                    hasRegalup: hasRegalup,
                  ),
                  IconButton(
                    icon: Icon(GalupFont.share),
                    onPressed: _share,
                  ),
                  Expanded(child: SizedBox(height: 1)),
                  Text(likes == 0 ? '' : '$likes Votos'),
                  SizedBox(width: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

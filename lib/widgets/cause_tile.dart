import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'description.dart';
import 'menu_content.dart';
import 'cause_button.dart';
import 'regalup_content.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';

class CauseTile extends StatelessWidget with ShareContent {
  final String id;
  final String userName;
  final String userImage;
  final String title;
  final String description;
  final String info;
  final DateTime date;
  final int likes;
  final int regalups;
  final bool hasLiked;
  final bool hasRegalup;
  final bool hasSaved;
  final int goal;
  final List resources;
  final String regalupName;
  final String phone;
  final String web;
  final String bank;

  final Color color = Color(0xFFF0F0F0);

  CauseTile({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.info,
    @required this.date,
    @required this.userName,
    @required this.userImage,
    @required this.likes,
    @required this.regalups,
    @required this.hasLiked,
    @required this.hasRegalup,
    @required this.hasSaved,
    @required this.goal,
    @required this.resources,
    this.regalupName,
    @required this.phone,
    @required this.web,
    @required this.bank,
  });

  void _call() async {
    if (await canLaunch('tel:$phone')) {
      await launch('tel:$phone');
    } else {
      throw 'Could not launch $phone';
    }
  }

  void _launchURL(String url) async {
    String newUrl = url;
    if (!url.contains('http')) {
      newUrl = 'http://$url';
    }
    if (await canLaunch(newUrl.trim())) {
      await launch(newUrl.trim());
    } else {
      throw 'Could not launch $newUrl';
    }
  }

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

  void _share() async {
    shareCause(id, title);
  }

  Widget _challengeGoal(context) {
    var totalPercentage = (likes == 0) ? 0.0 : likes / goal;
    if (totalPercentage > 1) totalPercentage = 1;
    final format = NumberFormat('###.##');

    return Column(
      children: [
        if (resources.isNotEmpty && resources[0].type == 'V')
          PollVideo(resources[0].url, null),
        if (resources.isNotEmpty && resources[0].type == 'I')
          PollImages([resources[0].url], null),
        Container(
          height: 42,
          margin: EdgeInsets.all(16),
          child: Stack(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: totalPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                      bottomRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Firmas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '${format.format(totalPercentage * 100)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _userTile(context) {
    final now = new DateTime.now();
    final difference = now.difference(date);
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).primaryColor,
        backgroundImage: info.isNotEmpty
            ? AssetImage('assets/logo.png')
            : userImage == null ? null : NetworkImage(userImage),
      ),
      title: info.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'creator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(width: 2),
                IconButton(
                  icon: Icon(GalupFont.info_circled_alt),
                  onPressed: () => _infoAlert(context),
                )
              ],
            )
          : Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                //InfluencerBadge(document['influencer'] ?? '', 16),
              ],
            ),
      subtitle: info.isNotEmpty
          ? Text('Por: Galup')
          : Text(timeago.format(now.subtract(difference))),
      trailing: MenuContent(
        id: id,
        isSaved: hasSaved,
        type: 'CA',
      ),
    );
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
              child: Column(
                children: [
                  if (regalupName != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            GalupFont.repost,
                            color: Colors.grey,
                            size: 12,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$regalupName Regalup',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _userTile(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            if (goal != null) _challengeGoal(context),
            if (goal != null) SizedBox(height: 16),
            if (description != null && description.isNotEmpty)
              Description(description),
            if (description != null && description.isNotEmpty)
              SizedBox(height: 16),
            CauseButton(
              id: id,
              hasLike: hasLiked,
              setVotes: null,
            ),
            if (phone != null)
              ListTile(
                onTap: _call,
                leading: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                title: Text('Contáctame'),
                subtitle: Text(phone),
              ),
            if (web != null)
              ListTile(
                onTap: () => _launchURL(web),
                leading: Icon(
                  Icons.open_in_browser,
                  color: Colors.black,
                ),
                title: Text('Visita'),
                subtitle: Text(web),
              ),
            if (bank != null)
              ListTile(
                leading: Icon(
                  Icons.credit_card,
                  color: Colors.black,
                ),
                title: Text('Donaciones'),
                subtitle: Text(bank),
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

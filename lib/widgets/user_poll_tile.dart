import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'title_content.dart';
import 'poll_images.dart';
import 'poll_video.dart';
import 'poll_options.dart';
import 'comment_content.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../mixins/share_mixin.dart';
import '../providers/content_provider.dart';
import '../screens/analytics_screen.dart';

class UserPollTile extends StatelessWidget with ShareContent {
  final String id;
  final String userName;
  final String userImage;
  final String title;
  final String description;
  final DateTime date;
  final int votes;
  final int likes;
  final int regalups;
  final int comments;
  final bool hasVoted;
  final bool hasLiked;
  final bool hasRegalup;
  final List answers;
  final List resources;
  final Function removeFunction;

  final Color color = Color(0xFFF8F8FF);

  UserPollTile({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.date,
    @required this.userName,
    @required this.userImage,
    @required this.votes,
    @required this.likes,
    @required this.regalups,
    @required this.comments,
    @required this.hasVoted,
    @required this.hasLiked,
    @required this.hasRegalup,
    @required this.answers,
    @required this.resources,
    @required this.removeFunction,
  });

  void _toAnalytics(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsScreen(
          pollId: id,
          title: title,
          answers: answers,
        ),
      ),
    );
  }

  void _share() {
    sharePoll(id, title);
  }

  void _deleteAlert(context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        content: Text('¿Seguro que deseas borrar esta encuesta?'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            child: Text(
              Translations.of(context).text('button_cancel'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(ct).pop();
            },
          ),
          FlatButton(
            textColor: Colors.red,
            child: Text(
              Translations.of(context).text('button_delete'),
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              _deleteContent(ct);
              Navigator.of(ct).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteContent(context) async {
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .deleteContent(id: id, type: 'P');
    if (result) {
      //Navigator.of(context).pop();
      removeFunction(id);
    }
  }

  void _options(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _deleteAlert(context),
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('button_delete'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _handleResources() {
    if (resources[0].type == 'V')
      return PollVideo(id, 'P', resources[0].url, null);
    List urls = resources.map((e) => e.url).toList();
    return PollImages(
      urls,
      'user',
      isClickable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    //final now = new DateTime.now();
    //final difference = now.difference(date);

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).accentColor, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: color,
              child: ListTile(
                title: OutlineButton(
                  onPressed: () => _toAnalytics(context),
                  child: Text('Estadísticas'),
                ),
                trailing: Transform.rotate(
                  angle: 270 * pi / 180,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => _options(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TitleContent(title),
            if (resources.isNotEmpty) SizedBox(height: 16),
            if (resources.isNotEmpty) _handleResources(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: PollOptions(
                id: id,
                isMine: true,
              ),
            ),
            if (votes > 0)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  bottom: 16,
                ),
                child: Text(votes == 1
                    ? '$votes participante'
                    : '$votes participantes'),
              ),
            Container(
              color: color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CommentContent(
                    id: id,
                    type: 'P',
                  ),
                  LikeContent(
                    id: id,
                    type: 'P',
                    likes: likes,
                    hasLiked: hasLiked,
                  ),
                  RegalupContent(
                    id: id,
                    type: 'P',
                    regalups: regalups,
                    hasRegalup: hasRegalup,
                  ),
                  IconButton(
                    icon: Icon(GalupFont.share),
                    onPressed: _share,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

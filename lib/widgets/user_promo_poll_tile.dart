import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'title_content.dart';
import 'poll_audio.dart';
import 'description.dart';
import 'poll_options.dart';
import 'promo_button.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'comment_content.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../screens/analytics_screen.dart';
import '../providers/content_provider.dart';
import '../models/poll_model.dart';
import '../models/resource_model.dart';

class UserPromoPollTile extends StatelessWidget with ShareContent {
  final String reference;
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
  final bool hasSaved;
  final List answers;
  final List resources;
  final String regalupName;
  final certificate;
  final String terms;
  final String promoUrl;
  final String message;
  final Function removeFunction;
  final ResourceModel audio;

  UserPromoPollTile({
    @required this.reference,
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
    @required this.hasSaved,
    @required this.answers,
    @required this.resources,
    @required this.certificate,
    this.regalupName,
    @required this.terms,
    @required this.promoUrl,
    @required this.message,
    @required this.removeFunction,
    @required this.audio,
  });

  final Color color = Color(0xFFFDF9F5);

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
    String image;
    if (userImage != null && userImage.isNotEmpty) {
      image = userImage;
    } else if (resources.isNotEmpty) {
      image = resources[0].url;
    }
    sharePromoPoll(id, title, image);
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
    return PollImages(urls, reference);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE56F0E), width: 0.5),
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
                  ListTile(
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
                ],
              ),
            ),
            SizedBox(height: 16),
            audio == null ? TitleContent(title) : PollAudio(audio),
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
                terms: terms,
                message: message,
                promoUrl: promoUrl,
              ),
            ),
            PromoButton(id, true),
            Consumer<ContentProvider>(
              builder: (context, value, child) {
                PollModel poll = value.getPolls[id];
                if (poll.votes > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      bottom: 16,
                    ),
                    child: Text(poll.votes == 1
                        ? '${poll.votes} participante'
                        : '${poll.votes} participantes'),
                  );
                }
                return Container();
              },
            ),
            if (description != null && description.trim().isNotEmpty)
              Description(description),
            if (description != null && description.trim().isNotEmpty)
              SizedBox(height: 16),
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

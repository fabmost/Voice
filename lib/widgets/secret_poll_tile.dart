import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'title_content.dart';
import 'content_type_icon.dart';
import 'poll_audio.dart';
import 'description.dart';
import 'poll_options.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'comment_content.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../models/poll_model.dart';
import '../models/resource_model.dart';

class SecretPollTile extends StatelessWidget {
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
  final videoFunction;
  final List groups;
  final int pos;
  final Function deleteFunction;
  final ResourceModel audio;

  SecretPollTile({
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
    @required this.videoFunction,
    @required this.groups,
    @required this.pos,
    @required this.deleteFunction,
    @required this.audio,
  });

  final Color color = Color(0xFFFFF5FB);

  void _toProfile(context) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userName) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userName);
    }
  }

  void _showGroups(context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 22, left: 22, right: 22, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Encuesta cerrada disponible solamente para los siguientes grupos:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              for (var item in groups)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${item.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.white,
                  child: Text('Ok'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _delete() {
    deleteFunction(pos);
  }

  Widget _handleResources() {
    if (resources[0].type == 'V')
      return PollVideo(id, 'P', resources[0], videoFunction);
    List urls = resources.map((e) => e.url).toList();
    return PollImages(urls, reference);
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(date);
    final newDate = now.subtract(difference).toLocal();

    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFA4175D), width: 0.5),
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
                    onTap: () => _toProfile(context),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFA4175D),
                      backgroundImage:
                          userImage == null ? null : NetworkImage(userImage),
                    ),
                    title: Row(
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
                        InfluencerBadge(id, certificate, 16),
                      ],
                    ),
                    subtitle: Text(
                      timeago.format(newDate,
                          locale: Translations.of(context).currentLanguage),
                    ),
                    trailing: ContentTypeIcon(
                      name: 'Encuesta Laboral',
                      icon: GalupFont.encuesta_cerrada,
                      color: Color(0xFFA4175D),
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
                isMine: false,
                isSecret: true,
                function: _delete,
              ),
            ),
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
                  IconButton(
                    icon: Icon(Icons.lock_outline, size: 28),
                    onPressed: () => _showGroups(context),
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

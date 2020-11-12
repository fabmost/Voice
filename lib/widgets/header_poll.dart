import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'title_content.dart';
import 'description.dart';
import 'poll_options.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import 'menu_content.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../models/poll_model.dart';
import '../custom/galup_font_icons.dart';
import '../screens/view_profile_screen.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';

class HeaderPoll extends StatelessWidget with ShareContent {
  final PollModel pollModel;

  final Color color = Color(0xFFF8F8FF);
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  HeaderPoll(this.pollModel);

  void _toProfile(context, creatorId) {
    if (Provider.of<UserProvider>(context, listen: false).getUser !=
        creatorId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
  }

  void _noExists(context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Este contenido ya no existe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    textColor: Colors.white,
                    child: Text('Ok'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).then((value) {
        Navigator.of(context).pop();
      });
    });
  }

  void _share() {
    String image;
    if (pollModel.user.icon != null && pollModel.user.icon.isNotEmpty) {
      image = pollModel.user.icon;
    } else if (pollModel.resources.isNotEmpty) {
      image = pollModel.resources[0].url;
    }
    sharePoll(pollModel.id, pollModel.title, image);
  }

  Widget _handleResources() {
    if (pollModel.resources[0].type == 'V')
      return PollVideo(pollModel.id, 'P', pollModel.resources[0].url, null);
    List<String> urls = pollModel.resources.map((e) => e.url).toList();
    return PollImages(urls, '');
  }

  @override
  Widget build(BuildContext context) {
    if (pollModel == null) {
      _noExists(context);
      return Container();
    }
    final now = new DateTime.now();
    final difference = now.difference(pollModel.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: color,
          child: ListTile(
            onTap: () => _toProfile(context, pollModel.user.userName),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: pollModel.user.icon == null
                  ? null
                  : NetworkImage(pollModel.user.icon),
            ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    pollModel.user.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                InfluencerBadge(pollModel.id, pollModel.certificate, 16),
              ],
            ),
            subtitle: Text(timeago.format(now.subtract(difference),
                locale: Translations.of(context).currentLanguage)),
            trailing: MenuContent(
              id: pollModel.id,
              type: 'P',
              isSaved: pollModel.hasSaved,
            ),
          ),
        ),
        SizedBox(height: 16),
        TitleContent(pollModel.title),
        if (pollModel.resources.isNotEmpty) SizedBox(height: 16),
        if (pollModel.resources.isNotEmpty) _handleResources(),
        //if (images.isNotEmpty) PollImages(images, reference),
        //if (video.isNotEmpty) SizedBox(height: 16),
        //if (video.isNotEmpty) PollVideo(thumb, video, null),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 8,
          ),
          child: PollOptions(
            id: pollModel.id,
            isMine: false,
          ),
        ),
        Consumer<ContentProvider>(
          builder: (context, value, child) {
            PollModel poll = value.getPolls[pollModel.id];
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
        if (pollModel.description != null && pollModel.description.isNotEmpty)
          Description(pollModel.description),
        if (pollModel.description != null && pollModel.description.isNotEmpty)
          SizedBox(height: 16),
        Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              LikeContent(
                id: pollModel.id,
                type: 'P',
                likes: pollModel.likes,
                hasLiked: pollModel.hasLiked,
              ),
              RegalupContent(
                id: pollModel.id,
                type: 'P',
                regalups: pollModel.regalups,
                hasRegalup: pollModel.hasRegalup,
              ),
              IconButton(
                icon: Icon(GalupFont.share),
                onPressed: _share,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

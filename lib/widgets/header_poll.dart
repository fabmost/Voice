import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'influencer_badge.dart';
import 'poll_options.dart';
import 'poll_video.dart';
import 'poll_images.dart';
import 'like_content.dart';
import 'regalup_content.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../models/poll_model.dart';
import '../providers/preferences_provider.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/view_profile_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/flag_screen.dart';
import '../screens/search_results_screen.dart';

class HeaderPoll extends StatelessWidget with ShareContent {
  final PollModel pollModel;

  final Color color = Color(0xFFF8F8FF);

  HeaderPoll(this.pollModel);

  void _toProfile(context, creatorId) {
    /*
    if (creatorId != userId) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: creatorId);
    }
    */
  }

  void _toHash(context, hashtag) {
    // Navigator.of(context)
    //   .pushNamed(SearchResultsScreen.routeName, arguments: hashtag);
  }

  void _noExists(context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text('Este contenido ya no existe'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      ).then((value) {
        Navigator.of(context).pop();
      });
    });
  }

  void _anonymousAlert(context, text) {
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

  void _share() {
    sharePoll(pollModel.id, pollModel.title);
  }

  void _flag(context) {
    /*
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
        */
  }

  void _save(context, hasSaved) async {
    /*
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(
        context,
        Translations.of(context).text('dialog_need_account'),
      );
      return;
    }
    WriteBatch batch = Firestore.instance.batch();
    if (hasSaved) {
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'saved': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayRemove([userId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      batch
          .updateData(Firestore.instance.collection('users').document(userId), {
        'saved': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayUnion([userId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();

    Navigator.of(context).pop();
    */
  }

  void _options(context, creatorId, hasSaved) {
    /*
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              if (creatorId != userId)
                ListTile(
                  onTap: () => _save(context, hasSaved),
                  leading: Icon(
                    GalupFont.saved,
                  ),
                  title: Text(hasSaved
                      ? Translations.of(context).text('button_delete')
                      : Translations.of(context).text('button_save')),
                ),
              ListTile(
                onTap: () => _flag(context),
                leading: Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('title_flag'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
    */
  }

  Widget _handleResources() {
    if (pollModel.resources[0].type == 'V')
      return PollVideo('', pollModel.resources[0].url, null);
    List<String> urls = pollModel.resources.map((e) => e.url).toList();
    return PollImages(urls, null);
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
            //onTap: creatorId == userId
            //  ? null
            //: () => _toProfile(context, creatorId),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: NetworkImage(pollModel.user.icon),
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
                //InfluencerBadge(document['influencer'] ?? '', 16),
              ],
            ),
            subtitle: Text(timeago.format(now.subtract(difference))),
            trailing: Transform.rotate(
              angle: 270 * pi / 180,
              child: IconButton(
                icon: Icon(Icons.chevron_left),
                // onPressed: () => _options(context, creatorId, hasSaved),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            pollModel.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (pollModel.resources.isNotEmpty)
          SizedBox(height: 16),
        if (pollModel.resources.isNotEmpty)
          _handleResources(),
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
            votes: pollModel.votes,
            hasVoted: pollModel.hasVoted,
            answers: pollModel.answers,
          ),
        ),
        if (pollModel.votes > 0)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 16,
            ),
            child: Text(pollModel.votes == 1
                ? '${pollModel.votes} participante'
                : '${pollModel.votes} participantes'),
          ),
        if (pollModel.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExtendedText(
              pollModel.description,
              specialTextSpanBuilder: MySpecialTextSpanBuilder(canClick: true),
              onSpecialTextTap: (parameter) {
                if (parameter.toString().startsWith('@')) {
                  String atText = parameter.toString();
                  int start = atText.indexOf('[');
                  int finish = atText.indexOf(']');
                  String toRemove = atText.substring(start + 1, finish);
                  _toProfile(context, toRemove);
                } else if (parameter.toString().startsWith('#')) {
                  _toHash(context, parameter.toString());
                }
              },
            ),
          ),
        if (pollModel.description.isNotEmpty)
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

import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'comment_options.dart';
import 'influencer_badge.dart';
import '../translations.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/new_comment_screen.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';

class CommentTile extends StatefulWidget {
  final bool isParent;
  final bool isLast;
  final String parentId;
  final String contentId;
  final String type;
  final String id;
  final String title;
  final DateTime date;
  final int comments;
  final String userName;
  final String userImage;
  final int ups;
  final int downs;
  final bool hasUp;
  final bool hasDown;
  final certificate;
  final Function removeFunction;
  final Function addFunction;
  final String owner;

  CommentTile({
    this.isParent = false,
    this.isLast = false,
    this.parentId,
    this.addFunction,
    @required this.contentId,
    @required this.type,
    @required this.id,
    this.title,
    this.date,
    this.comments,
    this.userImage,
    this.userName,
    this.ups,
    this.downs,
    this.hasUp,
    this.hasDown,
    @required this.certificate,
    @required this.removeFunction,
    @required this.owner,
  });

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  final GlobalKey _keyColumn = GlobalKey();
  double columnHeight = 0;
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  void _toComment(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCommentScreen(
          widget.contentId,
          widget.parentId,
          widget.userName,
          widget.addFunction,
        ),
      ),
    );
  }

  void _toProfile(context, user) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != user) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: user);
    }
  }

  void _toHash(context, hashtag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(hashtag),
      ),
    );
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

  void _deleteAlert(context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        content: Text('¿Seguro que deseas borrar este comentario?'),
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
        .deleteComment(
      id: widget.id,
      contentId: widget.contentId,
      type: widget.type,
    );
    if (result) {
      widget.removeFunction(widget.id);
    }
  }

  Widget _menuButton(context) {
    return Transform.rotate(
      angle: 270 * pi / 180,
      child: IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: () => _options(context),
      ),
    );
  }

  _getSize(_) {
    double height;
    if (widget.isLast)
      height = 42;
    else {
      final RenderBox renderBoxRed =
          _keyColumn.currentContext.findRenderObject();
      final sizeRed = renderBoxRed.size;
      height = sizeRed.height;
      if (widget.isParent) height = height - 42;
    }
    setState(() {
      columnHeight = height;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
    super.initState();
  }

  @override
  void didUpdateWidget(CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLast != oldWidget.isLast) {
      WidgetsBinding.instance.addPostFrameCallback(_getSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(widget.date);
    final newDate = now.subtract(difference).toLocal();

    return Stack(
      children: [
        if (widget.comments > 0 || !widget.isParent)
          Container(
            margin: EdgeInsets.only(
              left: 36,
              top: widget.isParent ? 42 : 0,
            ),
            width: 1,
            height: columnHeight,
            color: Colors.grey,
          ),
        Column(
          key: _keyColumn,
          children: <Widget>[
            if (widget.isParent) Divider(),
            ListTile(
              tileColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => _toProfile(context, widget.userName),
                child: CircleAvatar(
                  backgroundImage: widget.userImage == null
                      ? null
                      : widget.userImage.isEmpty
                          ? null
                          : NetworkImage(widget.userImage),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _toProfile(context, widget.userName),
                      child: Text(
                        widget.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  InfluencerBadge(widget.id, widget.certificate, 16),
                  Text(
                    timeago.format(newDate,
                        locale: Translations.of(context).currentLanguage),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
              subtitle: ExtendedText(
                widget.title,
                style: TextStyle(fontSize: 16),
                specialTextSpanBuilder:
                    MySpecialTextSpanBuilder(canClick: true),
                onSpecialTextTap: (parameter) {
                  if (parameter.toString().startsWith('@')) {
                    String atText = parameter.toString();
                    int start = atText.indexOf('[');
                    int finish = atText.indexOf(']');
                    String toRemove = atText.substring(start + 1, finish);
                    _toProfile(context, toRemove);
                  } else if (parameter.toString().startsWith('#')) {
                    _toHash(context, parameter.toString());
                  } else if (regex.hasMatch(parameter.toString())) {
                    _launchURL(parameter.toString());
                  }
                },
              ),
              trailing: Provider.of<UserProvider>(context, listen: false)
                          .getUser ==
                      widget.userName
                  ? _menuButton(context)
                  : Provider.of<UserProvider>(context, listen: false).getUser ==
                          widget.owner
                      ? _menuButton(context)
                      : null,
            ),
            CommentOptions(
              id: widget.id,
              likes: widget.ups,
              dislikes: widget.downs,
              hasLike: widget.hasUp,
              hasDislike: widget.hasDown,
              toComments: () => _toComment(context),
            ),
          ],
        ),
      ],
    );
  }
}

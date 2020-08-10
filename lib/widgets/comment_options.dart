import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';

class CommentOptions extends StatefulWidget {
  final String id;
  final int likes;
  final int dislikes;
  final bool hasLike;
  final bool hasDislike;
  final Function toComments;

  CommentOptions({
    @required this.id,
    @required this.likes,
    @required this.dislikes,
    @required this.hasLike,
    @required this.hasDislike,
    @required this.toComments,
  });

  @override
  _CommentOptionsState createState() => _CommentOptionsState();
}

class _CommentOptionsState extends State<CommentOptions> {
  int _likes;
  int _disLikes;
  bool _hasLike;
  bool _hasDislike;

  void _setLike(type) async {
    Map result = await Provider.of<ContentProvider>(context, listen: false)
        .likeComment(widget.id, type);
    setState(() {
      if (result['like']) {
        _likes++;
        _hasLike = true;
      }else{
        if(_hasLike) _likes--;
        _hasLike = false;
      }
      if (result['dislike']) {
        _disLikes++;
        _hasDislike = true;
      }else{
        if(_hasDislike) _disLikes--;
        _hasDislike = false;
      }
    });
  }

  @override
  void initState() {
    _likes = widget.likes;
    _disLikes = widget.dislikes;
    _hasLike = widget.hasLike;
    _hasDislike = widget.hasDislike;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton.icon(
          icon: Icon(
            GalupFont.like,
            color: _hasLike ? Theme.of(context).accentColor : Colors.black,
          ),
          label: Text(_likes == 0 ? '' : '$_likes'),
          onPressed: () => _setLike('L'),
        ),
        FlatButton.icon(
          icon: Icon(
            GalupFont.dislike,
            color: _hasDislike ? Theme.of(context).accentColor : Colors.black,
          ),
          label: Text(_disLikes == 0 ? '' : '$_disLikes'),
          onPressed: () => _setLike('D'),
        ),
        FlatButton(
          child: Text('Responder'),
          onPressed: () => widget.toComments,
        ),
      ],
    );
  }
}

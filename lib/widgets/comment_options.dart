import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../models/comment_model.dart';

class CommentOptions extends StatelessWidget {
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

  void _setLike(context, type) async {
    await Provider.of<ContentProvider>(context, listen: false)
        .likeComment(id, type);
    /*
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
    */
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(builder: (context, value, child) {
      CommentModel _comment = value.getCommentsMap[id];
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton.icon(
                icon: Icon(
                  GalupFont.like,
                  color: _comment.hasLike
                      ? Theme.of(context).accentColor
                      : Colors.black,
                ),
                label: Text(_comment.likes == 0 ? '' : '${_comment.likes}'),
                onPressed: () => _setLike(context, 'L'),
              ),
              FlatButton.icon(
                icon: Icon(
                  GalupFont.dislike,
                  color: _comment.hasDislike
                      ? Theme.of(context).accentColor
                      : Colors.black,
                ),
                label:
                    Text(_comment.dislikes == 0 ? '' : '${_comment.dislikes}'),
                onPressed: () => _setLike(context, 'D'),
              ),
              FlatButton(
                child: Text('Responder'),
                onPressed: toComments,
              ),
            ],
          ),
          if (_comment.comments > 0)
            Row(
              children: <Widget>[
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                ),
                FlatButton(
                  child: Text('Ver respuestas (${_comment.comments})'),
                  onPressed: toComments,
                ),
              ],
            ),
          if (_comment.comments == 0) Divider(),
        ],
      );
    });
  }
}

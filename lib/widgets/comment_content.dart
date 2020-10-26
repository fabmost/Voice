import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../custom/galup_font_icons.dart';
import '../models/content_model.dart';
import '../screens/comments_screen.dart';

class CommentContent extends StatelessWidget {
  final String id;
  final String type;

  CommentContent({this.id, this.type});

  void _toComments(context, owner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          id: id,
          type: type,
          owner: owner,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ContentModel _content;
    return Consumer<ContentProvider>(
      builder: (context, value, child) {
        switch (type) {
          case 'P':
            _content = value.getPolls[id];
            break;
          case 'C':
            _content = value.getChallenges[id];
            break;
          case 'TIP':
            _content = value.getTips[id];
            break;
        }
        return FlatButton.icon(
          onPressed: () => _toComments(context, _content.user.userName),
          icon: Icon(GalupFont.message),
          label: Text(_content.comments == 0 ? '' : '${_content.comments}'),
        );
      },
    );
  }
}

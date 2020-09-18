import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mixins/alert_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';

class LikeContent extends StatelessWidget with AlertMixin {
  final String id;
  final String type;
  final int likes;
  final bool hasLiked;
  final Function tipFunction;

  LikeContent({
    @required this.id,
    @required this.type,
    @required this.likes,
    @required this.hasLiked,
    this.tipFunction,
  });

  void _like(context) async {
    bool canInteract =
        await Provider.of<AuthProvider>(context, listen: false).canInteract();
    if (!canInteract) {
      anonymousAlert(context);
      return;
    }
    await Provider.of<ContentProvider>(context, listen: false)
        .likeContent(type, id);
  }

  @override
  Widget build(BuildContext context) {
    Color _color;
    ContentModel _content;
    return Consumer<ContentProvider>(
      builder: (context, value, child) {
        switch (type) {
          case 'P':
            _color = Color(0xFF6767CB);
            _content = value.getPolls[id];
            break;
          case 'C':
            _color = Color(0xFFA4175D);
            _content = value.getChallenges[id];
            break;
          case 'TIP':
            _color = Color(0xFF00B2E3);
            _content = value.getTips[id];
            break;
        }
        return FlatButton.icon(
          onPressed: () => _like(context),
          icon: Icon(
            GalupFont.like,
            color: _content.hasLiked ? _color : Colors.black,
          ),
          label: Text(_content.likes == 0 ? '' : '${_content.likes}'),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mixins/alert_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../models/content_model.dart';

class RegalupContent extends StatelessWidget with AlertMixin {
  final String id;
  final String type;
  final int regalups;
  final bool hasRegalup;

  RegalupContent({
    @required this.id,
    @required this.type,
    @required this.regalups,
    @required this.hasRegalup,
  });

  void _regalup(context) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    await Provider.of<ContentProvider>(context, listen: false)
        .newRegalup(type, id);
  }

  @override
  Widget build(BuildContext context) {
    Color _color;
    ContentModel _content;
    return Consumer<ContentProvider>(builder: (context, value, child) {
      switch (type) {
        case 'P':
          _color = Color(0xFF6767CB);
          _content = value.getPolls[id];
          break;
        case 'C':
          _color = Color(0xFFA4175D);
          _content = value.getChallenges[id];
          break;
        case 'CA':
          _color = Color(0xFF722282);
          _content = value.getCausesList[id];
          break;
        case 'TIP':
          _color = Color(0xFF00B2E3);
          _content = value.getTips[id];
          break;
      }
      return FlatButton.icon(
        onPressed: () => _regalup(context),
        icon: Icon(
          GalupFont.repost,
          color: _content.hasRegalup ? _color : Colors.black,
        ),
        label: Text(_content.regalups == 0 ? '' : '${_content.regalups}'),
      );
    });
  }
}

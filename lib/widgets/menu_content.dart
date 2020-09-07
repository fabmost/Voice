import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../screens/flag_screen.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../mixins/alert_mixin.dart';

class MenuContent extends StatefulWidget {
  final String id;
  final String type;
  final bool isSaved;

  MenuContent({this.id, this.type, this.isSaved});

  @override
  _MenuContentState createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> with AlertMixin{
  bool _isSaved;

  void _flag(context) {
    Navigator.of(context).popAndPushNamed(FlagScreen.routeName,
        arguments: {'id': widget.id, 'type': widget.type});
  }

  void _save(context) async {
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .saveContent(widget.id, widget.type);
    setState(() {
      _isSaved = result;
    });
    Navigator.of(context).pop();
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
                onTap: () => _save(context),
                leading: Icon(
                  GalupFont.saved,
                ),
                title: Text(_isSaved
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
  }

  @override
  void initState() {
    _isSaved = widget.isSaved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 270 * pi / 180,
      child: IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: () => _options(context),
      ),
    );
  }
}

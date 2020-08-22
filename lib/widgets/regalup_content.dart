import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';

class RegalupContent extends StatefulWidget {
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

  @override
  _RegalupContentState createState() => _RegalupContentState();
}

class _RegalupContentState extends State<RegalupContent> {
  int _regalups;
  bool _hasRegalup;
  Color _color;

  void _regalup() async {
    bool result = await Provider.of<ContentProvider>(context, listen: false)
        .newRegalup(widget.type, widget.id);
    setState(() {
      _hasRegalup = result;
      if (result) {
        _regalups++;
      } else {
        _regalups--;
      }
    });
  }

  @override
  void initState() {
    _regalups = widget.regalups;
    _hasRegalup = widget.hasRegalup;
    switch (widget.type) {
      case 'P':
        _color = Color(0xFF6767CB);
        break;
      case 'C':
        _color = Color(0xFFA4175D);
        break;
      case 'CA':
        _color = Color(0xFF722282);
        break;
      case 'TIP':
        _color = Color(0xFF00B2E3);
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed: _regalup,
      icon: Icon(
        GalupFont.repost,
        color: _hasRegalup ? _color : Colors.black,
      ),
      label: Text(_regalups == 0 ? '' : '$_regalups'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';

class LikeContent extends StatefulWidget {
  final String id;
  final String type;
  final int likes;
  final bool hasLiked;

  LikeContent({
    @required this.id,
    @required this.type,
    @required this.likes,
    @required this.hasLiked,
  });

  @override
  _LikeContentState createState() => _LikeContentState();
}

class _LikeContentState extends State<LikeContent> {
  int _likes;
  bool _hasLiked;
  Color _color;

  void _like() async {
    bool result = await Provider.of<ContentProvider>(context, listen: false)
        .likeContent(widget.type, widget.id);
    setState(() {
      _hasLiked = result;
      if (result) {
        _likes++;
      } else {
        _likes--;
      }
    });
  }

  @override
  void initState() {
    _likes = widget.likes;
    _hasLiked = widget.hasLiked;
    switch (widget.type) {
      case 'P':
        _color = Color(0xFF6767CB);
        break;
      case 'C':
        _color = Color(0xFFA4175D);
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed: _like,
      icon: Icon(
        GalupFont.like,
        color: _hasLiked ? _color : Colors.black,
      ),
      label: Text(_likes == 0 ? '' : '$_likes'),
    );
  }
}

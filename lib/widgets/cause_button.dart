import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';

class CauseButton extends StatefulWidget {
  final String id;
  final bool hasLike;
  final Function setVotes;

  CauseButton({
    @required this.id,
    @required this.hasLike,
    @required this.setVotes,
  });

  @override
  _CauseButtonState createState() => _CauseButtonState();
}

class _CauseButtonState extends State<CauseButton> {
  bool _isLoading = false;
  bool _hasLike;

  void _like() async {
    setState(() {
      _isLoading = true;
    });
    bool result = await Provider.of<ContentProvider>(context, listen: false)
        .likeContent('CA', widget.id);
    setState(() {
      _isLoading = false;
      _hasLike = result;
      if (result) {
        widget.setVotes(true);
      } else {
        widget.setVotes(false);
      }
    });
  }

  @override
  void initState() {
    _hasLike = widget.hasLike;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 42,
            width: double.infinity,
            child: _hasLike
                ? OutlineButton(
                    highlightColor: Color(0xFFA4175D),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                    onPressed: _like,
                    child: Text('No apoyo esta causa'),
                  )
                : RaisedButton(
                    onPressed: _like,
                    color: Colors.black,
                    textColor: Colors.white,
                    child: Text('Apoyo esta causa'),
                  ),
          );
  }
}

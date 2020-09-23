import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/cause_model.dart';

class CauseButton extends StatelessWidget {
  final String id;
  final bool hasLike;

  CauseButton({
    @required this.id,
    @required this.hasLike,
  });

  void _like(context) async {
    await Provider.of<ContentProvider>(context, listen: false)
        .likeContent('CA', id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(builder: (context, value, child) {
      CauseModel mCause = value.getCausesList[id];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 42,
        width: double.infinity,
        child: mCause.hasLiked
            ? OutlineButton(
                highlightColor: Color(0xFFA4175D),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
                onPressed: () => _like(context),
                child: Text('No apoyo esta causa'),
              )
            : RaisedButton(
                onPressed: () => _like(context),
                color: Colors.black,
                textColor: Colors.white,
                child: Text('Apoyo esta causa'),
              ),
      );
    });
  }
}

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom/my_special_text_span_builder.dart';
import '../providers/user_provider.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';

class TitleContent extends StatelessWidget {
  final String title;

  TitleContent(this.title);

  void _toTaggedProfile(context, userName) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userName) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userName);
    }
  }

  void _toHash(context, hashtag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(hashtag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExtendedText(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        specialTextSpanBuilder: MySpecialTextSpanBuilder(canClick: true),
        onSpecialTextTap: (parameter) {
          if (parameter.toString().startsWith('@')) {
            String atText = parameter.toString();
            int start = atText.indexOf('[');
            int finish = atText.indexOf(']');
            String toRemove = atText.substring(start + 1, finish);
            _toTaggedProfile(context, toRemove);
          } else if (parameter.toString().startsWith('#')) {
            _toHash(context, parameter.toString());
          }
        },
      ),
    );
  }
}

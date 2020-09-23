import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/user_provider.dart';
import '../custom/my_special_text_span_builder.dart';
import '../screens/view_profile_screen.dart';
import '../screens/search_results_screen.dart';

class Description extends StatelessWidget {
  final String text;
  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  Description(this.text);

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

  void _launchURL(String url) async {
    String newUrl = url;
    if (!url.contains('http')) {
      newUrl = 'http://$url';
    }
    if (await canLaunch(newUrl.trim())) {
      await launch(newUrl.trim());
    } else {
      throw 'Could not launch $newUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExtendedText(
        text,
        style: TextStyle(fontSize: 16),
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
          } else if (regex.hasMatch(parameter.toString())) {
            _launchURL(parameter.toString());
          }
        },
      ),
    );
  }
}

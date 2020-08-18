import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LinkText extends SpecialText {
  static const String flag = "";
  final int start;
  RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  /// whether show background for @somebody
  final bool showAtBackground;

  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground: false, this.start, String startFlag})
      : super(
          startFlag,
          " ",
          textStyle,
          onTap: onTap,
        );

  @override
  InlineSpan finishText() {
    TextStyle textStyle = this
        .textStyle
        ?.copyWith(color: Color(0xFF722282), fontWeight: FontWeight.bold);

    final String atText = toString();

    final String textLink = regex.firstMatch(atText).group(0);
    final List mList = atText.split(textLink);

    return TextSpan(text: mList[0], children: <InlineSpan>[
      SpecialTextSpan(
        text: textLink,
        actualText: textLink,
        deleteAll: false,
        start: start,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap(textLink);
          }),
      ),
      TextSpan(text: mList[1]),
    ]);
  }
}

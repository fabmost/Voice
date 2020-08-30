import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AtText extends SpecialText {
  static const String flag = "@[";
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  AtText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground: false, this.start})
      : super(
          flag,
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
    String toRemove;
    int start = atText.indexOf('[');
    if (start != -1) {
      int finish = atText.indexOf(']');
      toRemove = atText.substring(start, finish + 1);
    }

    final String shownText =
        toRemove != null ? atText.replaceAll(toRemove, '') : atText;

    return showAtBackground
        ? BackgroundTextSpan(
            background: Paint()..color = Colors.blue.withOpacity(0.15),
            text: shownText,
            actualText: atText,
            start: start,

            ///caret can move into special text
            deleteAll: true,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) onTap(atText);
              }))
        : SpecialTextSpan(
            text: shownText,
            actualText: atText,
            deleteAll: true,
            start: start,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) onTap(atText);
              }));
  }
}

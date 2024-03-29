import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TagText extends SpecialText {
  static const String flag = "#";
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  TagText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground: false, this.start})
      : super(
          flag,
          " ",
          textStyle,
          onTap: onTap,
        );

  @override
  InlineSpan finishText() {
    TextStyle textStyle =
        this.textStyle?.copyWith(color: Color(0xFF722282), fontWeight: FontWeight.bold);

    final String atText = toString();

    return showAtBackground
        ? BackgroundTextSpan(
            background: Paint()..color = Colors.blue.withOpacity(0.15),
            text: atText,
            actualText: atText,
            start: start,

            ///caret can move into special text
            deleteAll: false,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) onTap(atText);
              }))
        : SpecialTextSpan(
            text: atText,
            actualText: atText,
            start: start,
            style: textStyle,
            deleteAll: false,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) onTap(atText);
              }));
  }
}
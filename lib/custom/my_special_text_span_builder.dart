import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'at_span.dart';
import 'tag_span.dart';
import 'link_span.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder(
      {this.showAtBackground = false, this.canClick = false});

  /// whether show background for @somebody
  final bool showAtBackground;
  final bool canClick;

  final RegExp regex = new RegExp(
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  @override
  TextSpan build(String data,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }

    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
    if (flag == null || flag == '') {
      return null;
    }

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, AtText.flag)) {
      return AtText(
        textStyle,
        canClick ? onTap : null,
        start: index - (AtText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    } else if (isStart(flag, TagText.flag)) {
      return TagText(
        textStyle,
        canClick ? onTap : null,
        start: index - (TagText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    }else if (regex.hasMatch(flag)) {
      return LinkText(
        textStyle,
        canClick ? onTap : null,
        start: index,
        showAtBackground: showAtBackground,
        startFlag: flag,
      );
    }
    return null;
  }
}

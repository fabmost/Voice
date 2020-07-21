import 'dart:convert';

import 'package:crypto/crypto.dart';

class API{
  final String salt = '3=\$:ndTxmFK@LEZL~7n.';

  String getSalt(String value){
    String union = salt + value;
    String utf1 = md5.convert(utf8.encode(union)).toString();
    return sha1.convert(utf8.encode(utf1)).toString();
  }
}
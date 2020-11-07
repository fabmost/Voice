import 'dart:convert';

import 'package:crypto/crypto.dart';

class API {
  final String salt = '3=\$:ndTxmFK@LEZL~7n.';
  //Producción
  //static const baseURL = 'https://secure.galup.app/api-app-v1';
  //Dev
  static const baseURL = 'https://secure.galup.app/api-app-v1-dev';
  static const sessionToken = 'token';
  static const userHash = 'hash';
  static const userName = 'userName';

  String getSalt(String value) {
    String union = salt + value;
    String utf1 = md5.convert(utf8.encode(union)).toString();
    return sha1.convert(utf8.encode(utf1)).toString();
  }

  String getHash(String hash, String datetime) {
    String union = hash + salt + datetime;
    String utf1 = md5.convert(utf8.encode(union)).toString();
    return sha1.convert(utf8.encode(utf1)).toString();
  }

  String getLog(String email, String password) {
    String union = salt + email + password;
    return sha1.convert(utf8.encode(union)).toString();
  }
}

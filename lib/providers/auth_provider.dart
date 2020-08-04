import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api.dart';

class AuthProvider with ChangeNotifier {
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  Future<void> installation(int page, String type) async {
    var url = '${API.baseURL}/installation/';

    final hash = UniqueKey().toString();
    final datetime = DateFormat('YYYY-MM-dd HH:mm:ss').format(DateTime.now());
    final body = jsonEncode({
      'hash': hash,
      'utm_content': '',
      'utm_source': '',
      'utm_campaign': '',
      'utm_medium': '',
      'utm_term': '',
      'gclid': '',
      'language': '',
      'datetime': datetime
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: API().getHash(hash, datetime)
      },
      body: body,
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }
  }
}

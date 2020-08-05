import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;
import '../api.dart';

class ContentProvider with ChangeNotifier {
  final String _token;

  ContentProvider(this._token);
  
  Future<void> getBaseTimeline(int page, String type) async {
    var url = '${API.baseURL}/timeLine/';

    Map parameters = {'page': page};
    if (type != null) {
      parameters['type'] = type;
    }
    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final body = jsonEncode(parameters);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader:
            'Bearer $_token'
      },
      body: body,
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }
  }
}

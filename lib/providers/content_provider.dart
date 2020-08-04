import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api.dart';

class ContentProvider with ChangeNotifier {
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  Future<void> getBaseTimeline(int page, String type) async {
    var url = '${API.baseURL}/timeLine/';

    Map parameters = {'page': page};
    if (type != null) {
      parameters['type'] = type;
    }
    final body = jsonEncode(parameters);
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return;
    }
  }
}

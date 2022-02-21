import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:musify/constants.dart';

class MusifyHttpClient {
  static Future<Map<String, dynamic>> get(String url) async {
    var response = await http.get(Uri.parse("$kMusifyHost$url"));
    return convert.jsonDecode(convert.utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:logger/logger.dart';

class TimelineContentService {
  static final Logger _logger = Logger();

  static Future<List<Content>> fetchContents({required int eventId}) async {
    String uri = '${BackEndConstants.API_ADDRESS}/api/events/$eventId/contents';
    http.Response response =
        await http.get(Uri.parse(uri), headers: <String, String>{
      'content-type': 'application/json',
    });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    _logger.d("$uri\n$decodedResponse");
    // return response.statusCode;
    List<Content> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Content.fromMap(entry));
    }
    return eventsList;
  }

  static Future<List<Content>> fetchAllContents() async {
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/content'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));

    _logger.d(decodedResponse);
    // return response.statusCode;
    List<Content> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Content.fromMap(entry));
    }
    return eventsList;
  }

  static Future<List<Content>> fetchContentsWithinIds(
      {required int lower_id, required int upper_id}) async {
    http.Response response = await http.get(
        Uri.parse(
            '${BackEndConstants.API_ADDRESS}/api/content/$lower_id-$upper_id'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));

    _logger.d(decodedResponse);
    // return response.statusCode;
    List<Content> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Content.fromMap(entry));
    }
    return eventsList;
  }
}

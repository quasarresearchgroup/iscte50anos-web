import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:logger/logger.dart';

class TimelineTopicService {
  static final Logger _logger = Logger();

  static Future<List<Event>> fetchEvents({required List<int> topicIds}) async {
    String string = topicIds.fold("", (previousValue, element) {
      if (previousValue.isEmpty) {
        return "topic=$element";
      } else {
        return "$previousValue&topic=$element";
      }
    });
    //_logger.d(string);
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/?$string'),
        headers: <String, String>{
          'content-type': 'application/json',
        });

    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));

    List<Event> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Event.fromMap(entry));
    }
    _logger.i("fetched ${eventsList.length} events with topics: $topicIds");
    return eventsList;
  }

  static Future<List<Topic>> fetchTopics({required int eventId}) async {
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/$eventId/topics'),
        headers: <String, String>{
          'content-type': 'application/json',
        });

    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    //_logger.d(decodedResponse);
    // return response.statusCode;
    List<Topic> topicsList = [];
    for (var entry in decodedResponse) {
      topicsList.add(Topic.fromMap(entry));
    }
    _logger.i("fetched topics from event: $eventId");
    return topicsList;
  }

  static Future<List<Topic>> fetchAllTopics() async {
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/topics'),
        headers: <String, String>{
          'content-type': 'application/json',
        });

    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    //_logger.d(decodedResponse);
    // return response.statusCode;
    List<Topic> topicsList = [];
    for (var entry in decodedResponse) {
      topicsList.add(Topic.fromMap(entry));
    }
    _logger.i("fetched all topics");
    return topicsList;
  }
}

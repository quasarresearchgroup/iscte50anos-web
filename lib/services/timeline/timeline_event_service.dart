import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:logger/logger.dart';

class TimelineEventService {
  static final Logger _logger = Logger();

  static Future<List<Event>> fetchAllEvents() async {
    /*
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .getUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/events'));
      request.headers.set('content-type', 'application/json');
      */

    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/events'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    _logger.d(response.body);

    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    // _logger.d(decodedResponse);
    // return response.statusCode;
    List<Event> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Event.fromMap(entry));
    }
    _logger.i("fetched ${eventsList.length} events from server");
    //_logger.d(eventsList);
    return eventsList;
  }

  static Future<List<Event>> fetchEvents(
      {required int year, required int multiplier}) async {
    http.Response response = await http.get(
        Uri.parse(
            '${BackEndConstants.API_ADDRESS}/api/events/year/$year-$multiplier'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    // _logger.d(decodedResponse);
    // return response.statusCode;
    List<Event> eventsList = [];
    for (var entry in decodedResponse) {
      eventsList.add(Event.fromMap(entry));
    }
    return eventsList;
  }

  static Future<Event> fetchEvent({required int id}) async {
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/$id'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    _logger.d(decodedResponse);
    // return response.statusCode;

    return Event.fromMap(decodedResponse);
  }
}

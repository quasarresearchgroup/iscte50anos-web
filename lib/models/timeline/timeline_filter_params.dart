import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TimelineFilterParams with ChangeNotifier {
  TimelineFilterParams({
    Set<Topic>? topics,
    Set<EventScope>? scopes,
    String searchText = "",
  })  : _topics = topics ?? {},
        _scopes = scopes ?? {},
        _searchText = searchText;


  Set<Topic> _topics;
  Set<EventScope> _scopes;

  String _searchText;
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    LoggerService.instance.info(this);
  }

  //region Topics
  Set<Topic> get getTopics => _topics;
  set topics(Set<Topic> value) {
    _topics = value;
    notifyListeners();
    LoggerService.instance.info(this);
  }

  bool isTopicsEmpty() => _topics.isEmpty;

  void addTopic(Topic topic) {
    _topics.add(topic);
    notifyListeners();
    LoggerService.instance.info(this);
  }

  void removeTopic(Topic topic) {
    _topics.remove(topic);
    notifyListeners();
    LoggerService.instance.info(this);
  }

  void clearTopics() {
    _topics.clear();
    notifyListeners();
    LoggerService.instance.info(this);
  }

  bool containsTopic(Topic topic) => _topics.contains(topic);

  void addAllTopic(Iterable<Topic> iterableTopics) {
    _topics.addAll(iterableTopics);
    LoggerService.instance.info(this);
    notifyListeners();
  }
  //endregion

  //region Scopes

  Set<EventScope> get getScopes => _scopes;

  set scopes(Set<EventScope> value) {
    _scopes = value;
    LoggerService.instance.info(this);
    notifyListeners();
  }

  bool isScopesEmpty() => _scopes.isEmpty;

  void addScope(EventScope scope) {
    _scopes.add(scope);
    LoggerService.instance.info(this);
    notifyListeners();
  }

  void removeScope(EventScope scope) {
    _scopes.remove(scope);
    LoggerService.instance.info(this);
    notifyListeners();
  }

  void clearScopes() {
    _scopes.clear();
    LoggerService.instance.info(this);
    notifyListeners();
  }

  bool containsScope(EventScope scope) => _scopes.contains(scope);

  void addAllScope(Iterable<EventScope> iterableScopes) {
    _scopes.addAll(iterableScopes);
    LoggerService.instance.info(this);
    notifyListeners();
  }

  //endregion

  factory TimelineFilterParams.fromMap(Map<String, dynamic> json) {
    return TimelineFilterParams(
      topics: jsonDecode(json["topics"]),
      scopes: json["scopes"],
      searchText: json["searchText"],
    );
  }

  Map<String, dynamic> toMap() {
    var map = {
      "topics": json.encode(_topics.toList()),
      "scopes": json.encode(_scopes.map((e) => e.name).toList()),
      "searchText": json.encode(_searchText),
    };
    LoggerService.instance.debug("map\n$map");
    return map;
  }

  String encode() {
    //return base64Url.encode(utf8.encode(outputString));
    return "${_topics.map((e) => e.asString).join("&")}_${_scopes.map((e) => e.asString).join("&")}_search=$_searchText";
  }

  factory TimelineFilterParams.decode(String hash) {
    //String base64decode = utf8.decode(base64Url.decode(hash));
    //Logger().d(base64decode);
    List<String> split = hash.split("_");
    Set<EventScope> scopes = {};
    Set<Topic> topics = {};
    String searchText = "";
    try {
      List<String> topicsString = split[0].split("&");
      topics = topicsString.map((e) => Topic.fromString(e)).toSet();
    } catch (_) {
      rethrow;
    }
    try {
      List<String> scopesString = split[1].split("&");
      for (String entry in scopesString) {
        EventScope? eventScope = decodeEventScopefromString(entry);
        if (eventScope != null) {
          scopes.add(eventScope);
        }
      }
    } catch (_) {
      rethrow;
    }
    try {
      searchText = split[2].replaceFirst("search=", "");
    } catch (_) {
      rethrow;
    }

    return TimelineFilterParams(
        scopes: scopes, searchText: searchText, topics: topics);
  }

  @override
  String toString() {
    return 'TimelineFilterParams{_topics: $_topics, _scopes: $_scopes, _searchText: $_searchText}';
  }
}

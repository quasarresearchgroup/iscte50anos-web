import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/models/timeline/topic.dart';

class TimelineFilterParams with ChangeNotifier {
  TimelineFilterParams({required Set<Topic> topics, required String searchText})
      : _topics = topics,
        _searchText = searchText;

  Set<Topic> _topics;
  Set<Topic> get getTopics => _topics;
  set topics(Set<Topic> value) {
    _topics = value;
    notifyListeners();
  }

  bool isEmpty() => _topics.isEmpty;

  void addTopic(Topic topic) {
    _topics.add(topic);
    notifyListeners();
  }

  void removeTopic(Topic topic) {
    _topics.remove(topic);
    notifyListeners();
  }

  void clearTopics() {
    _topics.clear();
    notifyListeners();
  }

  bool containsTopic(Topic topic) => _topics.contains(topic);

  void addAllTopic(Iterable<Topic> iterableTopics) {
    _topics.addAll(iterableTopics);
    notifyListeners();
  }

  String _searchText;
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineFilterParams &&
          runtimeType == other.runtimeType &&
          _topics == other._topics &&
          _searchText == other._searchText;

  @override
  int get hashCode => _topics.hashCode ^ _searchText.hashCode;

  factory TimelineFilterParams.fromMap(Map<String, dynamic> json) {
    return TimelineFilterParams(
      topics: json["topics"],
      searchText: json["searchText"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "topics": _topics,
      "searchText": _searchText,
    };
  }

  String encode() {
    return "${_topics.map((e) => e.toString()).join("«")}»$_searchText";
  }

  factory TimelineFilterParams.decode(String hash) {
    List<String> split = hash.split("»");
    List<String> topicsString = split[0].split("«");
    Set<Topic> topics = topicsString.map((e) {
      //var decoded = jsonDecode(e);
      return Topic.fromString(e);
    }).toSet();

    return TimelineFilterParams(
      topics: topics,
      searchText: split.length > 1 ? split[1] : "",
    );
  }

  @override
  String toString() {
    return 'TimelineFilterParams{topics: $_topics, searchText: $_searchText}';
  }
}

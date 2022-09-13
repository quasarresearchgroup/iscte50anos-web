import 'package:logger/logger.dart';

class Topic {
  Topic({
    required this.id,
    this.title,
  });

  final int id;
  final String? title;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Topic{id: $id, title: $title}';
  }

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
    };
  }

/*
  Future<List<Event>> get getEventsList async {
    return TimelineTopicService.fetchEvents(topicIds: [id]);
    assert(id != null);
    List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getEventIdsFromTopicId(id!);
    List<Event> topicsList =
        await DatabaseEventTable.getAllWithIds(allIdsWithEventId);
    return topicsList;
  }
  */
}

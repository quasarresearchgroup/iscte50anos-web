import 'database/tables/pages_table.dart';

class VisitedPage {
  final int? id;
  final String content;
  final String? url;
  final int dateTime;

  VisitedPage({
    this.id,
    required this.content,
    required this.dateTime,
    this.url,
  });

  String get parsedTime {
    DateTime timeParsed = dateTimeParsed();
    int year = timeParsed.year;
    int month = timeParsed.month;
    int day = timeParsed.day;
    int hour = timeParsed.hour;
    int minute = timeParsed.minute;
    return "$year-$month-$day $hour:$minute";
  }

  factory VisitedPage.fromMap(Map<String, dynamic> json) => VisitedPage(
      id: json[DatabasePagesTable.columnId],
      content: json[DatabasePagesTable.columnContent],
      url: json[DatabasePagesTable.columnUrl],
      dateTime: json[DatabasePagesTable.columnDate]);

  Map<String, dynamic> toMap() {
    return {
      DatabasePagesTable.columnId: id,
      DatabasePagesTable.columnContent: content,
      DatabasePagesTable.columnDate: dateTime,
      DatabasePagesTable.columnUrl: url
    };
  }

  DateTime dateTimeParsed() {
    return DateTime.fromMillisecondsSinceEpoch(dateTime);
  }
}

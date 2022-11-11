import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/datetime_extension.dart';
import 'package:iscte_spots/models/timeline/event.dart';

class EventTimelineIndicator extends StatelessWidget {
  EventTimelineIndicator({
    Key? key,
    required this.isEven,
    required this.event,
    this.textColor,
    required this.isLast,
    required this.isFirst,
  }) : super(key: key);

  final bool isEven;
  final bool isLast;
  final bool isFirst;
  final Event event;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            event.dateTime.monthName(),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
          ),
          Text(
            event.dateTime.day.toString(),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
          ),
        ],
      ),
    ));
  }
}

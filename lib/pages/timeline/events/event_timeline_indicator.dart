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
    Widget verticalConnector = Expanded(
      child: Container(
        width: 6,
        color: Colors.black,
      ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        !isFirst ? verticalConnector : const Spacer(),
        EventTImelineIndicatorDate(event: event),
        !isLast ? verticalConnector : const Spacer(),
      ],
    );
  }
}

class EventTImelineIndicatorDate extends StatelessWidget {
  const EventTImelineIndicatorDate({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            event.dateTime.monthName(),
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
          Text(
            event.dateTime.day.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

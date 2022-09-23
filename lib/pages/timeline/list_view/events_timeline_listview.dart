import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineListView extends StatefulWidget {
  const EventTimelineListView({
    Key? key,
    required this.timeLineMap,
    required this.timelineYear,
    required this.handleEventSelection,
  }) : super(key: key);
  final List<Event> timeLineMap;
  final int timelineYear;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineListView> createState() => _EventTimelineListViewState();
}

class _EventTimelineListViewState extends State<EventTimelineListView> {
  List<Event> chosenTimelineList = <Event>[];
  List<Event> originalTimelineList = <Event>[];
  final double tileOffset = 0.4;

  @override
  void didUpdateWidget(covariant EventTimelineListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timelineYear != widget.timelineYear) {
      chosenTimelineList.clear();
      for (final entry in originalTimelineList) {
        if (entry.dateTime.year == widget.timelineYear) {
          chosenTimelineList.add(entry);
        }
      }
      chosenTimelineList.sort(
        (a, b) => a.dateTime.compareTo(b.dateTime),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    for (final Event entry in widget.timeLineMap) {
      originalTimelineList.add(entry);
      if (entry.dateTime.year == widget.timelineYear) {
        chosenTimelineList.add(entry);
      }
    }
    chosenTimelineList.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LineStyle lineStyle =
        LineStyle(color: Theme.of(context).focusColor, thickness: 6);
    List<Widget> timelineTiles = [];

    return ScrollConfiguration(
      behavior: WebScrollBehaviour(),
      child: ListView.builder(
        itemCount: chosenTimelineList.length,
        itemBuilder: (context, index) => EventTimelineTile(
          index: index,
          event: chosenTimelineList[index],
          isFirst: index == 0,
          isLast: index == chosenTimelineList.length - 1,
          lineStyle: lineStyle,
          handleEventSelection: widget.handleEventSelection,
        ),
      ),
    );
  }
}

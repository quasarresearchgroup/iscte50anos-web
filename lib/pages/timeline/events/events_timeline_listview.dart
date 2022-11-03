import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineListViewBuilder extends StatefulWidget {
  const EventTimelineListViewBuilder({
    Key? key,
    required this.timelineYear,
    required this.handleEventSelection,
    this.events,
    required this.selectedEventIndex,
  }) : super(key: key);
  final int timelineYear;
  final List<Event>? events;
  final void Function(int) handleEventSelection;
  final ValueNotifier<int?> selectedEventIndex;

  @override
  State<EventTimelineListViewBuilder> createState() =>
      _EventTimelineListViewBuilderState();
}

class _EventTimelineListViewBuilderState
    extends State<EventTimelineListViewBuilder> {
  late Future<List<Event>> currentEvents;

  @override
  void initState() {
    super.initState();
    if (widget.events == null) {
      currentEvents =
          TimelineEventService.fetchEventsFromYear(year: widget.timelineYear);
    } else {
      currentEvents = Future(() => widget.events!
          .where((element) => element.dateTime.year == widget.timelineYear)
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final LineStyle lineStyle =
        LineStyle(color: Theme.of(context).focusColor, thickness: 6);

    return FutureBuilder<List<Event>>(
        future: currentEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              List<Event> data = snapshot.data!;
              return ValueListenableBuilder<int?>(
                  valueListenable: widget.selectedEventIndex,
                  builder: (context, value, _) {
                    return ScrollConfiguration(
                      behavior: WebScrollBehaviour(),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var eventTimelineTile = EventTimelineTile(
                            index: index,
                            event: data[index],
                            isFirst: index == 0,
                            isLast: index == data.length - 1,
                            lineStyle: lineStyle,
                            handleEventSelection: widget.handleEventSelection,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: index == value
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: IscteTheme.iscteColor,
                                      width: 2,
                                      strokeAlign: StrokeAlign.outside,
                                    )),
                                    child: eventTimelineTile,
                                  )
                                : eventTimelineTile,
                          );
                        },
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Text("No data"),
              );
            }
          } else {
            return LoadingWidget();
          }
        });
  }
}

class EventTimelineListView extends StatefulWidget {
  const EventTimelineListView({
    Key? key,
    required this.lineStyle,
    required this.data,
    required this.handleEventSelection,
    required this.selectedEventIndex,
  }) : super(key: key);

  final LineStyle lineStyle;
  final List<Event> data;
  final void Function(int) handleEventSelection;
  final ValueNotifier<int?> selectedEventIndex;

  @override
  State<EventTimelineListView> createState() => _EventTimelineListViewState();
}

class _EventTimelineListViewState extends State<EventTimelineListView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: widget.selectedEventIndex,
        builder: (context, value, _) {
          return ScrollConfiguration(
            behavior: WebScrollBehaviour(),
            child: ListView.builder(
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                var eventTimelineTile = EventTimelineTile(
                  index: index,
                  event: widget.data[index],
                  isFirst: index == 0,
                  isLast: index == widget.data.length - 1,
                  lineStyle: widget.lineStyle,
                  handleEventSelection: widget.handleEventSelection,
                );
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: index == value
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: IscteTheme.iscteColor,
                            width: 2,
                            strokeAlign: StrokeAlign.outside,
                          )),
                          child: eventTimelineTile,
                        )
                      : eventTimelineTile,
                );
              },
            ),
          );
        });
  }
}

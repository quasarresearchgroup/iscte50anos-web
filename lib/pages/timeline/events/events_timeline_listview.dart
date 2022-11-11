import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

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
                        itemBuilder: (context, index) => EventTimelineTile(
                          index: index,
                          event: data[index],
                          isFirst: index == 0,
                          isLast: index == data.length - 1,
                          handleEventSelection: widget.handleEventSelection,
                          isSelected: index == value,
                        ),
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

class EventTimelineListView extends StatelessWidget {
  const EventTimelineListView({
    Key? key,
    required this.data,
    required this.handleEventSelection,
    required this.selectedEventIndex,
  }) : super(key: key);

  final List<Event> data;
  final void Function(int) handleEventSelection;
  final ValueNotifier<int?> selectedEventIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: selectedEventIndex,
        builder: (context, value, _) {
          return ScrollConfiguration(
            behavior: WebScrollBehaviour(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => EventTimelineTile(
                index: index,
                event: data[index],
                isFirst: index == 0,
                isLast: index == data.length - 1,
                handleEventSelection: handleEventSelection,
                isSelected: index == value,
              ),
            ),
          );
        });
  }
}
